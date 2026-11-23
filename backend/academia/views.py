from rest_framework import viewsets
from rest_framework.permissions import IsAuthenticated
from .models import Materia, Horario
from .serializers import MateriaSerializer, HorarioSerializer


class MateriaViewSet(viewsets.ModelViewSet):
    """Materias personales; una cuenta no ve las de otra."""
    permission_classes = [IsAuthenticated]
    serializer_class = MateriaSerializer
    http_method_names = ["get", "post", "patch", "delete", "head", "options"]

    def get_queryset(self):
        return Materia.objects.filter(usuario=self.request.user)

    def perform_create(self, serializer):
        serializer.save(usuario=self.request.user)


class HorarioViewSet(viewsets.ModelViewSet):
    """Horarios personales vinculados a materias del usuario autenticado."""
    permission_classes = [IsAuthenticated]
    serializer_class = HorarioSerializer
    http_method_names = ["get", "post", "patch", "delete", "head", "options"]

    def get_queryset(self):
        queryset = Horario.objects.select_related("materia").filter(materia__usuario=self.request.user)
        materia_id = self.request.query_params.get("materia")
        if materia_id:
            queryset = queryset.filter(materia_id=materia_id)
        return queryset
