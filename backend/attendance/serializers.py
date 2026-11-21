from django.utils import timezone
from rest_framework import serializers

from .models import Attendance


class DayQuerySerializer(serializers.Serializer):
    date = serializers.DateField()

    def validate_date(self, value):
        if value > timezone.localdate():
            raise serializers.ValidationError("Seleccione una fecha de hoy o anterior.")
        return value


class AttendanceRecordSerializer(serializers.Serializer):
    enrollment_id = serializers.IntegerField(min_value=1)
    status = serializers.ChoiceField(choices=Attendance.Status.choices, allow_null=True)
    note = serializers.CharField(max_length=255, allow_blank=True, default="")
    time_in = serializers.TimeField(allow_null=True, default=None)
    version = serializers.IntegerField(min_value=0)

    def validate(self, attrs):
        if attrs["status"] is None and (attrs["note"] or attrs["time_in"]):
            raise serializers.ValidationError("Una asistencia sin registrar debe tener sus campos vacíos.")
        return attrs


class AttendanceBatchSerializer(DayQuerySerializer):
    records = AttendanceRecordSerializer(many=True, allow_empty=False)

    def validate_records(self, value):
        ids = [record["enrollment_id"] for record in value]
        if len(ids) != len(set(ids)):
            raise serializers.ValidationError("Un estudiante aparece más de una vez en el envío.")
        return value
