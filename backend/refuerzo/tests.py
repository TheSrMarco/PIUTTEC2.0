from django.contrib.auth import get_user_model
from rest_framework.test import APITestCase
from .models import IntentoRefuerzo

User = get_user_model()


class ProgresoRefuerzoTests(APITestCase):
    def setUp(self):
        self.alumno = User.objects.create_user(username='quiz_a', password='Prueba2026!')
        self.otro = User.objects.create_user(username='quiz_b', password='Prueba2026!')
        self.url = '/api/refuerzo/intentos/'
        self.payload = {'tema': 'Redes', 'aciertos': 3, 'total': 3}

    def test_requiere_sesion(self):
        self.assertEqual(self.client.get(self.url).status_code, 401)
        self.assertEqual(self.client.post(self.url, self.payload, format='json').status_code, 401)

    def test_historial_resumen_y_logros(self):
        self.client.force_authenticate(user=self.alumno)
        response = self.client.post(self.url, self.payload, format='json')
        self.assertEqual(response.status_code, 201, response.data)
        summary = self.client.get(self.url + 'resumen/').data
        self.assertEqual(summary['intentos'], 1)
        self.assertEqual(summary['mejor_porcentaje'], 100)
        self.assertIn('Puntuación perfecta', summary['logros'])

    def test_datos_aislados_y_sin_falsificacion_de_usuario(self):
        IntentoRefuerzo.objects.create(usuario=self.otro, tema='Otro tema', aciertos=1, total=3)
        self.client.force_authenticate(user=self.alumno)
        self.assertEqual(self.client.get(self.url).data, [])
        self.assertEqual(self.client.post(self.url, {**self.payload, 'usuario': self.otro.pk}, format='json').status_code, 400)
        self.assertEqual(IntentoRefuerzo.objects.filter(usuario=self.alumno).count(), 0)

    def test_nota_no_supera_total(self):
        self.client.force_authenticate(user=self.alumno)
        self.assertEqual(self.client.post(self.url, {**self.payload, 'aciertos': 4}, format='json').status_code, 400)
        self.assertEqual(self.client.post(self.url, {**self.payload, 'total': 0}, format='json').status_code, 400)
