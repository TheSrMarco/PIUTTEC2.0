from decimal import Decimal
from django.conf import settings
from django.core.validators import MaxValueValidator, MinValueValidator
from django.db import migrations, models
import django.db.models.deletion


class Migration(migrations.Migration):
    initial = True
    dependencies = [migrations.swappable_dependency(settings.AUTH_USER_MODEL)]
    operations = [
        migrations.CreateModel(
            name="Materia",
            fields=[
                ("id", models.BigAutoField(auto_created=True, primary_key=True, serialize=False, verbose_name="ID")),
                ("nombre", models.CharField(max_length=120)),
                ("docente", models.CharField(blank=True, max_length=120)),
                ("grupo", models.CharField(blank=True, max_length=50)),
                ("aula", models.CharField(blank=True, max_length=80)),
                ("calificacion", models.DecimalField(blank=True, decimal_places=2, max_digits=4, null=True,
                    validators=[MinValueValidator(Decimal("0")), MaxValueValidator(Decimal("10"))])),
                ("creado_en", models.DateTimeField(auto_now_add=True)),
                ("usuario", models.ForeignKey(on_delete=django.db.models.deletion.CASCADE,
                    related_name="materias_registradas", to=settings.AUTH_USER_MODEL)),
            ],
            options={"ordering": ("nombre", "id")},
        ),
        migrations.CreateModel(
            name="Horario",
            fields=[
                ("id", models.BigAutoField(auto_created=True, primary_key=True, serialize=False, verbose_name="ID")),
                ("dia_semana", models.PositiveSmallIntegerField(choices=[(1, "Lunes"), (2, "Martes"),
                    (3, "Miércoles"), (4, "Jueves"), (5, "Viernes"), (6, "Sábado"), (7, "Domingo")])),
                ("inicio", models.TimeField()),
                ("fin", models.TimeField()),
                ("aula", models.CharField(blank=True, max_length=80)),
                ("materia", models.ForeignKey(on_delete=django.db.models.deletion.CASCADE,
                    related_name="horarios", to="academia.materia")),
            ],
            options={"ordering": ("dia_semana", "inicio", "id")},
        ),
        migrations.AddIndex(model_name="materia", index=models.Index(fields=["usuario", "nombre"], name="academia_usuario_nom_idx")),
        migrations.AddIndex(model_name="horario", index=models.Index(fields=["materia", "dia_semana"], name="academia_materia_dia_idx")),
    ]
