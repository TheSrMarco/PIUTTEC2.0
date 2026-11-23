from django.utils import timezone
from rest_framework import serializers
from academia.models import Materia
from .models import Asistencia


class AsistenciaSerializer(serializers.ModelSerializer):
    materia_nombre = serializers.CharField(source="materia.nombre", read_only=True)

    class Meta:
        model = Asistencia
        fields = ("id", "materia", "materia_nombre", "fecha", "estado", "actualizado_en")
        read_only_fields = ("id", "materia_nombre", "actualizado_en")

    def __init__(self, *args, **kwargs):
        super().__init__(*args, **kwargs)
        request = self.context.get("request")
        self.fields["materia"].queryset = (Materia.objects.filter(usuario=request.user)
            if request is not None and request.user.is_authenticated else Materia.objects.none())

    def to_internal_value(self, data):
        if not isinstance(data, dict):
            raise serializers.ValidationError("Se espera un objeto JSON.")
        extras = set(data) - set(self.fields)
        if extras:
            raise serializers.ValidationError({"campos": "No permitidos: " + ", ".join(sorted(extras))})
        return super().to_internal_value(data)

    def validate(self, attrs):
        fecha = attrs.get("fecha", self.instance.fecha if self.instance else None)
        materia = attrs.get("materia", self.instance.materia if self.instance else None)
        if fecha and fecha > timezone.localdate():
            raise serializers.ValidationError({"fecha": "No se puede registrar asistencia futura."})
        if materia is not None and fecha is not None:
            usuario = self.context["request"].user
            coincidencias = Asistencia.objects.filter(usuario=usuario, materia=materia, fecha=fecha)
            if self.instance:
                coincidencias = coincidencias.exclude(pk=self.instance.pk)
            if coincidencias.exists():
                raise serializers.ValidationError({"fecha": "Ya hay un registro para esta materia y fecha; edítalo."})
        return attrs
