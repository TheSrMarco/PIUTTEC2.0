from django.contrib import admin
from .models import Materia, Horario


class HorarioInline(admin.TabularInline):
    model = Horario
    extra = 0


@admin.register(Materia)
class MateriaAdmin(admin.ModelAdmin):
    list_display = ("nombre", "usuario", "docente", "grupo", "calificacion")
    list_filter = ("usuario",)
    search_fields = ("nombre", "docente", "usuario__username")
    inlines = [HorarioInline]


@admin.register(Horario)
class HorarioAdmin(admin.ModelAdmin):
    list_display = ("materia", "dia_semana", "inicio", "fin", "aula")
    list_filter = ("dia_semana",)
