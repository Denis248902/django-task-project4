from django.urls import path, include
from rest_framework.routers import DefaultRouter
from .views import EmployeeProfileViewSet, PaymentViewSet  # PaymentViewSet обязательно импортирован

router = DefaultRouter()
router.register(r'employees', EmployeeProfileViewSet)
router.register(r'payments', PaymentViewSet)  # ЭТА СТРОКА ОБЯЗАТЕЛЬНА

urlpatterns = [
    path('', include(router.urls)),
]
