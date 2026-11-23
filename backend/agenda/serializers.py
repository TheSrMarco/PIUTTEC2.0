from rest_framework import serializers
from .models import Actividad


class ActividadSerializer(serializers.ModelSerializer):
    class Meta:
        model = Actividad
        fields = (
            "id", "titulo", "descripcion", "materia", "tipo", "fecha", "hora",
            "completada", "creado_en", "actualizado_en"
        )
        read_only_fields = ("id", "creado_en", "actualizado_en")

    def validate_titulo(self, value):
        value = value.strip()
        if not value:
            raise serializers.ValidationError("Escribe el título de la actividad.")
        return value
