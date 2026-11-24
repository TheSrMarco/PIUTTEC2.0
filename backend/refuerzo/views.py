from rest_framework import viewsets
from rest_framework.decorators import action
from rest_framework.permissions import IsAuthenticated
from rest_framework.response import Response
from .models import IntentoRefuerzo
from .serializers import IntentoSerializer


class IntentoViewSet(viewsets.ModelViewSet):
    serializer_class = IntentoSerializer
    permission_classes = (IsAuthenticated,)
    http_method_names = ('get', 'post', 'head', 'options')

    def get_queryset(self):
        return IntentoRefuerzo.objects.filter(usuario=self.request.user)

    def perform_create(self, serializer):
        serializer.save(usuario=self.request.user)

    @action(detail=False, methods=('get',))
    def resumen(self, request):
        qs = self.get_queryset()
        intentos = qs.count()
        porcentajes = [round(item.aciertos * 100 / item.total, 2) for item in qs.only('aciertos', 'total')]
        mejor = max(porcentajes) if porcentajes else None
        promedio = round(sum(porcentajes) / len(porcentajes), 2) if porcentajes else None
        logros = []
        if intentos >= 1: logros.append('Primera práctica')
        if intentos >= 5: logros.append('Constancia: cinco intentos')
        if mejor == 100: logros.append('Puntuación perfecta')
        return Response({'intentos': intentos, 'mejor_porcentaje': mejor,
                         'promedio_porcentaje': promedio, 'logros': logros})
