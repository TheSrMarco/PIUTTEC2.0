from django.db import migrations, models
from django.db.models.functions import Lower

class Migration(migrations.Migration):
    initial = True
    dependencies = []
    operations = [
        migrations.CreateModel(name='Recurso', fields=[
            ('id', models.BigAutoField(auto_created=True, primary_key=True, serialize=False, verbose_name='ID')),
            ('tipo', models.CharField(choices=[('laboratorio', 'Laboratorio'), ('equipo', 'Equipo')], max_length=20)),
            ('nombre', models.CharField(max_length=120)),
            ('descripcion', models.CharField(blank=True, max_length=300)),
            ('ubicacion', models.CharField(blank=True, max_length=120)),
            ('capacidad', models.PositiveIntegerField(blank=True, null=True)),
            ('activo', models.BooleanField(default=True)),
            ('creado_en', models.DateTimeField(auto_now_add=True)),
        ], options={'ordering': ('tipo', 'nombre')}),
        migrations.AddConstraint(model_name='recurso', constraint=models.UniqueConstraint(Lower('nombre'), 'tipo', name='recurso_nombre_tipo_unico')),
    ]
