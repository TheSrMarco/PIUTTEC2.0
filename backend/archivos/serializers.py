from pathlib import Path
from rest_framework import serializers
from .models import Documento

EXTENSIONES = {'.pdf', '.docx', '.xlsx', '.csv', '.txt', '.png', '.jpg', '.jpeg'}
MAX_BYTES = 10 * 1024 * 1024


class DocumentoSerializer(serializers.ModelSerializer):
    class Meta:
        model = Documento
        fields = ('id', 'nombre', 'materia', 'tamano', 'creado_en')
        read_only_fields = fields


class DocumentoUploadSerializer(serializers.Serializer):
    def to_internal_value(self, data):
        extras = set(data.keys()) - set(self.fields.keys())
        if extras:
            raise serializers.ValidationError({'campos': 'Campos no admitidos.'})
        return super().to_internal_value(data)

    archivo = serializers.FileField(allow_empty_file=False)
    materia = serializers.CharField(max_length=120, required=False, allow_blank=True)

    def validate_archivo(self, archivo):
        if archivo.size > MAX_BYTES:
            raise serializers.ValidationError('El archivo supera el máximo de 10 MB.')
        if Path(archivo.name).suffix.lower() not in EXTENSIONES:
            raise serializers.ValidationError('Extensión no permitida (PDF, Office, CSV, texto e imágenes).')
        if len(archivo.name) > 180:
            raise serializers.ValidationError('Nombre demasiado largo.')
        return archivo
