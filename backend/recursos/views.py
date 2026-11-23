from datetime import date, time
from rest_framework import viewsets
from rest_framework.decorators import action
from rest_framework.exceptions import PermissionDenied, ValidationError
from rest_framework.permissions import IsAuthenticated
from rest_framework.response import Response
from solicitudes.models import Solicitud
from .models import Recurso
from .serializers import RecursoSerializer


def administrador(user):
    return user.is_superuser or user.role == 'administrator'


class RecursoViewSet(viewsets.ModelViewSet):
    serializer_class = RecursoSerializer
    permission_classes = (IsAuthenticated,)
    http_method_names = ('get', 'post', 'patch', 'delete', 'head', 'options')

    def get_queryset(self):
        qs = Recurso.objects.all()
        if not administrador(self.request.user):
            qs = qs.filter(activo=True)
        tipo = self.request.query_params.get('tipo')
        if tipo:
            if tipo not in Recurso.Tipo.values:
                raise ValidationError({'tipo': 'Tipo de recurso inválido.'})
            qs = qs.filter(tipo=tipo)
        return qs

    def perform_create(self, serializer):
        if not administrador(self.request.user):
            raise PermissionDenied('Solo administración puede crear recursos.')
        serializer.save()

    def perform_update(self, serializer):
        if not administrador(self.request.user):
            raise PermissionDenied('Solo administración puede editar recursos.')
        serializer.save()

    def perform_destroy(self, instance):
        if not administrador(self.request.user):
            raise PermissionDenied('Solo administración puede retirar recursos.')
        # Mantener catálogo histórico para que las solicitudes antiguas sigan siendo legibles.
        instance.activo = False
        instance.save(update_fields=['activo'])

    @action(detail=True, methods=('get',))
    def disponibilidad(self, request, pk=None):
        recurso = self.get_object()
        params = request.query_params
        try:
            fecha = date.fromisoformat(params['fecha'])
            inicio = time.fromisoformat(params['inicio'])
            fin = time.fromisoformat(params['fin'])
        except (ValueError, KeyError, TypeError) as exc:
            raise ValidationError({'intervalo': 'Indica fecha (AAAA-MM-DD), inicio y fin (HH:MM).'}) from exc
        if inicio >= fin:
            raise ValidationError({'intervalo': 'La hora final debe ser posterior a la inicial.'})
        ocupada = Solicitud.objects.filter(
            tipo=recurso.tipo, recurso__iexact=recurso.nombre,
            fecha_solicitada=fecha, estado=Solicitud.Estado.APROBADA,
            hora_inicio__lt=fin, hora_fin__gt=inicio,
        ).exists()
        return Response({'recurso': recurso.pk, 'disponible': recurso.activo and not ocupada,
                         'fecha': fecha.isoformat(), 'inicio': inicio.isoformat(timespec='minutes'),
                         'fin': fin.isoformat(timespec='minutes')})
