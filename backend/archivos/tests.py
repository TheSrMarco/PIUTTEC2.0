import tempfile
from django.contrib.auth import get_user_model
from django.core.files.uploadedfile import SimpleUploadedFile
from django.test import override_settings
from rest_framework.test import APITestCase
from .models import Documento

User = get_user_model()


class ArchivosApiTests(APITestCase):
    @classmethod
    def setUpClass(cls):
        cls._directory = tempfile.TemporaryDirectory()
        cls._media = override_settings(MEDIA_ROOT=cls._directory.name)
        cls._media.enable()
        super().setUpClass()

    @classmethod
    def tearDownClass(cls):
        super().tearDownClass()
        cls._media.disable()
        cls._directory.cleanup()

    def setUp(self):
        self.alumno = User.objects.create_user(username='file_a', password='Prueba2026!')
        self.otro = User.objects.create_user(username='file_b', password='Prueba2026!')

    def _subir(self, contenido=b'reporte de ejemplo', name='reporte.txt'):
        self.client.force_authenticate(user=self.alumno)
        return self.client.post('/api/archivos/', {'archivo': SimpleUploadedFile(name, contenido),
          'materia': 'Inglés'}, format='multipart')

    def test_solo_usuarios_autenticados_pueden_subir_o_listar(self):
        self.assertEqual(self.client.get('/api/archivos/').status_code, 401)
        self.assertEqual(self.client.post('/api/archivos/', {}).status_code, 401)

    def test_subir_listar_descargar_y_borrar(self):
        response = self._subir()
        self.assertEqual(response.status_code, 201, response.data)
        id_ = response.data['id']
        self.assertEqual(self.client.get('/api/archivos/').data[0]['nombre'], 'reporte.txt')
        file_response = self.client.get(f'/api/archivos/{id_}/descargar/')
        self.assertEqual(file_response.status_code, 200)
        self.assertEqual(b''.join(file_response.streaming_content), b'reporte de ejemplo')
        self.assertEqual(self.client.delete(f'/api/archivos/{id_}/').status_code, 204)
        self.assertFalse(Documento.objects.filter(pk=id_).exists())

    def test_aislamiento_por_cuenta(self):
        id_ = self._subir().data['id']
        self.client.force_authenticate(user=self.otro)
        self.assertEqual(len(self.client.get('/api/archivos/').data), 0)
        self.assertEqual(self.client.get(f'/api/archivos/{id_}/descargar/').status_code, 404)
        self.assertEqual(self.client.delete(f'/api/archivos/{id_}/').status_code, 404)

    def test_extension_y_limite_de_tamano(self):
        self.assertEqual(self._subir(name='script.exe').status_code, 400)
        self.assertEqual(self._subir(contenido=b'a' * (10 * 1024 * 1024 + 1)).status_code, 400)
