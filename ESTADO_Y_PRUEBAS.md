# Estado y pruebas de la versión consolidada — 23/11/2026

Origen: `PIUTTEC2.0-main.zip` aportado por el equipo. Se preservan los archivos originales salvo los ajustes necesarios en configuración Django, navegación Flutter y el acceso.

| Control | Estado comprobado | Verificación pendiente |
|---|---|---|
| Estructura Flutter, Django, docs, plataformas Android/iOS | Incluida en ZIP | Compilación por plataforma |
| Logotipo original | Copiado a recursos locales en Flutter y web | Revisión visual en dispositivo |
| Lámpara, cuerda y llamada al sonido original | Código de interacción incorporado | Audio remoto audible y prueba de gestos real |
| Login JWT Django | Ruta ya existente; Flutter usa API | Crear cuenta de prueba, comprobar login/expiración |
| Aviso obligatorio | Estado y casilla incorporados | Prueba Flutter en dispositivo |
| Calendario mensual/semanal/diario | Implementación Flutter y HTML | Ejecutar en Flutter; datos reales pendientes |
| Módulos con alcance acotado | Navegación solo PIUTTEC 2.0 | Revisar con requisitos de memoria |
| RF-12 solicitudes con Django API | Archivos integrados, migración y pruebas escritas | Migrar y ejecutar tests |
| Autenticación única para RF-12 | Se pasa token del login a la vista de solicitudes | Probar token real, logout y autorización |
| RNF-04 PostgreSQL | Configurable | Instancia/migraciones/pruebas en PostgreSQL |
| RNF-12 Despliegue | No realizado | URL HTTPS y comprobación externa |

**Importante:** las interfaces con datos de ejemplo no son servicios institucionales. El instalador de paquetes anterior no es necesario: este ZIP ya contiene los cambios. No se ha hecho `git push`.


## Actualización: pase de lista Django

El pase local de Flutter se conserva sin cambios funcionales. Con JWT, el pase ahora utiliza `asistencias` (nueva migración `0001_initial`) y el resumen de RF-01 calcula la asistencia desde registros personales existentes. El gestor de archivos sigue sin API. Este cambio **sí requiere `manage.py migrate`** y pruebas del nuevo módulo; consulta `AVANCE_ASISTENCIAS_DJANGO_2026.md`. Las pruebas nuevas no se han ejecutado en este entorno.
