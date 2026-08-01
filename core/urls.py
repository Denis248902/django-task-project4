from django.contrib import admin
from django.urls import include, path

urlpatterns = [
    path("admin/", admin.site.urls),
    path("api/", include("collects.urls")),
    # JWT через djoser — это даёт /api/auth/token/ и /api/auth/refresh/
    path("api/auth/", include("djoser.urls.jwt")),
]
