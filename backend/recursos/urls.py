from rest_framework.routers import SimpleRouter
from .views import RecursoViewSet
router = SimpleRouter()
router.register('recursos', RecursoViewSet, basename='recurso')
urlpatterns = router.urls
