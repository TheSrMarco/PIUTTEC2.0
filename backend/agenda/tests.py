from datetime import timedelta

from django.contrib.auth import get_user_model
from django.utils import timezone
from rest_framework.test import APITestCase

from .models import Actividad

User = get_user_model()


class AgendaApiTests(APITestCase):
    def setUp(self):
        self.alumno = User.objects.create_user(username="agenda_a", password="Clave-Prueba1!", role="student")
        self.otro = User.objects.create_user(username="agenda_b", password="Clave-Prueba1!", role="student")
        self.fecha = (timezone.localdate() + timedelta(days=2)).isoformat()
        self.payload = {"titulo": "Entregar práctica", "fecha": self.fecha,
                        "tipo": "tarea", "hora": "14:30", "materia": "DWI"}

    def autenticar(self, usuario):
        self.client.force_authenticate(user=usuario)

    def crear(self, usuario=None, **updates):
        self.autenticar(usuario or self.alumno)
        return self.client.post("/api/agenda/", {**self.payload, **updates}, format="json")

    def test_lista_exige_autenticacion(self):
        self.assertEqual(self.client.get("/api/agenda/").status_code, 401)

    def test_crea_y_asocia_al_usuario(self):
        response = self.crear()
        self.assertEqual(response.status_code, 201, response.data)
        self.assertFalse(response.data["completada"])
        self.assertEqual(Actividad.objects.get(pk=response.data["id"]).usuario, self.alumno)

    def test_el_usuario_no_puede_apropiarse_de_actividad_ajena(self):
        response = self.crear(usuario=self.otro.pk)
        self.assertEqual(response.status_code, 201)
        self.assertEqual(Actividad.objects.get(pk=response.data["id"]).usuario, self.alumno)

    def test_lista_muestra_solo_actividades_propias(self):
        self.crear()
        self.crear(self.otro, titulo="Actividad privada")
        self.autenticar(self.alumno)
        data = self.client.get("/api/agenda/").data
        self.assertEqual(len(data), 1)
        self.assertEqual(data[0]["titulo"], "Entregar práctica")

    def test_usuario_ajeno_no_lee_modifica_ni_elimina(self):
        actividad = self.crear().data["id"]
        self.autenticar(self.otro)
        detail = f"/api/agenda/{actividad}/"
        self.assertEqual(self.client.get(detail).status_code, 404)
        self.assertEqual(self.client.patch(detail, {"completada": True}, format="json").status_code, 404)
        self.assertEqual(self.client.delete(detail).status_code, 404)

    def test_marcar_completada_y_desmarcar(self):
        actividad = self.crear().data["id"]
        detail = f"/api/agenda/{actividad}/"
        self.assertTrue(self.client.patch(detail, {"completada": True}, format="json").data["completada"])
        self.assertFalse(self.client.patch(detail, {"completada": False}, format="json").data["completada"])

    def test_edita_fecha_y_titulo(self):
        actividad = self.crear().data["id"]
        response = self.client.patch(f"/api/agenda/{actividad}/", {"titulo": "Nueva tarea", "hora": None}, format="json")
        self.assertEqual(response.status_code, 200)
        self.assertEqual(response.data["titulo"], "Nueva tarea")
        self.assertIsNone(response.data["hora"])

    def test_puede_eliminar_su_actividad(self):
        actividad = self.crear().data["id"]
        self.assertEqual(self.client.delete(f"/api/agenda/{actividad}/").status_code, 204)
        self.assertFalse(Actividad.objects.filter(pk=actividad).exists())

    def test_titulo_vacio_no_es_valido(self):
        self.assertEqual(self.crear(titulo="   ").status_code, 400)

    def test_fecha_invalida_rechazada(self):
        self.assertEqual(self.crear(fecha="fecha equivocada").status_code, 400)

    def test_tipo_no_valido_rechazado(self):
        self.assertEqual(self.crear(tipo="externo").status_code, 400)

    def test_filtrado_por_fecha_y_tipo(self):
        self.crear()
        self.crear(titulo="Examen", tipo="evaluacion", fecha=(timezone.localdate()+timedelta(days=5)).isoformat())
        self.autenticar(self.alumno)
        r = self.client.get(f"/api/agenda/?desde={self.fecha}&hasta={self.fecha}")
        self.assertEqual(r.status_code, 200)
        self.assertEqual(len(r.data), 1)
        r = self.client.get("/api/agenda/?tipo=evaluacion")
        self.assertEqual(len(r.data), 1)
        self.assertEqual(r.data[0]["titulo"], "Examen")

    def test_filtra_por_completada(self):
        self.crear()
        segunda = self.crear(titulo="Segunda").data["id"]
        self.client.patch(f"/api/agenda/{segunda}/", {"completada": True}, format="json")
        data = self.client.get("/api/agenda/?completada=true").data
        self.assertEqual(len(data), 1)
        self.assertEqual(data[0]["titulo"], "Segunda")

    def test_filtros_incorrectos_responden_400(self):
        self.autenticar(self.alumno)
        self.assertEqual(self.client.get("/api/agenda/?desde=ayer").status_code, 400)
        self.assertEqual(self.client.get("/api/agenda/?completada=quizas").status_code, 400)
        self.assertEqual(self.client.get("/api/agenda/?tipo=otro").status_code, 400)

    def test_metodo_put_no_permitido(self):
        actividad = self.crear().data["id"]
        self.assertEqual(self.client.put(f"/api/agenda/{actividad}/", self.payload, format="json").status_code, 405)
