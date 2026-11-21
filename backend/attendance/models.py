from django.conf import settings
from django.db import models


class Course(models.Model):
    code = models.CharField("Código", max_length=64, unique=True)
    name = models.CharField("Materia", max_length=200)
    group = models.CharField("Grupo", max_length=80)
    period = models.CharField("Periodo", max_length=80)
    teacher = models.ForeignKey(
        settings.AUTH_USER_MODEL,
        on_delete=models.PROTECT,
        related_name="teaching_courses",
        limit_choices_to={"role": "teacher"},
        verbose_name="Docente",
    )

    class Meta:
        ordering = ["name", "group"]
        verbose_name = "Materia"
        verbose_name_plural = "Materias"

    def __str__(self):
        return f"{self.code} · {self.name} · {self.group}"


class Enrollment(models.Model):
    course = models.ForeignKey(Course, on_delete=models.CASCADE, related_name="enrollments")
    student = models.ForeignKey(
        settings.AUTH_USER_MODEL,
        on_delete=models.PROTECT,
        related_name="enrollments",
        limit_choices_to={"role": "student"},
        verbose_name="Estudiante",
    )

    class Meta:
        constraints = [
            models.UniqueConstraint(fields=["course", "student"], name="unique_course_student")
        ]
        ordering = ["student__last_name", "student__first_name", "student__username"]
        verbose_name = "Inscripción"
        verbose_name_plural = "Inscripciones"

    def __str__(self):
        return f"{self.student} · {self.course}"


class Attendance(models.Model):
    class Status(models.TextChoices):
        PRESENT = "present", "Presente"
        LATE = "late", "Retardo"
        ABSENT = "absent", "Falta"
        JUSTIFIED = "justified", "Justificado"

    enrollment = models.ForeignKey(Enrollment, on_delete=models.CASCADE, related_name="attendance")
    date = models.DateField("Fecha")
    status = models.CharField("Estado", max_length=12, choices=Status.choices, null=True, blank=True)
    note = models.CharField("Observación", max_length=255, blank=True)
    time_in = models.TimeField("Hora de entrada", null=True, blank=True)
    version = models.PositiveIntegerField(default=1)
    recorded_by = models.ForeignKey(
        settings.AUTH_USER_MODEL, on_delete=models.SET_NULL, null=True, editable=False
    )
    updated_at = models.DateTimeField(auto_now=True)

    class Meta:
        constraints = [
            models.UniqueConstraint(fields=["enrollment", "date"], name="unique_enrollment_date")
        ]
        ordering = ["date", "enrollment"]
        verbose_name = "Asistencia"
        verbose_name_plural = "Asistencias"
