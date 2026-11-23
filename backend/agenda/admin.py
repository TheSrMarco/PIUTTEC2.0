from django.contrib import admin
from .models import Actividad


@admin.register(Actividad)
class ActividadAdmin(admin.ModelAdmin):
    list_display = ("titulo", "usuario", "fecha", "tipo", "completada")
    search_fields = ("titulo", "usuario__username", "materia")
    list_filter = ("tipo", "completada", "fecha")
