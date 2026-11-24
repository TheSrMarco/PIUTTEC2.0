from decimal import Decimal
from rest_framework import serializers
from .models import Materia, Horario


class SoloCamposDeclarados:
    """Impide aceptar silenciosamente campos no definidos o forzar el dueño."""
    def to_internal_value(self, data):
        if not hasattr(data, "keys"):
            raise serializers.ValidationError("Se espera un objeto JSON.")
        extras = set(data.keys()) - set(self.fields.keys())
        if extras:
            raise serializers.ValidationError({"campos": "Campos no permitidos: " + ", ".join(sorted(extras))})
        return super().to_internal_value(data)


class MateriaSerializer(SoloCamposDeclarados, serializers.ModelSerializer):
    class Meta:
        model = Materia
        fields = ("id", "nombre", "docente", "grupo", "aula", "calificacion", "creado_en")
        read_only_fields = ("id", "creado_en")

    def validate_nombre(self, value):
        value = value.strip()
        if not value:
            raise serializers.ValidationError("Escribe el nombre de la materia.")
        return value


class HorarioSerializer(SoloCamposDeclarados, serializers.ModelSerializer):
    materia_nombre = serializers.CharField(source="materia.nombre", read_only=True)

    class Meta:
        model = Horario
        fields = ("id", "materia", "materia_nombre", "dia_semana", "inicio", "fin", "aula")
        read_only_fields = ("id", "materia_nombre")

    def __init__(self, *args, **kwargs):
        super().__init__(*args, **kwargs)
        request = self.context.get("request")
        self.fields["materia"].queryset = (Materia.objects.filter(usuario=request.user)
            if request is not None and request.user.is_authenticated else Materia.objects.none())

    def validate(self, attrs):
        materia = attrs.get("materia", self.instance.materia if self.instance else None)
        day = attrs.get("dia_semana", self.instance.dia_semana if self.instance else None)
        start = attrs.get("inicio", self.instance.inicio if self.instance else None)
        end = attrs.get("fin", self.instance.fin if self.instance else None)
        if start is not None and end is not None and start >= end:
            raise serializers.ValidationError({"horario": "La hora final debe ser posterior a la inicial."})
        if materia is not None and day is not None and start is not None and end is not None:
            request = self.context["request"]
            overlap = Horario.objects.filter(
                materia__usuario=request.user, dia_semana=day,
                inicio__lt=end, fin__gt=start,
            )
            if self.instance:
                overlap = overlap.exclude(pk=self.instance.pk)
            if overlap.exists():
                raise serializers.ValidationError({"horario": "Ya tienes otra clase en ese día y horario."})
        return attrs
