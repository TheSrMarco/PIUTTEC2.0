from decimal import Decimal
from django.conf import settings
from django.core.validators import MaxValueValidator, MinValueValidator
from django.db import models


class Materia(models.Model):
    usuario = models.ForeignKey(settings.AUTH_USER_MODEL, on_delete=models.CASCADE,
                                related_name="materias_registradas")
    nombre = models.CharField(max_length=120)
    docente = models.CharField(max_length=120, blank=True)
    grupo = models.CharField(max_length=50, blank=True)
    aula = models.CharField(max_length=80, blank=True)
    calificacion = models.DecimalField(max_digits=4, decimal_places=2, null=True, blank=True,
        validators=[MinValueValidator(Decimal("0")), MaxValueValidator(Decimal("10"))])
    creado_en = models.DateTimeField(auto_now_add=True)

    class Meta:
        ordering = ("nombre", "id")
        indexes = [models.Index(fields=["usuario", "nombre"], name="academia_usuario_nom_idx")]

    def __str__(self):
        return self.nombre


class Horario(models.Model):
    class Dia(models.IntegerChoices):
        LUNES = 1, "Lunes"
        MARTES = 2, "Martes"
        MIERCOLES = 3, "Miércoles"
        JUEVES = 4, "Jueves"
        VIERNES = 5, "Viernes"
        SABADO = 6, "Sábado"
        DOMINGO = 7, "Domingo"

    materia = models.ForeignKey(Materia, on_delete=models.CASCADE, related_name="horarios")
    dia_semana = models.PositiveSmallIntegerField(choices=Dia.choices)
    inicio = models.TimeField()
    fin = models.TimeField()
    aula = models.CharField(max_length=80, blank=True)

    class Meta:
        ordering = ("dia_semana", "inicio", "id")
        indexes = [models.Index(fields=["materia", "dia_semana"], name="academia_materia_dia_idx")]

    def __str__(self):
        return f"{self.materia} - {self.get_dia_semana_display()} {self.inicio}"
