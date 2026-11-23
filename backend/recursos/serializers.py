from rest_framework import serializers
from .models import Recurso


class RecursoSerializer(serializers.ModelSerializer):
    class Meta:
        model = Recurso
        fields = ('id', 'tipo', 'nombre', 'descripcion', 'ubicacion', 'capacidad', 'activo')

    def validate_nombre(self, value):
        value = value.strip()
        if not value:
            raise serializers.ValidationError('El nombre no puede quedar vacío.')
        return value

    def validate(self, attrs):
        tipo = attrs.get('tipo', self.instance.tipo if self.instance else None)
        nombre = attrs.get('nombre', self.instance.nombre if self.instance else None)
        if tipo and nombre:
            qs = Recurso.objects.filter(tipo=tipo, nombre__iexact=nombre)
            if self.instance:
                qs = qs.exclude(pk=self.instance.pk)
            if qs.exists():
                raise serializers.ValidationError({'nombre': 'El recurso ya existe.'})
        return attrs
