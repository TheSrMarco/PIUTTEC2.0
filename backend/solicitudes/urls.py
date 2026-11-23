from rest_framework.routers import SimpleRouter

from .views import SolicitudViewSet

router = SimpleRouter()
router.register(r"solicitudes", SolicitudViewSet, basename="solicitud")
urlpatterns = router.urls
