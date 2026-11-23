from django.contrib import admin
from .models import IntentoRefuerzo

@admin.register(IntentoRefuerzo)
class IntentoRefuerzoAdmin(admin.ModelAdmin):
    list_display = ('usuario', 'tema', 'aciertos', 'total', 'creado_en')
    list_filter = ('tema',)
    readonly_fields = ('usuario', 'tema', 'carrera', 'cuatrimestre', 'parcial', 'aciertos', 'total', 'creado_en')
    def has_add_permission(self, request): return False
    def has_change_permission(self, request, obj=None): return False
