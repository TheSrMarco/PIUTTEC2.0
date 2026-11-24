"""API de cuentas: autoregistro, perfil CRUD, contraseñas y administración."""
from uuid import uuid4

from django.contrib.auth import get_user_model
from django.db import transaction
from rest_framework import generics, permissions, status
from rest_framework.response import Response
from rest_framework.throttling import AnonRateThrottle
from rest_framework.views import APIView
from rest_framework_simplejwt.exceptions import TokenError
from rest_framework_simplejwt.tokens import RefreshToken

from .serializers import (AdminUserSerializer, ChangePasswordSerializer,
                          UserPublicSerializer, UserRegisterSerializer)

User = get_user_model()


class RegistrationThrottle(AnonRateThrottle):
    rate = '6/hour'


class PublicRegistrationView(generics.CreateAPIView):
    serializer_class = UserRegisterSerializer
    permission_classes = [permissions.AllowAny]
    authentication_classes = []
    throttle_classes = [RegistrationThrottle]

    def create(self, request, *args, **kwargs):
        serializer = self.get_serializer(data=request.data)
        serializer.is_valid(raise_exception=True)
        user = serializer.save()
        return Response(UserPublicSerializer(user).data, status=status.HTTP_201_CREATED)


def delete_account(user):
    """Conserva auditoría de solicitudes protegidas; anonimizamos en ese caso."""
    from solicitudes.models import Solicitud
    with transaction.atomic():
        files = [(record.archivo.storage, record.archivo.name)
                 for record in user.documentos_guardados.all() if record.archivo.name]
        if Solicitud.objects.filter(usuario=user).exists():
            # PROTECT impide borrado físico de cuentas con trámites auditables.
            user.username = f'cuenta_eliminada_{user.pk}_{uuid4().hex[:10]}'
            user.email = ''
            user.first_name = ''
            user.last_name = ''
            user.role = User.Role.STUDENT
            user.is_staff = False
            user.is_superuser = False
            user.is_active = False
            user.set_unusable_password()
            user.save()
            user.groups.clear()
            user.user_permissions.clear()
            user.documentos_guardados.all().delete()
            user.asistencias_registradas.all().delete()
            user.materias_registradas.all().delete()
            user.actividades.all().delete()
            user.intentos_refuerzo.all().delete()
            outcome = 'anonimized'
        else:
            user.delete()
            outcome = 'deleted'
        for storage, path in files:
            transaction.on_commit(lambda s=storage, p=path: s.delete(p))
    return outcome


class MeView(generics.RetrieveUpdateDestroyAPIView):
    serializer_class = UserPublicSerializer
    permission_classes = [permissions.IsAuthenticated]
    http_method_names = ['get', 'patch', 'delete', 'head', 'options']

    def get_object(self):
        return self.request.user

    def destroy(self, request, *args, **kwargs):
        user = self.get_object()
        delete_account(user)
        return Response(status=status.HTTP_204_NO_CONTENT)


class ChangePasswordView(APIView):
    permission_classes = [permissions.IsAuthenticated]

    def post(self, request):
        serializer = ChangePasswordSerializer(data=request.data, context={'request': request})
        serializer.is_valid(raise_exception=True)
        request.user.set_password(serializer.validated_data['new_password'])
        request.user.save(update_fields=['password'])
        # SIMPLE_JWT.CHECK_REVOKE_TOKEN invalida access y refresh emitidos antes del cambio.
        return Response({'detail': 'Contraseña actualizada. Inicia sesión nuevamente.'})


class LogoutView(APIView):
    permission_classes = [permissions.IsAuthenticated]

    def post(self, request):
        refresh = request.data.get('refresh')
        if not refresh or not isinstance(refresh, str):
            return Response({'refresh': ['Se requiere un token de renovación.']}, status=400)
        try:
            token = RefreshToken(refresh)
            if str(token.get('user_id')) != str(request.user.pk):
                return Response({'detail': 'El token no corresponde a tu cuenta.'}, status=403)
            token.blacklist()
        except TokenError:
            return Response({'detail': 'Token de renovación inválido o revocado.'}, status=400)
        return Response(status=status.HTTP_204_NO_CONTENT)


class IsInstitutionalAdmin(permissions.BasePermission):
    def has_permission(self, request, view):
        user = request.user
        return bool(user and user.is_authenticated and
                    (user.is_superuser or user.is_staff or user.role == User.Role.ADMINISTRATOR))


class AdminUsersView(generics.ListCreateAPIView):
    permission_classes = [IsInstitutionalAdmin]
    queryset = User.objects.all().order_by('id')

    def get_serializer_class(self):
        return UserRegisterSerializer if self.request.method == 'POST' else AdminUserSerializer

    def create(self, request, *args, **kwargs):
        serializer = self.get_serializer(data=request.data)
        serializer.is_valid(raise_exception=True)
        user = serializer.save()
        return Response(AdminUserSerializer(user).data, status=201)


class AdminUserDetailView(generics.RetrieveUpdateDestroyAPIView):
    permission_classes = [IsInstitutionalAdmin]
    queryset = User.objects.all()
    serializer_class = AdminUserSerializer
    http_method_names = ['get', 'patch', 'delete', 'head', 'options']

    def destroy(self, request, *args, **kwargs):
        user = self.get_object()
        if user.pk == request.user.pk:
            return Response({'detail': 'Elimina tu cuenta desde Mi perfil.'}, status=400)
        delete_account(user)
        return Response(status=204)
