from django.conf import settings
from django.contrib import admin
from django.urls import path
from rest_framework_simplejwt.views import TokenObtainPairView, TokenRefreshView
from dashboard.views import demo_dashboard
from accounts.views import profile
from attendance.views import attendance_day, course_list

urlpatterns = [
    path("api/auth/me/", profile, name="profile"),
    path("api/courses/", course_list, name="course-list"),
    path("api/courses/<int:course_id>/attendance/", attendance_day, name="attendance-day"),
    path("admin/", admin.site.urls),
    path("api/auth/login/", TokenObtainPairView.as_view(), name="login"),
    path("api/auth/refresh/", TokenRefreshView.as_view(), name="token-refresh"),
]
if settings.DEBUG:
    urlpatterns.append(path("api/demo/dashboard/", demo_dashboard, name="demo-dashboard"))
