from django.contrib import admin
from .models import Recurso

@admin.register(Recurso)
class RecursoAdmin(admin.ModelAdmin):
    list_display = ('nombre', 'tipo', 'ubicacion', 'capacidad', 'activo')
    list_filter = ('tipo', 'activo')
    search_fields = ('nombre', 'ubicacion')
