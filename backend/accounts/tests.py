"""Pruebas de regresión del CRUD de cuentas, permisos y sesiones JWT."""
from django.contrib.auth import get_user_model
from rest_framework.test import APITestCase

from solicitudes.models import Solicitud

User = get_user_model()


def registration(**overrides):
    result = {
        'username': 'nuevo_estudiante',
        'email': 'nuevo@example.test',
        'first_name': 'Prueba',
        'last_name': 'Estudiante',
        'password': 'CuentaSegura2026!x',
        'password_confirm': 'CuentaSegura2026!x',
        'accepted_privacy': True,
    }
    result.update(overrides)
    return result


class RegistroPublicoTests(APITestCase):
    def setUp(self):
        from django.core.cache import cache
        cache.clear()

    def test_registro_crea_cuenta_real_y_hash_de_contrasena(self):
        response = self.client.post('/api/auth/register/', registration(), format='json')
        self.assertEqual(response.status_code, 201, response.data)
        user = User.objects.get(username='nuevo_estudiante')
        self.assertTrue(user.check_password('CuentaSegura2026!x'))
        self.assertNotEqual(user.password, 'CuentaSegura2026!x')
        self.assertEqual(user.role, User.Role.STUDENT)
        self.assertNotIn('password', response.data)
        self.assertEqual(self.client.post('/api/auth/login/', {
            'username': 'nuevo_estudiante', 'password': 'CuentaSegura2026!x'
        }, format='json').status_code, 200)

    def test_no_aceptar_aviso_impide_registro(self):
        response = self.client.post('/api/auth/register/',
            registration(accepted_privacy=False), format='json')
        self.assertEqual(response.status_code, 400)
        self.assertFalse(User.objects.filter(username='nuevo_estudiante').exists())

    def test_rol_administrador_no_es_asignable_en_registro_publico(self):
        response = self.client.post('/api/auth/register/',
            registration(role='administrator', is_staff=True, is_superuser=True), format='json')
        self.assertEqual(response.status_code, 201, response.data)
        user = User.objects.get(username='nuevo_estudiante')
        self.assertEqual(user.role, 'student')
        self.assertFalse(user.is_staff)
        self.assertFalse(user.is_superuser)

    def test_correo_duplicado_sin_distinguir_mayusculas(self):
        User.objects.create_user(username='otro', password='CuentaSegura2026!x', email='NUEVO@example.test')
        response = self.client.post('/api/auth/register/', registration(), format='json')
        self.assertEqual(response.status_code, 400)
        self.assertIn('email', response.data)

    def test_username_duplicado_sin_distinguir_mayusculas(self):
        User.objects.create_user(username='NUEVO_ESTUDIANTE', password='CuentaSegura2026!x')
        response = self.client.post('/api/auth/register/', registration(), format='json')
        self.assertEqual(response.status_code, 400)
        self.assertIn('username', response.data)

    def test_password_debil_o_confirmacion_incorrecta(self):
        for payload in [registration(password='1234', password_confirm='1234'),
                        registration(password_confirm='distinta')]:
            with self.subTest(payload=payload['password_confirm']):
                response = self.client.post('/api/auth/register/', payload, format='json')
                self.assertEqual(response.status_code, 400)


