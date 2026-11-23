from django.conf import settings
from django.db import models


class Actividad(models.Model):
    class Tipo(models.TextChoices):
        TAREA = "tarea", "Tarea"
        EVALUACION = "evaluacion", "Evaluación"
        EVENTO = "evento", "Evento"

    usuario = models.ForeignKey(
        settings.AUTH_USER_MODEL, on_delete=models.CASCADE, related_name="actividades"
    )
    titulo = models.CharField(max_length=120)
    descripcion = models.TextField(blank=True, max_length=1000)
    materia = models.CharField(max_length=120, blank=True)
    tipo = models.CharField(max_length=12, choices=Tipo.choices, default=Tipo.TAREA)
    fecha = models.DateField()
    hora = models.TimeField(null=True, blank=True)
    completada = models.BooleanField(default=False)
    creado_en = models.DateTimeField(auto_now_add=True)
    actualizado_en = models.DateTimeField(auto_now=True)

    class Meta:
        ordering = ("fecha", "hora", "id")
        indexes = [models.Index(fields=["usuario", "fecha"], name="agenda_usuario_fecha_idx")]

    def __str__(self):
        return f"{self.titulo} ({self.fecha})"
