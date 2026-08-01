# api/viewsets.py
from rest_framework import permissions, viewsets

from .models import Collect
from .serializers import CollectSerializer


class CollectViewSet(viewsets.ModelViewSet):
    queryset = Collect.objects.all()
    serializer_class = CollectSerializer
    permission_classes = [permissions.IsAuthenticated]

    # Эта функция берёт текущего пользователя из запроса и ставит его в author
    def perform_create(self, serializer):
        serializer.save(author=self.request.user)
