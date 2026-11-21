import getpass
import os

from django.conf import settings
from django.contrib.auth import get_user_model
from django.contrib.auth.password_validation import validate_password
from django.core.exceptions import ValidationError
from django.core.management.base import BaseCommand, CommandError
from django.db import transaction

from attendance.models import Course, Enrollment


class Command(BaseCommand):
    help = "Crea cuentas y materias ficticias para probar el pase de lista en desarrollo."

    @transaction.atomic
    def handle(self, *args, **options):
        if not settings.DEBUG:
            raise CommandError("Este comando requiere el modo de desarrollo.")
        password = os.getenv("PIUTTEC_DEMO_PASSWORD") or getpass.getpass("Contraseña para las cuentas nuevas de prueba: ")
        try:
            validate_password(password)
        except ValidationError as error:
            raise CommandError(" ".join(error.messages)) from error
        User = get_user_model()
        users = {}
        for username, role, first_name in [
            ("docente.demo", "teacher", "Docente de prueba"),
            ("alumno.demo", "student", "Estudiante de prueba"),
            ("alumno2.demo", "student", "Segundo estudiante"),
        ]:
            user, created = User.objects.get_or_create(username=username, defaults={"role": role, "first_name": first_name})
            if user.role != role:
                raise CommandError(f"La cuenta {username} existe con otro rol.")
            if created:
                user.set_password(password)
                user.save()
            users[username] = user
        course, created = Course.objects.get_or_create(
            code="DEMO-REDES-2026",
            defaults={"name": "Fundamentos de redes", "group": "DEMO-1",
                      "period": "2026-3", "teacher": users["docente.demo"]},
        )
        if course.teacher_id != users["docente.demo"].pk:
            raise CommandError("La materia de prueba está asignada a otro docente.")
        for username in ["alumno.demo", "alumno2.demo"]:
            Enrollment.objects.get_or_create(course=course, student=users[username])
        self.stdout.write(self.style.SUCCESS(
            "Cuentas listas: docente.demo, alumno.demo y alumno2.demo. "
            "Las cuentas existentes conservan sus contraseñas. Materia DEMO-REDES-2026."
        ))
