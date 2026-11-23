import uuid
from pathlib import Path
from django.conf import settings
from django.db import models, transaction


def ruta_privada(instance, original):
    extension = Path(original).suffix.lower()
    return f'usuarios/{instance.usuario_id}/{uuid.uuid4().hex}{extension}'


class Documento(models.Model):
    """Archivo personal de práctica, accesible solo desde las rutas JWT."""
    usuario = models.ForeignKey(settings.AUTH_USER_MODEL, on_delete=models.CASCADE,
                                related_name='documentos_guardados')
    nombre = models.CharField(max_length=180)
    materia = models.CharField(max_length=120, blank=True)
    archivo = models.FileField(upload_to=ruta_privada, max_length=260)
    tamano = models.PositiveIntegerField()
    creado_en = models.DateTimeField(auto_now_add=True)

    class Meta:
        ordering = ('-creado_en', '-id')
        indexes = [models.Index(fields=('usuario', 'creado_en'), name='documentos_usuario_fecha_idx')]

    def delete(self, using=None, keep_parents=False):
        storage, path = self.archivo.storage, self.archivo.name
        result = super().delete(using=using, keep_parents=keep_parents)
        transaction.on_commit(lambda: storage.delete(path))
        return result
