from django.contrib.auth import get_user_model
from django.utils.crypto import constant_time_compare
from rest_framework.exceptions import AuthenticationFailed
from rest_framework.throttling import AnonRateThrottle
from rest_framework_simplejwt.serializers import TokenRefreshSerializer
from rest_framework_simplejwt.settings import api_settings
from rest_framework_simplejwt.utils import get_md5_hash_password
from rest_framework_simplejwt.views import TokenObtainPairView, TokenRefreshView


class LoginThrottle(AnonRateThrottle):
    rate = '8/min'


class RefreshThrottle(AnonRateThrottle):
    rate = '30/min'


class LimitedTokenObtainPairView(TokenObtainPairView):
    throttle_classes = (LoginThrottle,)


class PasswordAwareRefreshSerializer(TokenRefreshSerializer):
    """Invalida un refresh JWT cuando cambia la contraseña del usuario."""

    def validate(self, attrs):
        # Verifica firma, vencimiento y blacklist antes de consultar al usuario.
        refresh = self.token_class(attrs["refresh"])
        user_id = refresh.payload.get(api_settings.USER_ID_CLAIM)
        if user_id is None:
            raise AuthenticationFailed("Token de renovación inválido.")
        user = get_user_model().objects.filter(
            **{api_settings.USER_ID_FIELD: user_id}
        ).first()
        if not user or not api_settings.USER_AUTHENTICATION_RULE(user):
            raise AuthenticationFailed("La cuenta ya no está activa.")
        if api_settings.CHECK_REVOKE_TOKEN:
            previous_password_hash = refresh.payload.get(
                api_settings.REVOKE_TOKEN_CLAIM, ""
            )
            if not isinstance(previous_password_hash, str) or not constant_time_compare(
                previous_password_hash, get_md5_hash_password(user.password)
            ):
                raise AuthenticationFailed(
                    "La contraseña cambió. Inicia sesión nuevamente.",
                    code="password_changed",
                )
        return super().validate(attrs)


class LimitedTokenRefreshView(TokenRefreshView):
    throttle_classes = (RefreshThrottle,)
    serializer_class = PasswordAwareRefreshSerializer
