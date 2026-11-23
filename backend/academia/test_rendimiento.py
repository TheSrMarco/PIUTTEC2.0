from decimal import Decimal
from django.contrib.auth import get_user_model
from rest_framework.test import APITestCase
from .models import Materia

User = get_user_model()


class RendimientoTests(APITestCase):
    def setUp(self):
        self.alumno = User.objects.create_user(username="alumno_rf04", password="Prueba123456!")
        self.client.force_authenticate(user=self.alumno)

    def crear(self, user, nombre, grupo, calificacion):
        return Materia.objects.create(usuario=user, nombre=nombre, grupo=grupo,
                                     calificacion=calificacion)

    def test_requiere_autenticacion(self):
        self.client.force_authenticate(user=None)
        self.assertEqual(self.client.get("/api/rendimiento/").status_code, 401)

    def test_sin_materias_no_inventa_promedio(self):
        r = self.client.get("/api/rendimiento/")
        self.assertEqual(r.status_code, 200)
        self.assertIsNone(r.data["promedio_personal"])
        self.assertEqual(r.data["materias"], [])

    def test_promedio_personal_sin_notas_nulas(self):
        self.crear(self.alumno, "Álgebra", "5A", Decimal("8.50"))
        self.crear(self.alumno, "Biología", "5A", Decimal("9.50"))
        self.crear(self.alumno, "Química", "5A", None)
        r = self.client.get("/api/rendimiento/")
        self.assertEqual(r.data["promedio_personal"], 9.0)
        self.assertEqual(r.data["materias_evaluadas"], 2)
        self.assertEqual(r.data["materias_sin_calificar"], 1)
        self.assertEqual(
            {m["nombre"]: m["estado_grupal"] for m in r.data["materias"]},
            {"Álgebra": "muestra_insuficiente", "Biología": "muestra_insuficiente",
             "Química": "sin_calificacion"},
        )

    def test_cuatro_participantes_no_muestra_promedio_ni_tamano(self):
        self.crear(self.alumno, "Redes", "3B", Decimal("8.00"))
        for i in range(3):
            user = User.objects.create_user(username=f"par{i}")
            self.crear(user, "Redes", "3B", Decimal("9.00"))
        materia = self.client.get("/api/rendimiento/").data["materias"][0]
        self.assertEqual(materia["estado_grupal"], "muestra_insuficiente")
        self.assertIsNone(materia["promedio_grupal"])
        self.assertIsNone(materia["participantes"])

    def test_cinco_participantes_calculan_media_y_diferencia(self):
        self.crear(self.alumno, "Redes", "3B", Decimal("8.00"))
        for i, nota in enumerate([7, 9, 9, 10]):
            user = User.objects.create_user(username=f"grupo{i}")
            self.crear(user, "Redes", "3B", Decimal(str(nota)))
        r = self.client.get("/api/rendimiento/")
        registro = r.data["materias"][0]
        self.assertEqual(registro["promedio_grupal"], 8.6)
        self.assertEqual(registro["diferencia"], -0.6)
        self.assertEqual(registro["participantes"], 5)
        self.assertEqual(registro["estado_grupal"], "disponible")

    def test_distintos_grupos_y_materias_no_se_mezclan(self):
        self.crear(self.alumno, "Química", "3B", Decimal("9"))
        for i in range(4):
            u = User.objects.create_user(username=f"same{i}")
            self.crear(u, "Química", "3C", Decimal("0"))
            self.crear(u, "Historia", "3B", Decimal("0"))
        registro = self.client.get("/api/rendimiento/").data["materias"][0]
        self.assertIsNone(registro["promedio_grupal"])

    def test_normaliza_mayusculas_y_espacios(self):
        self.crear(self.alumno, "Base de Datos", "3a", Decimal("9.00"))
        for i in range(4):
            u = User.objects.create_user(username=f"norm{i}")
            self.crear(u, "  BASE   DE DATOS ", " 3A ", Decimal("8.00"))
        registro = self.client.get("/api/rendimiento/").data["materias"][0]
        self.assertEqual(registro["promedio_grupal"], 8.2)

    def test_varias_notas_del_mismo_usuario_cuentan_una_sola_vez(self):
        self.crear(self.alumno, "Redes", "3B", Decimal("10"))
        for i in range(3):
            u = User.objects.create_user(username=f"solo{i}")
            self.crear(u, "Redes", "3B", Decimal("10"))
        usuario = User.objects.get(username="solo0")
        self.crear(usuario, "Redes", "3B", Decimal("0"))
        registro = self.client.get("/api/rendimiento/").data["materias"][0]
        self.assertIsNone(registro["promedio_grupal"])

    def test_no_expone_materias_ajenas_en_listado(self):
        self.crear(self.alumno, "Matemáticas", "4A", Decimal("8"))
        otra = User.objects.create_user(username="otro")
        self.crear(otra, "Materia secreta", "7Z", Decimal("10"))
        payload = self.client.get("/api/rendimiento/").data
        self.assertEqual(len(payload["materias"]), 1)
        self.assertEqual(payload["materias"][0]["nombre"], "Matemáticas")

    def test_calificacion_ausente_y_grupo_vacio(self):
        self.crear(self.alumno, "Física", "", Decimal("9"))
        self.crear(self.alumno, "Química", "7A", None)
        registros = {m["nombre"]: m for m in self.client.get("/api/rendimiento/").data["materias"]}
        self.assertEqual(registros["Física"]["estado_grupal"], "sin_grupo")
        self.assertEqual(registros["Química"]["estado_grupal"], "sin_calificacion")

    def test_usuarios_docentes_no_cuentan_como_estudiantes(self):
        self.crear(self.alumno, "Redes", "3B", Decimal("8"))
        for i in range(3):
            student = User.objects.create_user(username=f"stu{i}", role="student")
            self.crear(student, "Redes", "3B", Decimal("9"))
        teacher = User.objects.create_user(username="docente", role="teacher")
        self.crear(teacher, "Redes", "3B", Decimal("9"))
        registro = self.client.get("/api/rendimiento/").data["materias"][0]
        self.assertIsNone(registro["promedio_grupal"])
