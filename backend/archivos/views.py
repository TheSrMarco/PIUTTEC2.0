from pathlib import Path
from django.http import FileResponse
from rest_framework import status, viewsets
from rest_framework.decorators import action
from rest_framework.parsers import FormParser, MultiPartParser
from rest_framework.permissions import IsAuthenticated
from rest_framework.response import Response
from .models import Documento
from .serializers import DocumentoSerializer, DocumentoUploadSerializer


class DocumentoViewSet(viewsets.GenericViewSet):
    """No se publican URLs de almacenamiento: descarga autenticada y aislada."""
    permission_classes = (IsAuthenticated,)
    parser_classes = (MultiPartParser, FormParser)
    http_method_names = ('get', 'post', 'delete', 'head', 'options')

    def get_queryset(self):
        return Documento.objects.filter(usuario=self.request.user)

    def list(self, request):
        return Response(DocumentoSerializer(self.get_queryset(), many=True).data)

    def retrieve(self, request, pk=None):
        return Response(DocumentoSerializer(self.get_object()).data)

    def create(self, request):
        validator = DocumentoUploadSerializer(data=request.data)
        validator.is_valid(raise_exception=True)
        archivo = validator.validated_data['archivo']
        doc = Documento.objects.create(usuario=request.user, nombre=Path(archivo.name).name,
            materia=validator.validated_data.get('materia', '').strip(),
            tamano=archivo.size, archivo=archivo)
        return Response(DocumentoSerializer(doc).data, status=status.HTTP_201_CREATED)

    def destroy(self, request, pk=None):
        self.get_object().delete()
        return Response(status=status.HTTP_204_NO_CONTENT)

    @action(detail=True, methods=('get',))
    def descargar(self, request, pk=None):
        doc = self.get_object()
        return FileResponse(doc.archivo.open('rb'), as_attachment=True,
                            filename=doc.nombre, content_type='application/octet-stream')
