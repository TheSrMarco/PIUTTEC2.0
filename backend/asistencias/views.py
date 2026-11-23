from datetime import date

from django.db import transaction
from django.utils import timezone
from rest_framework import serializers, status, viewsets
from rest_framework.decorators import action
from rest_framework.permissions import IsAuthenticated
from rest_framework.response import Response

from academia.models import Materia
from .models import Asistencia
from .serializers import AsistenciaSerializer


class AsistenciaViewSet(viewsets.ModelViewSet):
    """Un registro por materia y día. Datos personales, no pase de lista oficial."""
    permission_classes = (IsAuthenticated,)
    serializer_class = AsistenciaSerializer
    http_method_names = ("get", "post", "patch", "delete", "head", "options")

    def get_queryset(self):
        queryset = Asistencia.objects.select_related("materia").filter(usuario=self.request.user)
        materia = self.request.query_params.get("materia")
        fecha = self.request.query_params.get("fecha")
        if materia is not None:
            if not materia.isdecimal():
                raise serializers.ValidationError({"materia": "Identificador no válido."})
            queryset = queryset.filter(materia_id=int(materia))
        if fecha is not None:
            try:
                queryset = queryset.filter(fecha=date.fromisoformat(fecha))
            except ValueError as exc:
                raise serializers.ValidationError({"fecha": "Utiliza AAAA-MM-DD."}) from exc
        return queryset

    def perform_create(self, serializer):
        serializer.save(usuario=self.request.user)

    @action(detail=False, methods=["post"], url_path="marcar-todas")
    def marcar_todas(self, request):
        """Marca como P las materias solicitadas en una única transacción."""
        if not isinstance(request.data, dict) or set(request.data) != {"fecha", "materias"}:
            raise serializers.ValidationError({"datos": "Envía fecha y materias."})
        dia = serializers.DateField().run_validation(request.data["fecha"])
        if dia > timezone.localdate():
            raise serializers.ValidationError({"fecha": "No se admiten fechas futuras."})
        ids = request.data["materias"]
        if not isinstance(ids, list) or not ids or any(type(pk) is not int or pk < 1 for pk in ids):
            raise serializers.ValidationError({"materias": "Proporciona identificadores válidos."})
        if len(set(ids)) != len(ids) or len(ids) > 100:
            raise serializers.ValidationError({"materias": "No dupliques materias; máximo 100."})
        autorizadas = Materia.objects.filter(usuario=request.user, pk__in=ids)
        if autorizadas.count() != len(ids):
            raise serializers.ValidationError({"materias": "Una o varias materias no pertenecen a esta cuenta."})
        with transaction.atomic():
            for materia in autorizadas:
                Asistencia.objects.update_or_create(usuario=request.user, materia=materia,
                    fecha=dia, defaults={"estado": Asistencia.Estado.PRESENTE})
        return Response({"actualizadas": len(ids), "fecha": dia.isoformat()}, status=status.HTTP_200_OK)
