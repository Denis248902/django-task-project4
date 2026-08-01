from rest_framework import serializers

from .models import Collect, Payment


class PaymentSerializer(serializers.ModelSerializer):
    user_name = serializers.ReadOnlyField(source="user.username")

    class Meta:
        model = Payment
        fields = ["id", "collect", "user", "user_name", "amount", "paid_at"]
        read_only_fields = ["paid_at", "user"]


class CollectSerializer(serializers.ModelSerializer):
    author_name = serializers.ReadOnlyField(source="author.username")
    current_amount = serializers.ReadOnlyField()
    payments = PaymentSerializer(many=True, read_only=True)
    cover_image_url = serializers.SerializerMethodField()

    class Meta:
        model = Collect
        fields = [
            "id",
            "author",
            "author_name",
            "title",
            "reason",
            "description",
            "target_amount",
            "current_amount",
            "cover_image",
            "cover_image_url",
            "deadline",
            "created_at",
            "payments",
        ]
        read_only_fields = ["author", "current_amount", "created_at"]

    def get_cover_image_url(self, obj):
        if obj.cover_image:
            return obj.cover_image.url
        return None
