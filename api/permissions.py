from rest_framework import permissions

class IsEditorOrReadOnly(permissions.BasePermission):
    def has_permission(self, request, view):
        if request.method in permissions.SAFE_METHODS:
            return True
        user = request.user
        if not user.is_authenticated:
            return False
        return user.groups.filter(name__in=['editors', 'admins']).exists()
