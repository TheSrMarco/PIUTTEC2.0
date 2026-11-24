from datetime import timedelta

from django.contrib.auth import get_user_model
from django.utils import timezone
from rest_framework.test import APITestCase

from .models import Solicitud

User = get_user_model()


class SolicitudesApiTests(APITestCase):
    def setUp(self):
        self.alumno = User.objects.create_user(username="alumno", password="Prueba-2026!", role="student")
        self.otro = User.objects.create_user(username="otro", password="Prueba-2026!", role="student")
        self.admin = User.objects.create_user(username="admin_demo", password="Prueba-2026!", role="administrator")
        self.payload = {
            "tipo": "laboratorio", "recurso": "Lab Redes 1",
            "fecha_solicitada": (timezone.localdate() + timedelta(days=7)).isoformat(),
            "hora_inicio": "09:00", "hora_fin": "11:00",
            "motivo": "Práctica de redes",
        }

    def login(self, user):
        self.client.force_authenticate(user=user)

    def crear(self, user=None, **changes):
        self.login(user or self.alumno)
        return self.client.post("/api/solicitudes/", {**self.payload, **changes}, format="json")

    def test_es_obligatorio_autenticarse(self):
        response = self.client.get("/api/solicitudes/")
        self.assertEqual(response.status_code, 401)

    def test_crear_solicitud_pendiente_asocia_usuario(self):
        response = self.crear()
        self.assertEqual(response.status_code, 201, response.data)
        self.assertEqual(response.data["estado"], "pendiente")
        self.assertEqual(Solicitud.objects.get(pk=response.data["id"]).usuario, self.alumno)

    def test_no_se_puede_forzar_usuario_o_estado(self):
        response = self.crear(estado="aprobada", usuario=self.otro.pk)
        self.assertEqual(response.status_code, 400)
        self.assertEqual(Solicitud.objects.count(), 0)

    def test_listado_privado_y_administrador_ve_todo(self):
        self.crear()
        self.crear(self.otro, recurso="Lab 2")
        self.login(self.alumno)
        self.assertEqual(len(self.client.get("/api/solicitudes/").data), 1)
        self.login(self.admin)
        self.assertEqual(len(self.client.get("/api/solicitudes/").data), 2)

    def test_otro_usuario_no_ve_detalle(self):
        identificador = self.crear().data["id"]
        self.login(self.otro)
        self.assertEqual(self.client.get(f"/api/solicitudes/{identificador}/").status_code, 404)

    def test_alumno_no_puede_aprobar(self):
        identificador = self.crear().data["id"]
        self.login(self.alumno)
        response = self.client.patch(f"/api/solicitudes/{identificador}/", {"estado": "aprobada"}, format="json")
        self.assertEqual(response.status_code, 403)

    def test_admin_aprueba_y_registra_revisor(self):
        identificador = self.crear().data["id"]
        self.login(self.admin)
        response = self.client.patch(f"/api/solicitudes/{identificador}/", {"estado": "aprobada"}, format="json")
        self.assertEqual(response.status_code, 200, response.data)
        solicitud = Solicitud.objects.get(pk=identificador)
        self.assertEqual(solicitud.estado, "aprobada")
        self.assertEqual(solicitud.revisado_por, self.admin)

    def test_reservas_aprobadas_no_se_traslapan(self):
        primera = self.crear().data["id"]
        segunda = self.crear(self.otro, hora_inicio="10:00", hora_fin="12:00").data["id"]
        self.login(self.admin)
        self.assertEqual(self.client.patch(f"/api/solicitudes/{primera}/", {"estado": "aprobada"}, format="json").status_code, 200)
        response = self.client.patch(f"/api/solicitudes/{segunda}/", {"estado": "aprobada"}, format="json")
        self.assertEqual(response.status_code, 400)
        self.assertEqual(Solicitud.objects.get(pk=segunda).estado, "pendiente")

    def test_cancelar_pendiente_y_conservar_aprobadas(self):
        identificador = self.crear().data["id"]
        self.login(self.alumno)
        self.assertEqual(self.client.patch(f"/api/solicitudes/{identificador}/", {"estado": "cancelada"}, format="json").status_code, 200)
        self.assertEqual(self.client.delete(f"/api/solicitudes/{identificador}/").status_code, 400)

    def test_fecha_pasada_y_horario_invalido(self):
        pasada = (timezone.localdate() - timedelta(days=1)).isoformat()
        self.assertEqual(self.crear(fecha_solicitada=pasada).status_code, 400)
        self.assertEqual(self.crear(hora_inicio="12:00", hora_fin="11:00").status_code, 400)

    def test_justificante_no_se_autoaprueba(self):
        response = self.crear(tipo="justificante", recurso="", hora_inicio=None, hora_fin=None)
        self.assertEqual(response.status_code, 201, response.data)
        self.assertEqual(response.data["estado"], "pendiente")

    def test_rechazo_requiere_observaciones(self):
        identificador = self.crear().data["id"]
        self.login(self.admin)
        response = self.client.patch(f"/api/solicitudes/{identificador}/", {"estado": "rechazada"}, format="json")
        self.assertEqual(response.status_code, 400)
        response = self.client.patch(f"/api/solicitudes/{identificador}/", {"estado": "rechazada", "observaciones_revision": "Fuera de horario"}, format="json")
        self.assertEqual(response.status_code, 200)

    def test_puede_borrar_su_pendiente_pero_no_otras(self):
        propia = self.crear().data["id"]
        ajena = self.crear(self.otro, recurso="Otro laboratorio").data["id"]
        self.login(self.alumno)
        self.assertEqual(self.client.delete(f"/api/solicitudes/{ajena}/").status_code, 404)
        self.assertEqual(self.client.delete(f"/api/solicitudes/{propia}/").status_code, 204)
        self.assertFalse(Solicitud.objects.filter(pk=propia).exists())

    def test_profesor_sin_rol_admin_no_puede_aprobar_aunque_sea_staff(self):
        docente = User.objects.create_user(username="docente", password="Prueba-2026!", role="teacher", is_staff=True)
        identificador = self.crear(docente, recurso="Laboratorio 3").data["id"]
        self.login(docente)
        self.assertEqual(self.client.patch(f"/api/solicitudes/{identificador}/", {"estado": "aprobada"}, format="json").status_code, 403)
