from django.contrib.auth import get_user_model
from django.utils import timezone
from rest_framework import serializers

from collects.models import Collect, Payment

User = get_user_model()


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
    payments = PaymentSerializer(many=True, read_only=True)
    current_amount = serializers.DecimalField(
        max_digits=12, decimal_places=2, read_only=True
    )
    cover_image = serializers.ImageField(required=False, allow_null=True)

    class Meta:
        model = Collect
        fields = [
            "id",
            "author",
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

    def create(self, validated_data):
        validated_data.pop("author", None)
        user = self.context["request"].user
        return Collect.objects.create(author=user, **validated_data)

    def validate_deadline(self, value):
        if value <= timezone.now():
            raise serializers.ValidationError("Дата завершения должна быть в будущем.")
        return value
