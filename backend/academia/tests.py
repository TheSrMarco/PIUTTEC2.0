from django.contrib.auth import get_user_model
from rest_framework.test import APITestCase
from .models import Materia, Horario

User = get_user_model()


class AcademiaApiTests(APITestCase):
    def setUp(self):
        self.alumno = User.objects.create_user(username="horario_a", password="Clave-Prueba1!", role="student")
        self.otro = User.objects.create_user(username="horario_b", password="Clave-Prueba1!", role="student")
        self.client.force_authenticate(user=self.alumno)
        self.materia = Materia.objects.create(usuario=self.alumno, nombre="Matemáticas", docente="Docente de prueba")
        self.otra_materia = Materia.objects.create(usuario=self.otro, nombre="Materia ajena")
        self.horario = Horario.objects.create(materia=self.materia, dia_semana=1, inicio="09:00", fin="11:00")

    def test_materias_y_horarios_exigen_token(self):
        self.client.force_authenticate(user=None)
        self.assertEqual(self.client.get("/api/materias/").status_code, 401)
        self.assertEqual(self.client.get("/api/horarios/").status_code, 401)

    def test_listar_solo_materias_y_horarios_propios(self):
        Horario.objects.create(materia=self.otra_materia, dia_semana=3, inicio="12:00", fin="14:00")
        materias = self.client.get("/api/materias/")
        horarios = self.client.get("/api/horarios/")
        self.assertEqual(materias.status_code, 200)
        self.assertEqual(horarios.status_code, 200)
        self.assertEqual(len(materias.data), 1)
        self.assertEqual(len(horarios.data), 1)
        self.assertEqual(horarios.data[0]["materia_nombre"], "Matemáticas")

    def test_crear_materia_con_calificacion_valida(self):
        response = self.client.post("/api/materias/", {"nombre":" Química ", "docente":"Docente B", "calificacion":"9.25"}, format="json")
        self.assertEqual(response.status_code, 201, response.data)
        self.assertEqual(response.data["nombre"], "Química")
        self.assertEqual(Materia.objects.get(pk=response.data["id"]).usuario, self.alumno)

    def test_calificacion_fuera_rango(self):
        for nota in ["11.00", "-1.00"]:
            response = self.client.post("/api/materias/", {"nombre":"Química", "calificacion":nota}, format="json")
            self.assertEqual(response.status_code, 400)

    def test_no_admite_titulo_vacio(self):
        self.assertEqual(self.client.post("/api/materias/", {"nombre":"  "}, format="json").status_code, 400)

    def test_no_admite_forzar_usuario(self):
        response = self.client.post("/api/materias/", {"nombre":"Inglés", "usuario": self.otro.pk}, format="json")
        self.assertEqual(response.status_code, 400)

    def test_editar_materia_y_calificacion(self):
        response = self.client.patch(f"/api/materias/{self.materia.pk}/", {"calificacion":"8.90", "grupo":"3A"}, format="json")
        self.assertEqual(response.status_code, 200, response.data)
        self.materia.refresh_from_db()
        self.assertEqual(str(self.materia.calificacion), "8.90")
        self.assertEqual(self.materia.grupo, "3A")

    def test_crear_horario_valido(self):
        response = self.client.post("/api/horarios/", {"materia": self.materia.pk, "dia_semana":2, "inicio":"08:00", "fin":"10:00", "aula":"B-04"}, format="json")
        self.assertEqual(response.status_code, 201, response.data)
        self.assertEqual(Horario.objects.get(pk=response.data["id"]).materia, self.materia)

    def test_no_permite_materia_ajena_en_horario(self):
        response = self.client.post("/api/horarios/", {"materia": self.otra_materia.pk, "dia_semana":2, "inicio":"08:00", "fin":"09:00"}, format="json")
        self.assertEqual(response.status_code, 400)

    def test_no_permite_hora_fin_anterior(self):
        response = self.client.post("/api/horarios/", {"materia": self.materia.pk, "dia_semana":2, "inicio":"11:00", "fin":"09:00"}, format="json")
        self.assertEqual(response.status_code, 400)

    def test_detecta_traslapes_entre_materias(self):
        otra = Materia.objects.create(usuario=self.alumno, nombre="Física")
        response = self.client.post("/api/horarios/", {"materia":otra.pk,"dia_semana":1,"inicio":"10:00","fin":"12:00"},format="json")
        self.assertEqual(response.status_code, 400)

    def test_horarios_contiguos_validos(self):
        otra = Materia.objects.create(usuario=self.alumno, nombre="Física")
        response = self.client.post("/api/horarios/", {"materia":otra.pk,"dia_semana":1,"inicio":"11:00","fin":"13:00"},format="json")
        self.assertEqual(response.status_code, 201, response.data)

    def test_actualizacion_horario_valida_sin_autoconflicto(self):
        response = self.client.patch(f"/api/horarios/{self.horario.pk}/", {"inicio":"08:30", "fin":"10:30"}, format="json")
        self.assertEqual(response.status_code, 200, response.data)

    def test_actualizacion_horario_conflictiva(self):
        segunda = Horario.objects.create(materia=self.materia, dia_semana=1, inicio="11:00", fin="12:00")
        response = self.client.patch(f"/api/horarios/{segunda.pk}/", {"inicio":"10:30"}, format="json")
        self.assertEqual(response.status_code, 400)

    def test_otro_usuario_no_lee_ni_edita_ni_elimina(self):
        self.client.force_authenticate(user=self.otro)
        for route in [f"/api/materias/{self.materia.pk}/", f"/api/horarios/{self.horario.pk}/"]:
            self.assertEqual(self.client.get(route).status_code, 404)
            self.assertEqual(self.client.patch(route, {"aula":"X"},format="json").status_code, 404)
            self.assertEqual(self.client.delete(route).status_code, 404)

    def test_eliminar_materia_borra_sus_horarios(self):
        self.assertEqual(self.client.delete(f"/api/materias/{self.materia.pk}/").status_code, 204)
        self.assertFalse(Horario.objects.filter(pk=self.horario.pk).exists())

    def test_eliminar_horario_mantiene_materia(self):
        self.assertEqual(self.client.delete(f"/api/horarios/{self.horario.pk}/").status_code, 204)
        self.assertTrue(Materia.objects.filter(pk=self.materia.pk).exists())

    def test_dia_semana_fuera_de_rango(self):
        response = self.client.post("/api/horarios/", {"materia":self.materia.pk,"dia_semana":8,"inicio":"12:00","fin":"13:00"},format="json")
        self.assertEqual(response.status_code, 400)

    def test_filtrar_horarios_por_materia(self):
        segunda = Materia.objects.create(usuario=self.alumno, nombre="Literatura")
        Horario.objects.create(materia=segunda, dia_semana=4, inicio="10:00", fin="11:00")
        response = self.client.get(f"/api/horarios/?materia={self.materia.pk}")
        self.assertEqual(response.status_code, 200)
        self.assertEqual(len(response.data), 1)

    def test_metodo_put_no_permitido(self):
        self.assertEqual(self.client.put(f"/api/materias/{self.materia.pk}/", {"nombre":"X"},format="json").status_code, 405)
