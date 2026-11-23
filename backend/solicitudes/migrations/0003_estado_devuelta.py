from django.db import migrations, models

class Migration(migrations.Migration):
    dependencies = [('solicitudes', '0002_solicitud_materia')]
    operations = [migrations.AlterField(model_name='solicitud', name='estado',
        field=models.CharField(max_length=20, default='pendiente', choices=[
            ('pendiente', 'Pendiente'), ('aprobada', 'Aprobada'), ('rechazada', 'Rechazada'),
            ('cancelada', 'Cancelada'), ('devuelta', 'Devuelta')]))]
