from django.conf import settings
from django.db import migrations, models
import archivos.models
import django.db.models.deletion

class Migration(migrations.Migration):
    initial = True
    dependencies = [migrations.swappable_dependency(settings.AUTH_USER_MODEL)]
    operations = [migrations.CreateModel(name='Documento', fields=[
        ('id', models.BigAutoField(auto_created=True, primary_key=True, serialize=False, verbose_name='ID')),
        ('nombre', models.CharField(max_length=180)),
        ('materia', models.CharField(blank=True, max_length=120)),
        ('archivo', models.FileField(max_length=260, upload_to=archivos.models.ruta_privada)),
        ('tamano', models.PositiveIntegerField()),
        ('creado_en', models.DateTimeField(auto_now_add=True)),
        ('usuario', models.ForeignKey(on_delete=django.db.models.deletion.CASCADE, related_name='documentos_guardados', to=settings.AUTH_USER_MODEL)),
    ], options={'ordering': ('-creado_en', '-id'), 'indexes': [models.Index(fields=('usuario', 'creado_en'), name='documentos_usuario_fecha_idx')]})]
