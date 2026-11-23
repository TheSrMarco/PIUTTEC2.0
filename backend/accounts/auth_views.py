from rest_framework.throttling import AnonRateThrottle
from rest_framework_simplejwt.views import TokenObtainPairView, TokenRefreshView


class LoginThrottle(AnonRateThrottle):
    rate = '8/min'


class RefreshThrottle(AnonRateThrottle):
    rate = '30/min'


class LimitedTokenObtainPairView(TokenObtainPairView):
    throttle_classes = (LoginThrottle,)


class LimitedTokenRefreshView(TokenRefreshView):
    throttle_classes = (RefreshThrottle,)
