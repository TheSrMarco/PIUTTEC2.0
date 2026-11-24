from django.contrib import admin

from .models import Solicitud


@admin.register(Solicitud)
class SolicitudAdmin(admin.ModelAdmin):
    list_display = ("id", "tipo", "recurso", "usuario", "fecha_solicitada", "estado", "creado_en")
    list_filter = ("tipo", "estado", "fecha_solicitada")
    search_fields = ("recurso", "usuario__username", "motivo")
    readonly_fields = (
        "usuario", "materia", "tipo", "recurso", "fecha_solicitada", "hora_inicio", "hora_fin",
        "motivo", "estado", "observaciones_revision", "revisado_por", "creado_en", "actualizado_en",
    )

    def has_add_permission(self, request):
        return False

    def has_change_permission(self, request, obj=None):
        return False

    def has_delete_permission(self, request, obj=None):
        return False
