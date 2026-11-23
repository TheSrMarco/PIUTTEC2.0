"""RF-04. Informe académico personal y comparación agrupada no institucional.

No expone calificaciones ajenas. Solo presenta estadísticas de materias de
otros usuarios si hay al menos cinco participantes distintos en el mismo
nombre de materia y grupo. El grupo lo introducen los usuarios: el dato NO ha
sido verificado contra un padrón institucional.
"""
from collections import defaultdict
from decimal import Decimal, ROUND_HALF_UP

from rest_framework.decorators import api_view, permission_classes
from rest_framework.permissions import IsAuthenticated
from rest_framework.response import Response

from .models import Materia

MIN_PARTICIPANTES = 5
DOS_DECIMALES = Decimal("0.01")


def _clave(value):
    return " ".join(value.strip().casefold().split())


def _nota(value):
    return float(Decimal(value).quantize(DOS_DECIMALES, rounding=ROUND_HALF_UP))


def crear_resumen(usuario):
    materias = list(Materia.objects.filter(usuario=usuario).only(
        "id", "nombre", "grupo", "calificacion", "usuario").order_by("nombre", "id"))
    calificadas = [materia for materia in materias if materia.calificacion is not None]
    promedio = _nota(sum((m.calificacion for m in calificadas), Decimal("0")) / len(calificadas)) \
        if calificadas else None

    # Una agrupación solo se consulta si el usuario ya pertenece a ella
    # mediante una materia propia con nota y grupo declarado.
    claves = {
        (_clave(m.grupo), _clave(m.nombre))
        for m in calificadas if m.grupo.strip() and m.nombre.strip()
    }
    # Cada usuario aporta un solo promedio al grupo, aun cuando registre
    # varias materias con el mismo nombre. Esto evita duplicar su peso.
    aportes = defaultdict(lambda: defaultdict(list))
    if claves:
        for m in Materia.objects.filter(calificacion__isnull=False, usuario__role="student").exclude(grupo="").only(
            "id", "nombre", "grupo", "calificacion", "usuario").iterator():
            clave = (_clave(m.grupo), _clave(m.nombre))
            if clave in claves and Decimal("0") <= m.calificacion <= Decimal("10"):
                aportes[clave][m.usuario_id].append(m.calificacion)

    resultados = []
    for materia in materias:
        nota = _nota(materia.calificacion) if materia.calificacion is not None else None
        estado = "sin_calificacion" if nota is None else "sin_grupo" if not materia.grupo.strip() else "muestra_insuficiente"
        media_grupo = None
        participantes = None
        diferencia = None
        if nota is not None and materia.grupo.strip():
            aportes_usuarios = aportes[(_clave(materia.grupo), _clave(materia.nombre))]
            if len(aportes_usuarios) >= MIN_PARTICIPANTES:
                medias = [sum(valores, Decimal("0")) / len(valores) for valores in aportes_usuarios.values()]
                media_grupo = _nota(sum(medias, Decimal("0")) / len(medias))
                participantes = len(medias)
                diferencia = _nota(Decimal(str(nota)) - Decimal(str(media_grupo)))
                estado = "disponible"
        resultados.append({
            "id": materia.id,
            "nombre": materia.nombre,
            "grupo": materia.grupo,
            "calificacion": nota,
            "promedio_grupal": media_grupo,
            "participantes": participantes,
            "diferencia": diferencia,
            "estado_grupal": estado,
        })

    return {
        "promedio_personal": promedio,
        "materias_evaluadas": len(calificadas),
        "materias_sin_calificar": len(materias) - len(calificadas),
        "materias": resultados,
        "minimo_grupal": MIN_PARTICIPANTES,
        "origen": "calificaciones_registradas_por_usuarios",
        "aviso": (
            "Comparación orientativa: las calificaciones y los grupos son ingresados "
            "por usuarios y no están validados por la institución. "
            "El promedio grupal incluye la calificación propia."
        ),
    }


@api_view(["GET"])
@permission_classes([IsAuthenticated])
def rendimiento(request):
    return Response(crear_resumen(request.user))
