from django.db import migrations, models
import django.db.models.deletion

class Migration(migrations.Migration):
    dependencies = [('solicitudes', '0001_initial'), ('academia', '0001_initial')]
    operations = [migrations.AddField(model_name='solicitud', name='materia',
        field=models.ForeignKey(blank=True, null=True, on_delete=django.db.models.deletion.SET_NULL,
                                related_name='justificantes_solicitados', to='academia.materia'))]
