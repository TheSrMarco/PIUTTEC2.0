from django.contrib import admin
from .models import Asistencia


@admin.register(Asistencia)
class AsistenciaAdmin(admin.ModelAdmin):
    list_display = ("usuario", "materia", "fecha", "estado", "actualizado_en")
    list_filter = ("estado", "fecha")
    search_fields = ("usuario__username", "materia__nombre")
