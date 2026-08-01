from django.shortcuts import get_object_or_404
from rest_framework import permissions, viewsets

from collects.models import Collect, Payment
from collects.serializers import CollectSerializer, PaymentSerializer


class CollectViewSet(viewsets.ModelViewSet):
    queryset = Collect.objects.all()
    serializer_class = CollectSerializer
    permission_classes = [permissions.IsAuthenticatedOrReadOnly]

    def perform_create(self, serializer):
        serializer.save(author=self.request.user)


class PaymentViewSet(viewsets.ModelViewSet):
    queryset = Payment.objects.all()
    serializer_class = PaymentSerializer
    permission_classes = [permissions.IsAuthenticated]

    def perform_create(self, serializer):
        collect_id = self.request.data.get("collect")
        collect = get_object_or_404(Collect, id=collect_id)
        user = self.request.user

        payment = serializer.save(user=user)
        collect.current_amount += payment.amount
        collect.save(update_fields=["current_amount"])
        return payment
