from django.db import models
from django.db.models.functions import Lower


class Recurso(models.Model):
    """Catálogo de espacios y equipos disponibles para solicitar (no autoconfirma)."""

    class Tipo(models.TextChoices):
        LABORATORIO = 'laboratorio', 'Laboratorio'
        EQUIPO = 'equipo', 'Equipo'

    tipo = models.CharField(max_length=20, choices=Tipo.choices)
    nombre = models.CharField(max_length=120)
    descripcion = models.CharField(max_length=300, blank=True)
    ubicacion = models.CharField(max_length=120, blank=True)
    capacidad = models.PositiveIntegerField(null=True, blank=True)
    activo = models.BooleanField(default=True)
    creado_en = models.DateTimeField(auto_now_add=True)

    class Meta:
        ordering = ('tipo', 'nombre')
        constraints = [models.UniqueConstraint(Lower('nombre'), 'tipo', name='recurso_nombre_tipo_unico')]

    def __str__(self):
        return f'{self.get_tipo_display()}: {self.nombre}'
