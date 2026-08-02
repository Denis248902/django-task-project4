from rest_framework import viewsets
from .models import Payment, Collect
from .serializers import PaymentSerializer

class PaymentViewSet(viewsets.ModelViewSet):
    queryset = Payment.objects.all()
    serializer_class = PaymentSerializer

    def perform_create(self, serializer):
        payment = serializer.save()
        collect = payment.collect
        collect.current_amount = collect.current_amount + payment.amount
        collect.save(update_fields=['current_amount'])