from django.conf import settings
from django.db import migrations, models
import django.db.models.deletion

class Migration(migrations.Migration):
    initial = True
    dependencies = [migrations.swappable_dependency(settings.AUTH_USER_MODEL)]
    operations = [migrations.CreateModel(name='IntentoRefuerzo', fields=[
        ('id', models.BigAutoField(auto_created=True, primary_key=True, serialize=False, verbose_name='ID')),
        ('tema', models.CharField(max_length=120)),
        ('carrera', models.CharField(blank=True, max_length=120)),
        ('cuatrimestre', models.PositiveSmallIntegerField(blank=True, null=True)),
        ('parcial', models.PositiveSmallIntegerField(blank=True, null=True)),
        ('aciertos', models.PositiveSmallIntegerField()),
        ('total', models.PositiveSmallIntegerField()),
        ('creado_en', models.DateTimeField(auto_now_add=True)),
        ('usuario', models.ForeignKey(on_delete=django.db.models.deletion.CASCADE, related_name='intentos_refuerzo', to=settings.AUTH_USER_MODEL)),
    ], options={'ordering': ('-creado_en', '-id'), 'indexes': [models.Index(fields=('usuario', 'tema'), name='refuerzo_usuario_tema_idx')]})]
