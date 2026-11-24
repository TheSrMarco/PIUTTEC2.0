from django.conf import settings
from django.db import migrations, models
import django.db.models.deletion


class Migration(migrations.Migration):
    initial = True
    dependencies = [
        migrations.swappable_dependency(settings.AUTH_USER_MODEL),
        ("academia", "0001_initial"),
    ]
    operations = [
        migrations.CreateModel(
            name="Asistencia",
            fields=[
                ("id", models.BigAutoField(auto_created=True, primary_key=True, serialize=False, verbose_name="ID")),
                ("fecha", models.DateField()),
                ("estado", models.CharField(max_length=1, choices=[("P", "Presente"), ("R", "Retardo"),
                    ("J", "Justificado"), ("F", "Falta")])),
                ("creado_en", models.DateTimeField(auto_now_add=True)),
                ("actualizado_en", models.DateTimeField(auto_now=True)),
                ("materia", models.ForeignKey(on_delete=django.db.models.deletion.CASCADE,
                    related_name="asistencias", to="academia.materia")),
                ("usuario", models.ForeignKey(on_delete=django.db.models.deletion.CASCADE,
                    related_name="asistencias_registradas", to=settings.AUTH_USER_MODEL)),
            ],
            options={"ordering": ("-fecha", "-id")},
        ),
        migrations.AddConstraint(model_name="asistencia", constraint=models.UniqueConstraint(
            fields=("usuario", "materia", "fecha"), name="asistencia_unica_usuario_materia_fecha")),
        migrations.AddIndex(model_name="asistencia", index=models.Index(fields=("usuario", "fecha"),
            name="asistencia_usuario_fecha_idx")),
    ]
