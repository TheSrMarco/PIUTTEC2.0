"""Pruebas RF-01: autenticación, cálculos reales y aislamiento por cuenta."""
from datetime import time, timedelta
from decimal import Decimal

from django.contrib.auth import get_user_model
from django.utils import timezone
from rest_framework.test import APITestCase

from academia.models import Horario, Materia
from agenda.models import Actividad
from solicitudes.models import Solicitud

User = get_user_model()
URL = "/api/dashboard/resumen/"


class ResumenDashboardTests(APITestCase):
    def setUp(self):
        self.alumno = User.objects.create_user(username="rf01_alumno", password="Prueba123456!", role="student")
        self.otro = User.objects.create_user(username="rf01_otro", password="Prueba123456!", role="student")
        self.client.force_authenticate(user=self.alumno)
        self.hoy = timezone.localdate()

    def materia(self, usuario, nombre, calificacion=None):
        return Materia.objects.create(usuario=usuario, nombre=nombre, grupo="3A", calificacion=calificacion)

    def actividad(self, usuario, titulo, tipo="tarea", completada=False, dias=1):
        return Actividad.objects.create(usuario=usuario, titulo=titulo, tipo=tipo,
            completada=completada, fecha=self.hoy + timedelta(days=dias))

    def solicitud(self, usuario, estado="pendiente"):
        return Solicitud.objects.create(usuario=usuario, tipo="justificante", fecha_solicitada=self.hoy,
            motivo="Motivo de prueba", estado=estado)

    def test_exige_autenticacion(self):
        self.client.force_authenticate(user=None)
        self.assertEqual(self.client.get(URL).status_code, 401)

    def test_usuario_sin_registros_no_recibe_cifras_inventadas(self):
        response = self.client.get(URL)
        self.assertEqual(response.status_code, 200)
        data = response.data
        self.assertIsNone(data["average"])
        self.assertIsNone(data["attendance"])
        self.assertEqual(data["file_count"], 0)
        self.assertEqual(data["subject_count"], 0)
        self.assertEqual(data["pending_tasks"], 0)
        self.assertEqual(data["weekly_classes"], 0)
        self.assertEqual(data["subjects"], [])
        self.assertEqual(data["upcoming"], [])

    def test_promedio_excluye_materias_sin_calificacion(self):
        self.materia(self.alumno, "Bases de Datos", Decimal("8.50"))
        self.materia(self.alumno, "Programación", Decimal("9.50"))
        self.materia(self.alumno, "Redes", None)
        data = self.client.get(URL).data
        self.assertEqual(data["average"], 9.0)
        self.assertEqual(data["graded_subjects"], 2)
        self.assertEqual(data["subject_count"], 3)
        self.assertIsNone(next(m["grade"] for m in data["subjects"] if m["name"] == "Redes"))

    def test_estados_de_agenda_y_solicitudes_no_se_mezclan(self):
        self.actividad(self.alumno, "Pendiente")
        self.actividad(self.alumno, "Evaluación", tipo="evaluacion")
        self.actividad(self.alumno, "Finalizada", completada=True)
        self.actividad(self.alumno, "Evento", tipo="evento")
        self.solicitud(self.alumno, "pendiente")
        self.solicitud(self.alumno, "aprobada")
        self.solicitud(self.alumno, "rechazada")
        data = self.client.get(URL).data
        self.assertEqual(data["pending_tasks"], 2)
        self.assertEqual(data["completed_tasks"], 1)
        self.assertEqual(data["pending_requests"], 1)
        self.assertEqual(data["approved_requests"], 1)
        self.assertEqual(len(data["upcoming"]), 3)

    def test_cuenta_solo_clases_del_usuario(self):
        propia = self.materia(self.alumno, "Cálculo")
        ajena = self.materia(self.otro, "Física")
        Horario.objects.create(materia=propia, dia_semana=1, inicio=time(8), fin=time(9))
        Horario.objects.create(materia=ajena, dia_semana=2, inicio=time(8), fin=time(9))
        self.assertEqual(self.client.get(URL).data["weekly_classes"], 1)

    def test_no_revela_registros_de_otros_usuarios(self):
        self.materia(self.otro, "Materia secreta", Decimal("10"))
        self.actividad(self.otro, "Tarea ajena")
        self.solicitud(self.otro)
        data = self.client.get(URL).data
        self.assertEqual(data["subject_count"], 0)
        self.assertIsNone(data["average"])
        self.assertEqual(data["pending_tasks"], 0)
        self.assertEqual(data["pending_requests"], 0)
        self.assertEqual(data["subjects"], [])

    def test_proximas_actividades_en_orden_y_limite_cinco(self):
        self.actividad(self.alumno, "Pasada", dias=-2)
        for index in range(8):
            self.actividad(self.alumno, f"Actividad {index}", dias=8 - index)
        data = self.client.get(URL).data
        self.assertEqual(len(data["upcoming"]), 5)
        self.assertEqual(data["upcoming"][0]["title"], "Actividad 7")
        self.assertNotIn("Pasada", [item["title"] for item in data["upcoming"]])

    def test_requiere_metodo_get(self):
        self.assertEqual(self.client.post(URL, {}, format="json").status_code, 405)
