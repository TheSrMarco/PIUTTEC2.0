from django.contrib import admin

from .models import Attendance, Course, Enrollment


class EnrollmentInline(admin.TabularInline):
    model = Enrollment
    extra = 0
    autocomplete_fields = ["student"]


@admin.register(Course)
class CourseAdmin(admin.ModelAdmin):
    list_display = ["code", "name", "group", "period", "teacher"]
    search_fields = ["code", "name", "group"]
    list_filter = ["period"]
    autocomplete_fields = ["teacher"]
    inlines = [EnrollmentInline]


@admin.register(Attendance)
class AttendanceAdmin(admin.ModelAdmin):
    list_display = ["enrollment", "date", "status", "note"]
    list_filter = ["date", "status", "enrollment__course"]
    readonly_fields = ["enrollment", "date", "status", "note", "time_in", "version", "recorded_by", "updated_at"]

    def has_add_permission(self, request):
        return False

    def has_delete_permission(self, request, obj=None):
        return False
