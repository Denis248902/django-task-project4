from django.urls import path, include
from rest_framework.routers import DefaultRouter
from collects.viewsets import CollectViewSet

# Создаём роутер и регистрируем твой ViewSet
router = DefaultRouter()
router.register(r'collects', CollectViewSet, basename='collect')

urlpatterns = [
    # Эндпоинты Djoser (users, auth и т.д.)
    path('', include('djoser.urls')),
    path('auth/', include('djoser.urls.jwt')),
    
    # Эндпоинты для collects (теперь будет работать /api/collects/)
    path('', include(router.urls)),
]
