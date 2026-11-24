from datetime import timedelta
from django.contrib.auth import get_user_model
from django.utils import timezone
from rest_framework.test import APITestCase
from academia.models import Materia
from asistencias.models import Asistencia
from recursos.models import Recurso
from .models import Solicitud

User = get_user_model()


class FlujosInstitucionalesTests(APITestCase):
    def setUp(self):
        self.alumno = User.objects.create_user(username='flujo_a', password='Prueba2026!', role='student')
        self.otro = User.objects.create_user(username='flujo_b', password='Prueba2026!', role='student')
        self.admin = User.objects.create_user(username='flujo_admin', password='Prueba2026!', role='administrator')
        self.materia = Materia.objects.create(usuario=self.alumno, nombre='Inglés VIII')
        self.dia = timezone.localdate() - timedelta(days=1)
        self.asistencia = Asistencia.objects.create(usuario=self.alumno, materia=self.materia,
          fecha=self.dia, estado='F')

    def test_justificante_pendiente_no_cambia_asistencia_y_aprobado_si(self):
        self.client.force_authenticate(user=self.alumno)
        response = self.client.post('/api/solicitudes/', {'tipo': 'justificante',
          'fecha_solicitada': str(self.dia), 'materia': self.materia.pk,
          'motivo': 'Comprobante académico'}, format='json')
        self.assertEqual(response.status_code, 201, response.data)
        self.asistencia.refresh_from_db()
        self.assertEqual(self.asistencia.estado, 'F')
        self.client.force_authenticate(user=self.admin)
        self.assertEqual(self.client.patch(f'/api/solicitudes/{response.data["id"]}/',
          {'estado': 'aprobada'}, format='json').status_code, 200)
        self.asistencia.refresh_from_db()
        self.assertEqual(self.asistencia.estado, 'J')

    def test_no_se_puede_justificar_materia_ajena(self):
        ajena = Materia.objects.create(usuario=self.otro, nombre='Confidencial')
        self.client.force_authenticate(user=self.alumno)
        self.assertEqual(self.client.post('/api/solicitudes/', {'tipo': 'justificante',
          'fecha_solicitada': str(self.dia), 'materia': ajena.pk,
          'motivo': 'No autorizado'}, format='json').status_code, 400)

    def test_no_se_puede_solicitar_recurso_desactivado(self):
        Recurso.objects.create(nombre='Laptop', tipo='equipo', activo=False)
        self.client.force_authenticate(user=self.alumno)
        payload = {'tipo': 'equipo', 'recurso': 'Laptop',
          'fecha_solicitada': str(timezone.localdate() + timedelta(days=2)),
          'hora_inicio': '09:00', 'hora_fin': '10:00', 'motivo': 'Trabajo'}
        self.assertEqual(self.client.post('/api/solicitudes/', payload, format='json').status_code, 400)

    def test_devolucion_equipos_solo_tras_aprobacion_y_por_admin(self):
        sol = Solicitud.objects.create(usuario=self.alumno, tipo='equipo', recurso='Proyector',
          fecha_solicitada=timezone.localdate() + timedelta(days=2),
          hora_inicio='09:00', hora_fin='10:00', motivo='Prueba', estado='aprobada')
        self.client.force_authenticate(user=self.alumno)
        self.assertEqual(self.client.patch(f'/api/solicitudes/{sol.pk}/',
          {'estado': 'devuelta'}, format='json').status_code, 403)
        self.client.force_authenticate(user=self.admin)
        self.assertEqual(self.client.patch(f'/api/solicitudes/{sol.pk}/',
          {'estado': 'devuelta'}, format='json').status_code, 200)
        sol.refresh_from_db()
        self.assertEqual(sol.estado, 'devuelta')
        self.assertEqual(self.client.patch(f'/api/solicitudes/{sol.pk}/',
          {'estado': 'devuelta'}, format='json').status_code, 400)
