from rest_framework.routers import SimpleRouter
from .views import AsistenciaViewSet

router = SimpleRouter()
router.register(r"asistencias", AsistenciaViewSet, basename="asistencias")
urlpatterns = router.urls
