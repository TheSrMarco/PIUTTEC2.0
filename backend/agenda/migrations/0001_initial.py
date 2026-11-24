from django.conf import settings
from django.db import migrations, models
import django.db.models.deletion


class Migration(migrations.Migration):
    initial = True
    dependencies = [migrations.swappable_dependency(settings.AUTH_USER_MODEL)]
    operations = [
        migrations.CreateModel(
            name="Actividad",
            fields=[
                ("id", models.BigAutoField(auto_created=True, primary_key=True, serialize=False, verbose_name="ID")),
                ("titulo", models.CharField(max_length=120)),
                ("descripcion", models.TextField(blank=True, max_length=1000)),
                ("materia", models.CharField(blank=True, max_length=120)),
                ("tipo", models.CharField(choices=[("tarea", "Tarea"), ("evaluacion", "Evaluación"), ("evento", "Evento")], default="tarea", max_length=12)),
                ("fecha", models.DateField()),
                ("hora", models.TimeField(blank=True, null=True)),
                ("completada", models.BooleanField(default=False)),
                ("creado_en", models.DateTimeField(auto_now_add=True)),
                ("actualizado_en", models.DateTimeField(auto_now=True)),
                ("usuario", models.ForeignKey(on_delete=django.db.models.deletion.CASCADE, related_name="actividades", to=settings.AUTH_USER_MODEL)),
            ],
            options={"ordering": ("fecha", "hora", "id")},
        ),
        migrations.AddIndex(
            model_name="actividad",
            index=models.Index(fields=["usuario", "fecha"], name="agenda_usuario_fecha_idx"),
        ),
    ]
