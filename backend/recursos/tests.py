from datetime import timedelta
from django.contrib.auth import get_user_model
from django.utils import timezone
from rest_framework.test import APITestCase
from solicitudes.models import Solicitud
from .models import Recurso

User = get_user_model()


class CatalogoTests(APITestCase):
    def setUp(self):
        self.alumno = User.objects.create_user(username='rec_alumno', password='Prueba2026!', role='student')
        self.admin = User.objects.create_user(username='rec_admin', password='Prueba2026!', role='administrator')
        self.recurso = Recurso.objects.create(tipo='laboratorio', nombre='Lab Software', ubicacion='TIC', activo=True)

    def test_requiere_autenticacion(self):
        self.assertEqual(self.client.get('/api/recursos/').status_code, 401)

    def test_alumno_consulta_pero_no_edita_catalogo(self):
        self.client.force_authenticate(user=self.alumno)
        self.assertEqual(len(self.client.get('/api/recursos/').data), 1)
        self.assertEqual(self.client.post('/api/recursos/', {'tipo': 'equipo', 'nombre': 'Laptop'}, format='json').status_code, 403)
        self.assertEqual(self.client.patch(f'/api/recursos/{self.recurso.pk}/', {'nombre': 'Otro'}, format='json').status_code, 403)
        self.assertEqual(self.client.delete(f'/api/recursos/{self.recurso.pk}/').status_code, 403)

    def test_admin_agrega_y_desactiva_sin_borrar_historico(self):
        self.client.force_authenticate(user=self.admin)
        created = self.client.post('/api/recursos/', {'tipo': 'equipo', 'nombre': 'Proyector'}, format='json')
        self.assertEqual(created.status_code, 201, created.data)
        self.assertEqual(self.client.delete(f'/api/recursos/{created.data["id"]}/').status_code, 204)
        self.assertFalse(Recurso.objects.get(pk=created.data['id']).activo)
        self.client.force_authenticate(user=self.alumno)
        self.assertEqual(len(self.client.get('/api/recursos/').data), 1)

    def test_disponibilidad_reconoce_reserva_aprobada(self):
        dia = timezone.localdate() + timedelta(days=3)
        Solicitud.objects.create(usuario=self.alumno, tipo='laboratorio', recurso='Lab Software',
            fecha_solicitada=dia, hora_inicio='09:00', hora_fin='11:00', motivo='Prueba', estado='aprobada')
        self.client.force_authenticate(user=self.alumno)
        base = f'/api/recursos/{self.recurso.pk}/disponibilidad/?fecha={dia}&inicio=10:00&fin=12:00'
        self.assertFalse(self.client.get(base).data['disponible'])
        self.assertTrue(self.client.get(base.replace('10:00&fin=12:00','11:00&fin=12:00')).data['disponible'])
        self.assertEqual(self.client.get(base.replace('10:00&fin=12:00','12:00&fin=09:00')).status_code, 400)
