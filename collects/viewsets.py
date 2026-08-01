from rest_framework import viewsets
from collects.models import Collect
from collects.serializers import CollectSerializer
from api.permissions import IsEditorOrReadOnly


class CollectViewSet(viewsets.ModelViewSet):
    queryset = Collect.objects.all()
    serializer_class = CollectSerializer
    permission_classes = [IsEditorOrReadOnly]

    def perform_create(self, serializer):
        serializer.save(author=self.request.user)
