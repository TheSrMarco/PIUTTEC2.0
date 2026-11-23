from django.conf import settings
from django.db import models


class IntentoRefuerzo(models.Model):
    """Historial de prácticas académicas; no altera calificaciones oficiales."""
    usuario = models.ForeignKey(settings.AUTH_USER_MODEL, on_delete=models.CASCADE, related_name='intentos_refuerzo')
    tema = models.CharField(max_length=120)
    carrera = models.CharField(max_length=120, blank=True)
    cuatrimestre = models.PositiveSmallIntegerField(null=True, blank=True)
    parcial = models.PositiveSmallIntegerField(null=True, blank=True)
    aciertos = models.PositiveSmallIntegerField()
    total = models.PositiveSmallIntegerField()
    creado_en = models.DateTimeField(auto_now_add=True)

    class Meta:
        ordering = ('-creado_en', '-id')
        indexes = [models.Index(fields=('usuario', 'tema'), name='refuerzo_usuario_tema_idx')]
