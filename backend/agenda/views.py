from datetime import date

from rest_framework import viewsets
from rest_framework.exceptions import ValidationError
from rest_framework.permissions import IsAuthenticated

from .models import Actividad
from .serializers import ActividadSerializer


class ActividadViewSet(viewsets.ModelViewSet):
    """CRUD de agenda personal; nunca comparte actividades entre usuarios."""
    permission_classes = [IsAuthenticated]
    serializer_class = ActividadSerializer
    http_method_names = ["get", "post", "patch", "delete", "head", "options"]

    def get_queryset(self):
        queryset = Actividad.objects.filter(usuario=self.request.user)
        start = self.request.query_params.get("desde")
        end = self.request.query_params.get("hasta")
        tipo = self.request.query_params.get("tipo")
        completed = self.request.query_params.get("completada")
        try:
            if start:
                queryset = queryset.filter(fecha__gte=date.fromisoformat(start))
            if end:
                queryset = queryset.filter(fecha__lte=date.fromisoformat(end))
        except ValueError as error:
            raise ValidationError({"fecha": "Utiliza el formato AAAA-MM-DD."}) from error
        if start and end and date.fromisoformat(start) > date.fromisoformat(end):
            raise ValidationError({"fecha": "La fecha inicial debe ser anterior a la final."})
        if tipo:
            if tipo not in Actividad.Tipo.values:
                raise ValidationError({"tipo": "Tipo de actividad no válido."})
            queryset = queryset.filter(tipo=tipo)
        if completed is not None:
            if completed.lower() not in {"true", "false"}:
                raise ValidationError({"completada": "Usa true o false."})
            queryset = queryset.filter(completada=completed.lower() == "true")
        return queryset

    def perform_create(self, serializer):
        serializer.save(usuario=self.request.user)
