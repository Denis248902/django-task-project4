# api/serializers.py
from rest_framework import serializers
from .models import Collect

class CollectSerializer(serializers.ModelSerializer):
    class Meta:
        model = Collect
        fields = ['id', 'title', 'reason', 'target_amount', 'deadline', 'description', 'author']
        read_only_fields = ['author']  # автор не приходит из JSON, а берётся из request.user