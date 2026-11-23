# PIUTTEC 2.0 — cierre técnico del prototipo académico

**Fecha de consolidación:** noviembre de 2026. **Base:** `PIUTTEC2.0_COMPLETO_ASISTENCIAS_DJANGO.zip`, entregada en la conversación. Este documento refleja **código incorporado**, no certificación de pruebas de ejecución ni aceptación institucional.

## Alcance funcional (RF-01 a RF-13)

| Requisito | Estado de implementación | Evidencia / limitación |
|---|---|---|
| RF-01 Panel académico | Código integrado | `/api/dashboard/resumen/`: promedio, materias, asistencia personal, agenda, solicitudes, archivos. Datos por usuario. |
| RF-02 Materias y horarios | Código integrado | CRUD `/api/materias/`, `/api/horarios/`; horarios recurrentes, sin calendario escolar real. |
| RF-03 Agenda y tareas | Código integrado | CRUD `/api/agenda/`; calendario Flutter; sin sincronización con calendario institucional. |
| RF-04 Comparativo individual/grupal | Código integrado | `/api/rendimiento/`; no calcula promedio grupal sin mínimo de estudiantes registrados. |
| RF-05 Reservas y equipos | Código integrado | Catálogo `/api/recursos/`, disponibilidad, `/api/solicitudes/`, aprobación/rechazo y devolución de equipo. Sin inventario UTTEC real. |
| RF-06 Justificantes y estado | Código integrado | Solicitud pendiente, revisión por administrador, cambio `F → J` solamente si existe falta en materia/fecha asociadas. Sin validación oficial de comprobantes. |
| RF-07 Inicio de sesión JWT | Código integrado | Lámpara, login, `/api/auth/me/`, refresh periódico en memoria; expiración y manejo multi-dispositivo requieren QA. |
| RF-08 Roles | Código integrado parcial | Estudiante/docente/administrador en modelo y revisión administrativa protegida. No hay un panel docente institucional completo ni asignación centralizada de grupos. |
| RF-09 Refuerzo académico | Prototipo funcional | Tres bancos de tres preguntas (redes, programación, SQL) por carrera/cuatrimestre/parcial; contenido didáctico ampliable. |
| RF-10 Progreso, retos y recordatorios | Parcial | Historial de intentos, porcentajes y logros; no incluye notificaciones automáticas programadas. El resultado se envía desde el cliente, no es una evaluación certificada. |
| RF-11 Dashboard API | Código integrado | `/api/dashboard/resumen/` protegido por JWT, sin cifras académicas inventadas. |
| RF-12 Solicitudes API | Código integrado | CRUD de solicitud, rol revisor, bloqueo básico de colisiones y trazabilidad. |
| RF-13 Interfaz responsive Flutter | Código integrado parcial | Navegación adaptable, módulos principales conectados; directorio docente reúne los nombres anotados por el estudiante en sus materias; requiere pruebas de accesibilidad y pantallas móviles. Requiere pruebas de accesibilidad y pantallas móviles. |

**Estados:** «Código integrado» significa implementado en archivos, **no** que los tests hayan pasado. Los datos en este repositorio son registros de práctica, no operaciones ni historiales oficiales de la Universidad Tecnológica de Tecámac.

## Requisitos no funcionales (RNF-01 a RNF-12)

| RNF | Evidencia incluida | Pendiente para cierre verificable |
|---|---|---|
| RNF-01 JWT | Login/refresh, token sólo en memoria | Probar expiración y revocación real, estrategia completa de sesiones. |
| RNF-02 Permisos | Aislamiento en QuerySets; aprobación por admin | Pruebas de seguridad y auditoría sobre políticas institucionales. |
| RNF-03 Protección web | CORS permitido, HTTPS configurable, throttling básico de API/login | Revisión de seguridad, Redis/rate limit distribuido, CSRF/cabeceras finales. |
| RNF-04 PostgreSQL | Variables DB_ENGINE, Docker Compose con Postgres 17 | Levantar el servicio, migrar y correr pruebas reales. |
| RNF-05 Responsive | Drawer/sidebar Flutter, ListView y Wrap en pantallas | QA web/móvil/tablet y corrección de overflows. |
| RNF-06 Plataformas | Árbol Flutter Android/iOS/web y dependencias multiplataforma | `flutter build web`, APK real y pruebas iOS en macOS. |
| RNF-07 Accesibilidad | Etiquetas y controles semánticos existentes | Auditoría WCAG y navegación teclado/lector de pantalla. |
| RNF-08 Rendimiento | Caching y filtros ORM básicos | Medir latencia/carga con muestras reproducibles. |
| RNF-09 Mantenibilidad | Apps Django + carpetas Flutter + CI integral | Obtener CI verde y documentación adicional. |
| RNF-10 Seguridad de datos | .gitignore de secretos, upload privado, JWT obligatorio | Revisar hosting, backups, escaneo antivirus, privacidad validada. |
| RNF-11 Trazabilidad | Tests Django/Flutter y script `VERIFICAR_PIUTTEC.ps1` | Ejecutar script, guardar logs/capturas y registrar fecha/responsable. |
| RNF-12 Despliegue | Dockerfile, Compose local, health endpoint | URL pública, dominio, TLS, hosting y prueba desde otra red. |

## Qué fue preservado

El ZIP de base permanece íntegro salvo cambios puntuales para conectar módulos y ampliar modelos. Se conserva el HTML/JS histórico, logo institucional local, lámpara verde y su sonido remoto original, aviso de privacidad original, calendario, historial de asistencias, reservas/justificantes, agenda, materias, comparativo y panel.

El archivo de privacidad **no fue reemplazado**. El documento histórico `docs/piuttec2.docx` y los assets de marca siguen sin modificaciones.

## Aspectos fuera del alcance de una entrega local

- No se dispone de acceso autorizado a datos, sistemas o inventarios oficiales de UTTEC.
- No se ha publicado un servidor público con dominio y TLS ni verificado PostgreSQL contra un contenedor en esta sesión.
- No se han generado APK/iOS ni ejecutado los tests Flutter/Django en esta sesión: no hay SDK Flutter ni se pudieron instalar las dependencias de Django por conectividad.
- La carga de archivos no incluye antivirus/DLP ni cifrado de objetos para producción; no subir expedientes reales.
- El sonido original de la lámpara procede de un enlace externo; requiere conectividad y disponibilidad de ese enlace.
- **No se ha realizado `git push` a GitHub.**

## Criterio de aceptación pendiente

Ejecutar `VERIFICAR_PIUTTEC.ps1` (con tu Python y Flutter instalados), conservar `evidencias_pruebas/resumen.csv` y corregir cualquier prueba roja. Después probar manualmente: cuenta estudiante, cuenta administradora, materias, pase de lista `F`, solicitud de justificante asociada, aprobación `F → J`, reserva de recurso, conflicto de horario, devolución de equipo, subida/descarga de PDF y progreso de refuerzo. Finalmente levantar PostgreSQL, repetir pruebas y desplegar con HTTPS.
