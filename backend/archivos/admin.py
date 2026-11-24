from django.contrib import admin
from .models import Documento

@admin.register(Documento)
class DocumentoAdmin(admin.ModelAdmin):
    list_display = ('nombre', 'usuario', 'materia', 'tamano', 'creado_en')
    search_fields = ('nombre', 'usuario__username', 'materia')
    readonly_fields = ('usuario', 'nombre', 'materia', 'archivo', 'tamano', 'creado_en')
    def has_add_permission(self, request):
        return False
    def has_change_permission(self, request, obj=None):
        return False
