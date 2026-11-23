from rest_framework.routers import SimpleRouter
from .views import ActividadViewSet

router = SimpleRouter()
router.register(r"agenda", ActividadViewSet, basename="agenda")
urlpatterns = router.urls
