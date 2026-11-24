from django.db import transaction
from rest_framework import status, viewsets
from rest_framework.exceptions import PermissionDenied, ValidationError
from rest_framework.permissions import IsAuthenticated
from rest_framework.response import Response

from .models import Solicitud
from recursos.models import Recurso
from asistencias.models import Asistencia
from .serializers import (
    SolicitudCancelSerializer,
    SolicitudCreateSerializer,
    SolicitudReadSerializer,
    SolicitudReviewSerializer,
)


def es_administrador(user):
    return user.is_superuser or user.role == "administrator"


class SolicitudViewSet(viewsets.ModelViewSet):
    """Alumno/docente: sus solicitudes. Administrador: todas y revisión."""

    permission_classes = [IsAuthenticated]
    http_method_names = ["get", "post", "patch", "delete", "head", "options"]

    def get_queryset(self):
        qs = Solicitud.objects.select_related("usuario", "revisado_por")
        if es_administrador(self.request.user):
            return qs
        return qs.filter(usuario=self.request.user)

    def get_serializer_class(self):
        if self.action == "create":
            return SolicitudCreateSerializer
        if self.action == "partial_update":
            return SolicitudReviewSerializer if es_administrador(self.request.user) else SolicitudCancelSerializer
        return SolicitudReadSerializer

    def create(self, request, *args, **kwargs):
        serializer = self.get_serializer(data=request.data)
        serializer.is_valid(raise_exception=True)
        solicitud = serializer.save(usuario=request.user)
        return Response(SolicitudReadSerializer(solicitud).data, status=status.HTTP_201_CREATED)

    @transaction.atomic
    def partial_update(self, request, *args, **kwargs):
        solicitud = self.get_object()
        if not es_administrador(request.user) and request.data.get("estado") != Solicitud.Estado.CANCELADA:
            raise PermissionDenied("Solo un administrador puede aprobar o rechazar solicitudes.")
        # Bloqueo de la solicitud para evitar dos revisiones simultáneas.
        solicitud = Solicitud.objects.select_for_update().get(pk=solicitud.pk)
        # Una revisión de reserva bloquea también la fila del catálogo en PostgreSQL.
        if es_administrador(request.user) and solicitud.tipo != Solicitud.Tipo.JUSTIFICANTE:
            list(Recurso.objects.select_for_update().filter(
                tipo=solicitud.tipo, nombre__iexact=solicitud.recurso))
        serializer = self.get_serializer(solicitud, data=request.data, partial=True)
        serializer.is_valid(raise_exception=True)
        if es_administrador(request.user):
            solicitud = serializer.save(revisado_por=request.user)
        else:
            solicitud = serializer.save()
        # Un justificante aprobado transforma solo una falta real de la materia y fecha
        # propias; no crea registros oficiales ni modifica otras materias.
        if (es_administrador(request.user) and solicitud.estado == Solicitud.Estado.APROBADA
                and solicitud.tipo == Solicitud.Tipo.JUSTIFICANTE and solicitud.materia_id):
            Asistencia.objects.filter(usuario=solicitud.usuario, materia_id=solicitud.materia_id,
                fecha=solicitud.fecha_solicitada, estado=Asistencia.Estado.FALTA).update(
                estado=Asistencia.Estado.JUSTIFICADO)
        return Response(SolicitudReadSerializer(solicitud).data)

    def destroy(self, request, *args, **kwargs):
        solicitud = self.get_object()
        if solicitud.estado != Solicitud.Estado.PENDIENTE:
            raise ValidationError({"estado": "Las solicitudes revisadas no se pueden eliminar; conservar historial."})
        if solicitud.usuario_id != request.user.pk:
            raise PermissionDenied("Solo el solicitante puede eliminar su solicitud pendiente.")
        return super().destroy(request, *args, **kwargs)
