from django_filters.rest_framework import DjangoFilterBackend
from rest_framework import filters, viewsets

from .models import Collect
from .serializers import CollectSerializer


class CollectViewSet(viewsets.ModelViewSet):
    queryset = Collect.objects.all()
    serializer_class = CollectSerializer
    filter_backends = [
        DjangoFilterBackend,
        filters.OrderingFilter,
        filters.SearchFilter,
    ]
    filterset_fields = ["reason"]
    search_fields = ["title", "description"]
    ordering_fields = ["deadline", "created_at", "target_amount"]
    lookup_field = "id"
