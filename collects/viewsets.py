from django.db.models import Sum
from rest_framework import permissions, viewsets

from .models import Collect, Payment
from .serializers import CollectSerializer, PaymentSerializer


class IsAuthorOrReadOnly(permissions.BasePermission):
    """Разрешает редактирование только автору сбора."""

    def has_object_permission(self, request, view, obj):
        # SAFE_METHODS = GET, HEAD, OPTIONS
        if request.method in permissions.SAFE_METHODS:
            return True
        return obj.author == request.user


class CollectViewSet(viewsets.ModelViewSet):
    queryset = Collect.objects.all()
    serializer_class = CollectSerializer
    permission_classes = [permissions.IsAuthenticatedOrReadOnly, IsAuthorOrReadOnly]

    def perform_create(self, serializer):
        serializer.save(author=self.request.user)


class PaymentViewSet(viewsets.ModelViewSet):
    serializer_class = PaymentSerializer
    permission_classes = [permissions.IsAuthenticated]

    def get_queryset(self):
        user = self.request.user
        return Payment.objects.filter(user=user)

    def perform_create(self, serializer):
        payment = serializer.save(user=self.request.user)
        collect = payment.collect
        total = collect.payments.aggregate(total=Sum("amount"))["total"] or 0
        collect.current_amount = total
        collect.save(update_fields=["current_amount"])
        return payment
