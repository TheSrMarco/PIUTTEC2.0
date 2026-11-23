from rest_framework.routers import SimpleRouter
from .views import DocumentoViewSet
router = SimpleRouter()
router.register('archivos', DocumentoViewSet, basename='archivo')
urlpatterns = router.urls
