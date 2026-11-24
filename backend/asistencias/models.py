"""Asistencias: asistencias personales de práctica, no registros institucionales."""
from django.conf import settings
from django.db import models


class Asistencia(models.Model):
    class Estado(models.TextChoices):
        PRESENTE = "P", "Presente"
        RETARDO = "R", "Retardo"
        JUSTIFICADO = "J", "Justificado"
        FALTA = "F", "Falta"

    usuario = models.ForeignKey(settings.AUTH_USER_MODEL, on_delete=models.CASCADE,
        related_name="asistencias_registradas")
    materia = models.ForeignKey("academia.Materia", on_delete=models.CASCADE,
        related_name="asistencias")
    fecha = models.DateField()
    estado = models.CharField(max_length=1, choices=Estado.choices)
    creado_en = models.DateTimeField(auto_now_add=True)
    actualizado_en = models.DateTimeField(auto_now=True)

    class Meta:
        ordering = ("-fecha", "-id")
        constraints = [models.UniqueConstraint(fields=("usuario", "materia", "fecha"),
            name="asistencia_unica_usuario_materia_fecha")]
        indexes = [models.Index(fields=("usuario", "fecha"), name="asistencia_usuario_fecha_idx")]

    def __str__(self):
        return f"{self.materia.nombre}: {self.fecha} {self.estado}"
