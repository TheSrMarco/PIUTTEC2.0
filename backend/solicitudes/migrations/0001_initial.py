# Primera migración de RF-12. Compatible con AUTH_USER_MODEL del proyecto.
import django.db.models.deletion
from django.conf import settings
from django.db import migrations, models


class Migration(migrations.Migration):
    initial = True
    dependencies = [migrations.swappable_dependency(settings.AUTH_USER_MODEL)]

    operations = [
        migrations.CreateModel(
            name="Solicitud",
            fields=[
                ("id", models.BigAutoField(auto_created=True, primary_key=True, serialize=False, verbose_name="ID")),
                ("tipo", models.CharField(choices=[("laboratorio", "Laboratorio"), ("equipo", "Equipo"), ("justificante", "Justificante")], max_length=20)),
                ("recurso", models.CharField(blank=True, max_length=120)),
                ("fecha_solicitada", models.DateField()),
                ("hora_inicio", models.TimeField(blank=True, null=True)),
                ("hora_fin", models.TimeField(blank=True, null=True)),
                ("motivo", models.TextField(max_length=500)),
                ("estado", models.CharField(choices=[("pendiente", "Pendiente"), ("aprobada", "Aprobada"), ("rechazada", "Rechazada"), ("cancelada", "Cancelada")], default="pendiente", max_length=20)),
                ("observaciones_revision", models.CharField(blank=True, max_length=500)),
                ("creado_en", models.DateTimeField(auto_now_add=True)),
                ("actualizado_en", models.DateTimeField(auto_now=True)),
                ("revisado_por", models.ForeignKey(blank=True, null=True, on_delete=django.db.models.deletion.SET_NULL, related_name="solicitudes_revisadas", to=settings.AUTH_USER_MODEL)),
                ("usuario", models.ForeignKey(on_delete=django.db.models.deletion.PROTECT, related_name="solicitudes", to=settings.AUTH_USER_MODEL)),
            ],
            options={
                "ordering": ["-creado_en"],
                "indexes": [models.Index(fields=["tipo", "recurso", "fecha_solicitada", "estado"], name="solicitud_reserva_idx")],
            },
        ),
    ]