class PerfilAuthTests(APITestCase):
    def setUp(self):
        from django.core.cache import cache
        cache.clear()
        self.user = User.objects.create_user(username='alumno_demo', email='alumno@example.test',
            password='Prueba2026!segura', role='student')

    def test_perfil_requiere_jwt_y_no_revela_hash(self):
        self.assertEqual(self.client.get('/api/auth/me/').status_code, 401)
        self.client.force_authenticate(user=self.user)
        result = self.client.get('/api/auth/me/')
        self.assertEqual(result.status_code, 200)
        self.assertEqual(result.data['role'], 'student')
        self.assertNotIn('password', result.data)

    def test_login_jwt_refresh_y_password_incorrecta(self):
        response = self.client.post('/api/auth/login/', {
            'username': 'alumno_demo', 'password': 'Prueba2026!segura'}, format='json')
        self.assertEqual(response.status_code, 200, response.data)
        self.assertIn('access', response.data)
        self.assertEqual(self.client.post('/api/auth/refresh/',
            {'refresh': response.data['refresh']}, format='json').status_code, 200)
        self.assertEqual(self.client.post('/api/auth/login/', {
            'username': 'alumno_demo', 'password': 'incorrecta'}, format='json').status_code, 401)

    def test_editar_perfil_sin_poder_elevar_privilegios(self):
        self.client.force_authenticate(user=self.user)
        response = self.client.patch('/api/auth/me/', {
            'username': 'alumno_actualizado', 'first_name': 'Alma',
            'email': 'actualizado@example.test',
            'role': 'administrator', 'is_staff': True, 'is_superuser': True,
        }, format='json')
        self.assertEqual(response.status_code, 200, response.data)
        self.user.refresh_from_db()
        self.assertEqual(self.user.username, 'alumno_actualizado')
        self.assertEqual(self.user.first_name, 'Alma')
        self.assertEqual(self.user.role, 'student')
        self.assertFalse(self.user.is_staff)
        self.assertFalse(self.user.is_superuser)

    def test_cambio_de_password_valida_anterior_e_invalida_tokens(self):
        response = self.client.post('/api/auth/login/', {
            'username': 'alumno_demo', 'password': 'Prueba2026!segura'}, format='json')
        refresh = response.data['refresh']
        access = response.data['access']
        self.client.credentials(HTTP_AUTHORIZATION=f'Bearer {access}')
        wrong = self.client.post('/api/auth/change-password/', {
            'current_password': 'incorrecta', 'new_password': 'OtraCuenta2026!segura',
            'new_password_confirm': 'OtraCuenta2026!segura'}, format='json')
        self.assertEqual(wrong.status_code, 400)
        ok = self.client.post('/api/auth/change-password/', {
            'current_password': 'Prueba2026!segura',
            'new_password': 'OtraCuenta2026!segura',
            'new_password_confirm': 'OtraCuenta2026!segura'}, format='json')
        self.assertEqual(ok.status_code, 200, ok.data)
        self.user.refresh_from_db()
        self.assertTrue(self.user.check_password('OtraCuenta2026!segura'))
        self.assertEqual(self.client.get('/api/auth/me/').status_code, 401)
        self.assertEqual(self.client.post('/api/auth/refresh/', {'refresh': refresh}, format='json').status_code, 401)

    def test_logout_revoca_refresh_token(self):
        response = self.client.post('/api/auth/login/', {
            'username': 'alumno_demo', 'password': 'Prueba2026!segura'}, format='json')
        self.client.credentials(HTTP_AUTHORIZATION=f"Bearer {response.data['access']}")
        result = self.client.post('/api/auth/logout/', {'refresh': response.data['refresh']}, format='json')
        self.assertEqual(result.status_code, 204, result.data)
        self.assertEqual(self.client.post('/api/auth/refresh/', {
            'refresh': response.data['refresh']}, format='json').status_code, 401)

    def test_logout_no_puede_revocar_token_ajeno(self):
        other = User.objects.create_user(username='otra_persona',
            password='Prueba2026!segura', email='otra@example.test')
        response = self.client.post('/api/auth/login/', {
            'username': 'alumno_demo', 'password': 'Prueba2026!segura'}, format='json')
        self.client.force_authenticate(user=other)
        result = self.client.post('/api/auth/logout/', {'refresh': response.data['refresh']}, format='json')
        self.assertEqual(result.status_code, 403)

    def test_eliminar_cuenta_sin_solicitudes_borra_usuario(self):
        self.client.force_authenticate(user=self.user)
        self.assertEqual(self.client.delete('/api/auth/me/').status_code, 204)
        self.assertFalse(User.objects.filter(pk=self.user.pk).exists())

    def test_eliminar_cuenta_con_solicitudes_anonimiza_y_bloquea_login(self):
        from datetime import date
        Solicitud.objects.create(usuario=self.user, tipo='equipo', recurso='Monitor de prueba',
            fecha_solicitada=date(2026, 11, 25), motivo='Práctica')
        self.client.force_authenticate(user=self.user)
        self.assertEqual(self.client.delete('/api/auth/me/').status_code, 204)
        self.user.refresh_from_db()
        self.assertFalse(self.user.is_active)
        self.assertFalse(self.user.has_usable_password())
        self.assertEqual(self.user.email, '')
        self.assertTrue(self.user.username.startswith('cuenta_eliminada_'))
        self.client.force_authenticate(user=None)
        self.assertEqual(self.client.post('/api/auth/login/', {
            'username': 'alumno_demo', 'password': 'Prueba2026!segura'}, format='json').status_code, 401)


class GestionAdministrativaTests(APITestCase):
    def setUp(self):
        from django.core.cache import cache
        cache.clear()
        self.student = User.objects.create_user(username='estudiante',
            password='Prueba2026!segura', email='estudiante@example.test')
        self.admin = User.objects.create_superuser(username='admin_demo',
            password='OtraClaveSegura2026!', email='admin@example.test')

    def test_estudiante_no_puede_listar_editar_ni_eliminar_otros(self):
        self.client.force_authenticate(user=self.student)
        self.assertEqual(self.client.get('/api/auth/users/').status_code, 403)
        self.assertEqual(self.client.patch(f'/api/auth/users/{self.admin.pk}/',
            {'role': 'student'}, format='json').status_code, 403)
        self.assertEqual(self.client.delete(f'/api/auth/users/{self.admin.pk}/').status_code, 403)

    def test_administrador_crear_listar_editar_y_eliminar(self):
        self.client.force_authenticate(user=self.admin)
        self.assertEqual(self.client.get('/api/auth/users/').status_code, 200)
        create = self.client.post('/api/auth/users/', registration(
            username='tercera_cuenta', email='tercera@example.test'), format='json')
        self.assertEqual(create.status_code, 201, create.data)
        pk = create.data['id']
        edit = self.client.patch(f'/api/auth/users/{pk}/', {'role': 'teacher'}, format='json')
        self.assertEqual(edit.status_code, 200, edit.data)
        self.assertEqual(User.objects.get(pk=pk).role, 'teacher')
        self.assertEqual(self.client.delete(f'/api/auth/users/{pk}/').status_code, 204)
        self.assertFalse(User.objects.filter(pk=pk).exists())

    def test_admin_no_elimina_su_propia_cuenta_por_usuarios(self):
        self.client.force_authenticate(user=self.admin)
        self.assertEqual(self.client.delete(f'/api/auth/users/{self.admin.pk}/').status_code, 400)

    def test_administrador_puede_desactivar_usuario(self):
        self.client.force_authenticate(user=self.admin)
        response = self.client.patch(f'/api/auth/users/{self.student.pk}/',
            {'is_active': False}, format='json')
        self.assertEqual(response.status_code, 200, response.data)
        self.student.refresh_from_db()
        self.assertFalse(self.student.is_active)
