from django.urls import path, include
from rest_framework.routers import DefaultRouter
from .viewsets import CollectViewSet, PaymentViewSet

router = DefaultRouter()
router.register(r'collects', CollectViewSet, basename='collect')
router.register(r'payments', PaymentViewSet, basename='payment')

urlpatterns = [
    path('', include(router.urls)),
]
