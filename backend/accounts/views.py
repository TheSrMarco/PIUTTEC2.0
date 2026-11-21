from rest_framework.decorators import api_view
from rest_framework.response import Response


@api_view(["GET"])
def profile(request):
    user = request.user
    return Response({
        "id": user.pk,
        "username": user.username,
        "name": user.get_full_name() or user.username,
        "role": user.role,
    })
