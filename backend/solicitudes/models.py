from django.conf import settings
from django.db import models


class Solicitud(models.Model):
    """Solicitud institucional. Una reserva no se confirma hasta aprobarse."""

    class Tipo(models.TextChoices):
        LABORATORIO = "laboratorio", "Laboratorio"
        EQUIPO = "equipo", "Equipo"
        JUSTIFICANTE = "justificante", "Justificante"

    class Estado(models.TextChoices):
        PENDIENTE = "pendiente", "Pendiente"
        APROBADA = "aprobada", "Aprobada"
        RECHAZADA = "rechazada", "Rechazada"
        CANCELADA = "cancelada", "Cancelada"
        DEVUELTA = "devuelta", "Devuelta"

    usuario = models.ForeignKey(
        settings.AUTH_USER_MODEL, on_delete=models.PROTECT, related_name="solicitudes"
    )
    materia = models.ForeignKey("academia.Materia", null=True, blank=True, on_delete=models.SET_NULL,
                               related_name="justificantes_solicitados")
    tipo = models.CharField(max_length=20, choices=Tipo.choices)
    recurso = models.CharField(max_length=120, blank=True)
    fecha_solicitada = models.DateField()
    hora_inicio = models.TimeField(null=True, blank=True)
    hora_fin = models.TimeField(null=True, blank=True)
    motivo = models.TextField(max_length=500)
    estado = models.CharField(
        max_length=20, choices=Estado.choices, default=Estado.PENDIENTE
    )
    observaciones_revision = models.CharField(max_length=500, blank=True)
    revisado_por = models.ForeignKey(
        settings.AUTH_USER_MODEL,
        on_delete=models.SET_NULL,
        null=True,
        blank=True,
        related_name="solicitudes_revisadas",
    )
    creado_en = models.DateTimeField(auto_now_add=True)
    actualizado_en = models.DateTimeField(auto_now=True)

    class Meta:
        ordering = ["-creado_en"]
        indexes = [models.Index(fields=["tipo", "recurso", "fecha_solicitada", "estado"], name="solicitud_reserva_idx")]

    def __str__(self):
        return f"Solicitud {self.pk}: {self.get_tipo_display()} ({self.get_estado_display()})"
