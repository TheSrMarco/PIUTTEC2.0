"""RF-01. Resumen privado de práctica construido a partir de datos persistentes.

No se atribuyen los registros a una fuente escolar oficial.
"""
from datetime import date
from decimal import Decimal, ROUND_HALF_UP

from django.db.models import Avg
from django.utils import timezone
from rest_framework.decorators import api_view, permission_classes
from rest_framework.permissions import IsAuthenticated
from rest_framework.response import Response

from academia.models import Horario, Materia
from asistencias.models import Asistencia
from agenda.models import Actividad
from archivos.models import Documento
from solicitudes.models import Solicitud


def construir_resumen(usuario, hoy: date | None = None):
    hoy = hoy or timezone.localdate()
    materias = Materia.objects.filter(usuario=usuario)
    actividades = Actividad.objects.filter(usuario=usuario)
    solicitudes = Solicitud.objects.filter(usuario=usuario)
    conteos = {clave: 0 for clave in Asistencia.Estado.values}
    for estado in Asistencia.objects.filter(usuario=usuario).values_list("estado", flat=True):
        conteos[estado] += 1
    total_asistencias = sum(conteos.values())
    equivalentes = conteos["P"] + conteos["J"] + conteos["R"] - conteos["R"] // 3
    porcentaje_asistencia = (
        int((Decimal(100 * equivalentes) / Decimal(total_asistencias)).quantize(Decimal("1"), rounding=ROUND_HALF_UP))
        if total_asistencias else None
    )

    promedio = materias.aggregate(media=Avg("calificacion"))["media"]
    promedio = (
        float(Decimal(promedio).quantize(Decimal("0.01"), rounding=ROUND_HALF_UP))
        if promedio is not None else None
    )
    pendientes = actividades.filter(
        completada=False, tipo__in=[Actividad.Tipo.TAREA, Actividad.Tipo.EVALUACION]
    )
    completadas = actividades.filter(
        completada=True, tipo__in=[Actividad.Tipo.TAREA, Actividad.Tipo.EVALUACION]
    )
    proximas = actividades.filter(completada=False, fecha__gte=hoy).order_by(
        "fecha", "hora", "id"
    )[:5]
    return {
        "source": "django",
        "average": promedio,
        "attendance": porcentaje_asistencia,  # Registros personales de práctica (no oficiales).
        "attendance_records": total_asistencias,
        "subject_count": materias.count(),
        "graded_subjects": materias.filter(calificacion__isnull=False).count(),
        "pending_tasks": pendientes.count(),
        "completed_tasks": completadas.count(),
        "pending_requests": solicitudes.filter(estado=Solicitud.Estado.PENDIENTE).count(),
        "approved_requests": solicitudes.filter(estado=Solicitud.Estado.APROBADA).count(),
        "weekly_classes": Horario.objects.filter(materia__usuario=usuario).count(),
        "file_count": Documento.objects.filter(usuario=usuario).count(),
        "subjects": [
            {
                "id": materia.id,
                "name": materia.nombre,
                "grade": float(materia.calificacion) if materia.calificacion is not None else None,
                "group": materia.grupo,
            }
            for materia in materias.order_by("nombre", "id")
        ],
        "upcoming": [
            {
                "id": actividad.id,
                "title": actividad.titulo,
                "date": actividad.fecha.isoformat(),
                "type": actividad.tipo,
                "subject": actividad.materia,
            }
            for actividad in proximas
        ],
        "unavailable": [] if total_asistencias else ["attendance"],
    }


@api_view(["GET"])
@permission_classes([IsAuthenticated])
def resumen_dashboard(request):
    return Response(construir_resumen(request.user))
