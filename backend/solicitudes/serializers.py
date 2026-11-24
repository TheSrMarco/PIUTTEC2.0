from django.utils import timezone
from rest_framework import serializers

from .models import Solicitud
from academia.models import Materia
from recursos.models import Recurso


class StrictFieldsMixin:
    """Evita aceptar silenciosamente campos extra como estado o usuario."""

    def to_internal_value(self, data):
        if not hasattr(data, "keys"):
            raise serializers.ValidationError("Se esperaba un objeto JSON.")
        extra = set(data.keys()) - set(self.fields.keys())
        if extra:
            raise serializers.ValidationError(
                {"campos": f"Campos no permitidos: {', '.join(sorted(extra))}."}
            )
        return super().to_internal_value(data)


class SolicitudReadSerializer(serializers.ModelSerializer):
    usuario = serializers.StringRelatedField(read_only=True)
    revisado_por = serializers.StringRelatedField(read_only=True)

    class Meta:
        model = Solicitud
        fields = [
            "id", "usuario", "materia", "tipo", "recurso", "fecha_solicitada",
            "hora_inicio", "hora_fin", "motivo", "estado",
            "observaciones_revision", "revisado_por", "creado_en", "actualizado_en",
        ]
        read_only_fields = fields


class SolicitudCreateSerializer(StrictFieldsMixin, serializers.ModelSerializer):
    materia = serializers.PrimaryKeyRelatedField(queryset=Materia.objects.none(), required=False, allow_null=True)

    def __init__(self, *args, **kwargs):
        super().__init__(*args, **kwargs)
        request = self.context.get('request')
        if request is not None and request.user.is_authenticated:
            self.fields['materia'].queryset = Materia.objects.filter(usuario=request.user)

    class Meta:
        model = Solicitud
        fields = [
            "tipo", "recurso", "fecha_solicitada", "hora_inicio", "hora_fin", "motivo", "materia",
        ]
        extra_kwargs = {"recurso": {"required": False, "allow_blank": True}}

    def validate(self, data):
        tipo = data["tipo"]
        fecha = data["fecha_solicitada"]
        data["motivo"] = data["motivo"].strip()
        if not data["motivo"]:
            raise serializers.ValidationError({"motivo": "Indica el motivo de la solicitud."})
        if tipo in (Solicitud.Tipo.LABORATORIO, Solicitud.Tipo.EQUIPO):
            if data.get('materia') is not None:
                raise serializers.ValidationError({'materia': 'La materia solo corresponde a justificantes.'})
            data["recurso"] = data.get("recurso", "").strip()
            if not data["recurso"]:
                raise serializers.ValidationError({"recurso": "Selecciona un recurso."})
            catalogo = Recurso.objects.filter(tipo=tipo, nombre__iexact=data['recurso']).first()
            if catalogo is not None and not catalogo.activo:
                raise serializers.ValidationError({'recurso': 'Este recurso se encuentra fuera de servicio.'})
            if catalogo is None and Recurso.objects.filter(tipo=tipo, activo=True).exists():
                raise serializers.ValidationError({'recurso': 'Selecciona un recurso del catálogo disponible.'})
            if fecha < timezone.localdate():
                raise serializers.ValidationError({"fecha_solicitada": "No se permiten reservas en fechas anteriores."})
            inicio, fin = data.get("hora_inicio"), data.get("hora_fin")
            if inicio is None or fin is None or inicio >= fin:
                raise serializers.ValidationError({"horario": "Indica un intervalo de inicio y fin válido."})
        else:
            if data.get("hora_inicio") is not None or data.get("hora_fin") is not None:
                raise serializers.ValidationError({"horario": "Un justificante no utiliza horario de reserva."})
            data["recurso"] = ""
        return data


class SolicitudReviewSerializer(StrictFieldsMixin, serializers.ModelSerializer):
    estado = serializers.ChoiceField(choices=[Solicitud.Estado.APROBADA, Solicitud.Estado.RECHAZADA,
                                                 Solicitud.Estado.DEVUELTA], required=True)

    class Meta:
        model = Solicitud
        fields = ["estado", "observaciones_revision"]

    def validate(self, data):
        estado = data.get("estado")
        if estado is None:
            raise serializers.ValidationError({"estado": "Indica el estado de revisión."})
        if estado == Solicitud.Estado.DEVUELTA:
            if self.instance.tipo != Solicitud.Tipo.EQUIPO or self.instance.estado != Solicitud.Estado.APROBADA:
                raise serializers.ValidationError({"estado": "Solo se devuelve un equipo aprobado."})
            return data
        if self.instance.estado != Solicitud.Estado.PENDIENTE:
            raise serializers.ValidationError({"estado": "Solo se pueden resolver solicitudes pendientes."})
        if estado == Solicitud.Estado.RECHAZADA and not data.get("observaciones_revision", "").strip():
            raise serializers.ValidationError({"observaciones_revision": "Explica el motivo del rechazo."})
        if estado == Solicitud.Estado.APROBADA and self.instance.tipo != Solicitud.Tipo.JUSTIFICANTE:
            s = self.instance
            conflict = Solicitud.objects.filter(
                tipo=s.tipo,
                recurso__iexact=s.recurso,
                fecha_solicitada=s.fecha_solicitada,
                estado=Solicitud.Estado.APROBADA,
                hora_inicio__lt=s.hora_fin,
                hora_fin__gt=s.hora_inicio,
            ).exclude(pk=s.pk)
            if conflict.exists():
                raise serializers.ValidationError({"horario": "Ya existe una reserva aprobada para ese recurso y horario."})
        return data


class SolicitudCancelSerializer(StrictFieldsMixin, serializers.ModelSerializer):
    estado = serializers.ChoiceField(choices=[Solicitud.Estado.CANCELADA], required=True)

    class Meta:
        model = Solicitud
        fields = ["estado"]

    def validate(self, data):
        if self.instance.estado != Solicitud.Estado.PENDIENTE:
            raise serializers.ValidationError({"estado": "Solo puedes cancelar solicitudes pendientes."})
        if "estado" not in data:
            raise serializers.ValidationError({"estado": "Indica cancelada."})
        return data
