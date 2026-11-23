from django.conf import settings
from django.contrib import admin
from django.urls import path, include
from accounts.auth_views import LimitedTokenObtainPairView, LimitedTokenRefreshView
from dashboard.views import demo_dashboard
from dashboard.resumen import resumen_dashboard
from accounts.views import (AdminUserDetailView, AdminUsersView, ChangePasswordView,
                            LogoutView, MeView, PublicRegistrationView)
from config.health import health

urlpatterns = [
    path("admin/", admin.site.urls),
    path("api/health/", health, name="api-health"),
    path("api/dashboard/resumen/", resumen_dashboard, name="dashboard-resumen"),
    path("api/", include("solicitudes.urls")),
    path("api/", include("agenda.urls")),
    path("api/", include("academia.urls")),
    path("api/", include("asistencias.urls")),
    path("api/", include("recursos.urls")),
    path("api/", include("archivos.urls")),
    path("api/", include("refuerzo.urls")),
    path("api/auth/register/", PublicRegistrationView.as_view(), name="auth-register"),
    path("api/auth/me/", MeView.as_view(), name="auth-me"),
    path("api/auth/change-password/", ChangePasswordView.as_view(), name="auth-change-password"),
    path("api/auth/logout/", LogoutView.as_view(), name="auth-logout"),
    path("api/auth/users/", AdminUsersView.as_view(), name="auth-users"),
    path("api/auth/users/<int:pk>/", AdminUserDetailView.as_view(), name="auth-user-detail"),
    path("api/auth/login/", LimitedTokenObtainPairView.as_view(), name="login"),
    path("api/auth/refresh/", LimitedTokenRefreshView.as_view(), name="token-refresh"),
]
if settings.DEBUG:
    urlpatterns.append(path("api/demo/dashboard/", demo_dashboard, name="demo-dashboard"))
