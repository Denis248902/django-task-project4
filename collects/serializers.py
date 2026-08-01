from rest_framework import serializers
from collects.models import Collect, Payment
from django.contrib.auth.models import User

class UserSerializer(serializers.ModelSerializer):
    class Meta:
        model = User
        fields = ["id", "username", "first_name", "last_name"]

class PaymentSerializer(serializers.ModelSerializer):
    user = UserSerializer(read_only=True)
    username = serializers.CharField(source="user.username", read_only=True)

    class Meta:
        model = Payment
        fields = [
            "id",
            "collect",
            "user",
            "username",
            "amount",
            "paid_at",
        ]
        read_only_fields = ["paid_at"]

class CollectSerializer(serializers.ModelSerializer):
    author = UserSerializer(read_only=True)
    author_id = serializers.IntegerField(write_only=True)
    payments = PaymentSerializer(many=True, read_only=True)
    current_amount = serializers.DecimalField(
        max_digits=12, decimal_places=2, read_only=True
    )

    class Meta:
        model = Collect
        fields = [
            "id",
            "author",
            "author_id",
            "title",
            "reason",
            "description",
            "target_amount",
            "current_amount",
            "cover_image",
            "deadline",
            "created_at",
            "payments",
        ]
        read_only_fields = ["created_at"]
