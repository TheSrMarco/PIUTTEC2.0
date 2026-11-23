# Estado comprobado — PIUTTEC 2.0 (cierre académico)

Fecha de elaboración: noviembre de 2026.

## Verificaciones que SÍ se ejecutaron en este entorno

- Comparación binaria con el ZIP anterior: **196 archivos heredados presentes**, 177 idénticos, 19 modificados, 56 nuevos (antes de añadir este informe).
- Compilación sintáctica de **90 archivos Python** mediante `compile(..., 'exec')`: sin errores de sintaxis.
- Lectura sintáctica de **5 archivos YAML**: sin errores de lectura.
- XML plist de iOS: formato válido y propiedad `CFBundleName` encontrada.
- Verificación estática de importaciones relativas `frontend/lib/**/*.dart`: todos los destinos importados existen.
- Existencia de rutas nuevas de recursos, documentos, progreso, justificantes, logo, privacidad y script de PowerShell: confirmada.

## Verificaciones NO ejecutadas / pendientes

- **Django `manage.py check`, migraciones reales y tests:** Django no está instalado en este entorno y no se pudieron descargar las dependencias por conectividad.
- **Flutter `pub get`, analyze, test, build web/APK:** no está instalado el SDK Flutter aquí.
- **PostgreSQL:** la configuración Compose se ha escrito pero no se ha levantado ni probado.
- **HTTPS y servidor público:** no se ha desplegado.
- **GitHub:** no se ha realizado `git push`.
- **Accesibilidad, roles institucionales, carga, auditoría de seguridad y operación real:** requieren pruebas de aceptación.

No confundir **código integrado** con **funcionalidad certificada**. Este paquete es una base consolidada y documentada para la entrega y validación académica, no una implementación institucional aprobada.

## Ejecutar comprobación completa en Windows

```powershell
cd "C:\Software Proyectos\PIUTTEC2_Prueba\PIUTTEC2.0"
powershell -ExecutionPolicy Bypass -File .\VERIFICAR_PIUTTEC.ps1
```

Las evidencias se guardan en `evidencias_pruebas/`. Revisa los logs y corrige cualquier prueba roja antes de etiquetar una versión estable.

## Archivos existentes modificados

- `.gitignore`
- `README.md`
- `backend/config/settings.py`
- `backend/config/urls.py`
- `backend/dashboard/resumen.py`
- `backend/dashboard/tests.py`
- `backend/solicitudes/admin.py`
- `backend/solicitudes/models.py`
- `backend/solicitudes/serializers.py`
- `backend/solicitudes/views.py`
- `frontend/ios/Runner/Info.plist`
- `frontend/lib/app.dart`
- `frontend/lib/features/auth/data/auth_session.dart`
- `frontend/lib/features/dashboard/ui/dashboard_view.dart`
- `frontend/lib/features/refuerzo/ui/refuerzo_quiz_view.dart`
- `frontend/lib/features/shell/ui/app_shell.dart`
- `frontend/lib/features/solicitudes/data/solicitudes_repository.dart`
- `frontend/lib/features/solicitudes/ui/solicitudes_view.dart`
- `frontend/pubspec.yaml`

## Archivos añadidos (antes de este informe)

- `.env.production.example`
- `.github/workflows/ci-integral.yml`
- `CIERRE_ACADEMICO_RF_RNF.md`
- `GUIA_EJECUCION_FINAL.md`
- `VERIFICAR_PIUTTEC.ps1`
- `backend/.dockerignore`
- `backend/Dockerfile`
- `backend/accounts/auth_views.py`
- `backend/accounts/tests.py`
- `backend/accounts/views.py`
- `backend/archivos/__init__.py`
- `backend/archivos/admin.py`
- `backend/archivos/migrations/0001_initial.py`
- `backend/archivos/migrations/__init__.py`
- `backend/archivos/models.py`
- `backend/archivos/serializers.py`
- `backend/archivos/tests.py`
- `backend/archivos/urls.py`
- `backend/archivos/views.py`
- `backend/config/health.py`
- `backend/recursos/__init__.py`
- `backend/recursos/admin.py`
- `backend/recursos/management/__init__.py`
- `backend/recursos/management/commands/__init__.py`
- `backend/recursos/management/commands/sembrar_recursos_demo.py`
- `backend/recursos/migrations/0001_initial.py`
- `backend/recursos/migrations/__init__.py`
- `backend/recursos/models.py`
- `backend/recursos/serializers.py`
- `backend/recursos/tests.py`
- `backend/recursos/urls.py`
- `backend/recursos/views.py`
- `backend/refuerzo/__init__.py`
- `backend/refuerzo/admin.py`
- `backend/refuerzo/migrations/0001_initial.py`
- `backend/refuerzo/migrations/__init__.py`
- `backend/refuerzo/models.py`
- `backend/refuerzo/serializers.py`
- `backend/refuerzo/tests.py`
- `backend/refuerzo/urls.py`
- `backend/refuerzo/views.py`
- `backend/requirements-prod.txt`
- `backend/solicitudes/migrations/0002_solicitud_materia.py`
- `backend/solicitudes/migrations/0003_estado_devuelta.py`
- `backend/solicitudes/test_flujos_finales.py`
- `compose.yaml`
- `frontend/lib/features/archivos/data/archivos_repository.dart`
- `frontend/lib/features/archivos/ui/archivos_view.dart`
- `frontend/lib/features/docentes/ui/docentes_view.dart`
- `frontend/lib/features/recursos/data/recursos_repository.dart`
- `frontend/lib/features/recursos/ui/recursos_view.dart`
- `frontend/lib/features/refuerzo/data/refuerzo_repository.dart`
- `frontend/test/archivos_repository_test.dart`
- `frontend/test/docentes_view_test.dart`
- `frontend/test/recursos_repository_test.dart`
- `frontend/test/refuerzo_repository_test.dart`
