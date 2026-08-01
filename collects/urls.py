from django.urls import include, path
from rest_framework.routers import DefaultRouter

from .viewsets import CollectViewSet

router = DefaultRouter()
router.register(r"collects", CollectViewSet, basename="collect")

urlpatterns = [
    path("", include(router.urls)),
]
