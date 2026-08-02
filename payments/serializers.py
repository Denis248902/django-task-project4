class PaymentSerializer(serializers.ModelSerializer):
    class Meta:
        model = Payment
        fields = ['id', 'collect', 'amount', 'paid_at']  # collect просто в списке полей