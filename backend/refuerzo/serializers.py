from rest_framework import serializers
from .models import IntentoRefuerzo


class IntentoSerializer(serializers.ModelSerializer):
    def to_internal_value(self, data):
        if not hasattr(data, 'keys'):
            raise serializers.ValidationError('Se esperaba un objeto JSON.')
        extras = set(data.keys()) - set(self.fields.keys())
        if extras:
            raise serializers.ValidationError({'campos': 'No se admiten: ' + ', '.join(sorted(extras))})
        return super().to_internal_value(data)

    class Meta:
        model = IntentoRefuerzo
        fields = ('id', 'tema', 'carrera', 'cuatrimestre', 'parcial', 'aciertos', 'total', 'creado_en')
        read_only_fields = ('id', 'creado_en')

    def validate(self, attrs):
        if attrs['total'] < 1 or attrs['total'] > 100:
            raise serializers.ValidationError({'total': 'Debe haber entre 1 y 100 preguntas.'})
        if attrs['aciertos'] > attrs['total']:
            raise serializers.ValidationError({'aciertos': 'No puede superar el total.'})
        for campo in ('cuatrimestre', 'parcial'):
            value = attrs.get(campo)
            if value is not None and not 1 <= value <= (11 if campo == 'cuatrimestre' else 3):
                raise serializers.ValidationError({campo: 'Valor fuera de rango.'})
        attrs['tema'] = attrs['tema'].strip()
        if not attrs['tema']:
            raise serializers.ValidationError({'tema': 'Especifica un tema.'})
        return attrs
