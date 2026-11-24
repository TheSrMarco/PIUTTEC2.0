from rest_framework.routers import SimpleRouter
from .views import IntentoViewSet
router = SimpleRouter()
router.register('refuerzo/intentos', IntentoViewSet, basename='intento-refuerzo')
urlpatterns = router.urls
