from rest_framework import viewsets, filters
from django_filters.rest_framework import DjangoFilterBackend
from .models import Collect, Payment
from .serializers import CollectSerializer, PaymentSerializer
from .permissions import IsAuthorOrReadOnly

class CollectViewSet(viewsets.ModelViewSet):
    queryset = Collect.objects.all().order_by("-created_at")
    serializer_class = CollectSerializer
    permission_classes = [IsAuthorOrReadOnly]
    filter_backends = [DjangoFilterBackend, filters.OrderingFilter, filters.SearchFilter]
    filterset_fields = ["reason", "author"]
    ordering_fields = ["deadline", "target_amount", "current_amount"]
    search_fields = ["title", "description"]

    def perform_create(self, serializer):
        serializer.save(author=self.request.user)


class PaymentViewSet(viewsets.ModelViewSet):
    queryset = Payment.objects.all().order_by("-paid_at")
    serializer_class = PaymentSerializer
    # Платёж может создавать любой авторизованный пользователь
    permission_classes = []

    def perform_create(self, serializer):
        collect = serializer.validated_data["collect"]
        amount = serializer.validated_data["amount"]
        payment = serializer.save(user=self.request.user)
        # Бизнес‑логика: обновляем current_amount у сбора
        collect.current_amount += amount
        collect.save(update_fields=["current_amount"])
        return payment
