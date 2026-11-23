"""Asistencias: autenticación, aislamiento, edición y métricas del panel."""
from datetime import timedelta
from django.contrib.auth import get_user_model
from django.utils import timezone
from rest_framework.test import APITestCase
from academia.models import Materia
from .models import Asistencia

User = get_user_model()
URL = "/api/asistencias/"


class AsistenciasApiTests(APITestCase):
    def setUp(self):
        self.usuario = User.objects.create_user(username="rf05_a", password="ClaveRF05!123", role="student")
        self.ajeno = User.objects.create_user(username="rf05_b", password="ClaveRF05!123", role="student")
        self.materia = Materia.objects.create(usuario=self.usuario, nombre="Biología")
        self.otra = Materia.objects.create(usuario=self.ajeno, nombre="Física")
        self.hoy = timezone.localdate().isoformat()
        self.client.force_authenticate(user=self.usuario)

    def nuevo(self, materia=None, estado="P", fecha=None):
        return self.client.post(URL, {"materia": materia or self.materia.pk,
            "fecha": fecha or self.hoy, "estado": estado}, format="json")

    def test_necesita_jwt(self):
        self.client.force_authenticate(user=None)
        self.assertEqual(self.client.get(URL).status_code, 401)
        self.assertEqual(self.client.post(URL, {}, format="json").status_code, 401)

    def test_crear_listar_y_filtrar(self):
        response = self.nuevo(estado="R")
        self.assertEqual(response.status_code, 201, response.data)
        self.assertEqual(response.data["materia_nombre"], "Biología")
        self.assertEqual(len(self.client.get(URL).data), 1)
        self.assertEqual(len(self.client.get(f"{URL}?fecha={self.hoy}").data), 1)
        self.assertEqual(len(self.client.get(f"{URL}?materia={self.materia.pk}").data), 1)
        self.assertEqual(len(self.client.get(f"{URL}?materia={self.otra.pk}").data), 0)

    def test_no_permita_materia_ajena(self):
        self.assertEqual(self.nuevo(materia=self.otra.pk).status_code, 400)

    def test_no_permite_forzar_usuario(self):
        response = self.client.post(URL, {"usuario": self.ajeno.pk, "materia": self.materia.pk,
            "fecha": self.hoy, "estado": "P"}, format="json")
        self.assertEqual(response.status_code, 400)
        self.assertEqual(Asistencia.objects.count(), 0)

    def test_no_duplica_materia_y_fecha(self):
        self.assertEqual(self.nuevo().status_code, 201)
        self.assertEqual(self.nuevo(estado="F").status_code, 400)
        self.assertEqual(Asistencia.objects.count(), 1)

    def test_actualizar_y_eliminar_registro_propio(self):
        pk = self.nuevo().data["id"]
        resp = self.client.patch(f"{URL}{pk}/", {"estado": "J"}, format="json")
        self.assertEqual(resp.status_code, 200, resp.data)
        self.assertEqual(Asistencia.objects.get(pk=pk).estado, "J")
        self.assertEqual(self.client.delete(f"{URL}{pk}/").status_code, 204)
        self.assertEqual(Asistencia.objects.count(), 0)

    def test_ajeno_no_se_puede_leer_cambiar_ni_borrar(self):
        ajena = Asistencia.objects.create(usuario=self.ajeno, materia=self.otra,
            fecha=timezone.localdate(), estado="F")
        self.assertEqual(len(self.client.get(URL).data), 0)
        self.assertEqual(self.client.get(f"{URL}{ajena.pk}/").status_code, 404)
        self.assertEqual(self.client.patch(f"{URL}{ajena.pk}/", {"estado": "P"}, format="json").status_code, 404)
        self.assertEqual(self.client.delete(f"{URL}{ajena.pk}/").status_code, 404)

    def test_rechaza_estado_fecha_futura_y_filtros_erroneos(self):
        self.assertEqual(self.nuevo(estado="X").status_code, 400)
        futuro = (timezone.localdate() + timedelta(days=1)).isoformat()
        self.assertEqual(self.nuevo(fecha=futuro).status_code, 400)
        self.assertEqual(self.client.get(f"{URL}?fecha=ayer").status_code, 400)
        self.assertEqual(self.client.get(f"{URL}?materia=abc").status_code, 400)

    def test_marca_todas_en_una_transaccion_y_permite_corregirlas(self):
        extra = Materia.objects.create(usuario=self.usuario, nombre="Química")
        self.assertEqual(self.nuevo(estado="F").status_code, 201)
        datos = {"fecha": self.hoy, "materias": [self.materia.pk, extra.pk]}
        response = self.client.post(f"{URL}marcar-todas/", datos, format="json")
        self.assertEqual(response.status_code, 200, response.data)
        self.assertEqual(response.data["actualizadas"], 2)
        self.assertEqual(Asistencia.objects.filter(usuario=self.usuario, estado="P").count(), 2)
        self.assertEqual(Asistencia.objects.count(), 2)

    def test_marcacion_masiva_rechaza_ajenos_sin_cambios_parciales(self):
        response = self.client.post(f"{URL}marcar-todas/",
            {"fecha": self.hoy, "materias": [self.materia.pk, self.otra.pk]}, format="json")
        self.assertEqual(response.status_code, 400)
        self.assertEqual(Asistencia.objects.count(), 0)

    def test_marcacion_masiva_rechaza_duplicados_y_fecha_futura(self):
        duplicated = {"fecha": self.hoy, "materias": [self.materia.pk, self.materia.pk]}
        self.assertEqual(self.client.post(f"{URL}marcar-todas/", duplicated, format="json").status_code, 400)
        futuro = (timezone.localdate() + timedelta(days=1)).isoformat()
        self.assertEqual(self.client.post(f"{URL}marcar-todas/",
            {"fecha": futuro, "materias": [self.materia.pk]}, format="json").status_code, 400)

    def test_dashboard_no_suma_asistencias_ajenas(self):
        Asistencia.objects.create(usuario=self.ajeno, materia=self.otra,
            fecha=timezone.localdate(), estado="F")
        data = self.client.get("/api/dashboard/resumen/").data
        self.assertIsNone(data["attendance"])
        self.assertEqual(data["attendance_records"], 0)

    def test_dashboard_calcula_porcentaje_sin_fingir_asistencia(self):
        self.assertEqual(self.nuevo(estado="P").status_code, 201)
        # Tres estados: P, J y F -> 2 de 3, redondeo habitual a 67 %.
        extra = Materia.objects.create(usuario=self.usuario, nombre="Química")
        ultimo = Materia.objects.create(usuario=self.usuario, nombre="Inglés")
        Asistencia.objects.create(usuario=self.usuario, materia=extra,
            fecha=timezone.localdate(), estado="J")
        Asistencia.objects.create(usuario=self.usuario, materia=ultimo,
            fecha=timezone.localdate(), estado="F")
        data = self.client.get("/api/dashboard/resumen/").data
        self.assertEqual(data["attendance"], 67)
        self.assertEqual(data["attendance_records"], 3)
        self.assertNotIn("attendance", data["unavailable"])
