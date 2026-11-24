from rest_framework.routers import SimpleRouter
from .views import MateriaViewSet, HorarioViewSet
from .rendimiento import rendimiento
from django.urls import path

router = SimpleRouter()
router.register(r"materias", MateriaViewSet, basename="materias")
router.register(r"horarios", HorarioViewSet, basename="horarios")
urlpatterns = [path("rendimiento/", rendimiento, name="rendimiento")] + router.urls
