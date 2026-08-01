from django.urls import path, include
from rest_framework.routers import DefaultRouter
from collects.viewsets import CollectViewSet

router = DefaultRouter()
router.register(r'collects', CollectViewSet, basename='collect')

urlpatterns = [
    # Эндпоинты Djoser: регистрация, логин, токены и т.д.
    path('', include('djoser.urls')),
    path('auth/', include('djoser.urls.jwt')),

    # Твои ресурсы (collects, payments)
    path('', include(router.urls)),
]
