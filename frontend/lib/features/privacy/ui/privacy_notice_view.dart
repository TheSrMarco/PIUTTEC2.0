import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

/// Información del prototipo académico. No constituye un aviso institucional.
class PrivacyNoticeView extends StatelessWidget {
  const PrivacyNoticeView({super.key});

  static const officialNoticeUrl =
      'https://uttecamac.edomex.gob.mx/sites/uttecamac.edomex.gob.mx/files/files/PDFs/DPL/SLIDERS/AVISO_DE_PRIVACIDAD_UTTEC.pdf';

  static const _sections = <({String title, String body})>[
    (
      title: '1. Naturaleza del proyecto y responsable',
      body: 'PIUTTEC 2.0 es un prototipo académico independiente, desarrollado '
          'para prácticas y evaluación. No es el sistema oficial PIUTTEC '
          'ni está acreditado como servicio de la Universidad Tecnológica '
          'de Tecámac (UTTEC). Quien instale o publique este prototipo y '
          'administre su servidor será responsable de documentar el tratamiento '
          'de los datos bajo su control. Antes de un despliegue público se '
          'deberán identificar expresamente al responsable, su domicilio y '
          'un contacto verificable para consultas de privacidad.',
    ),
    (
      title: '2. Datos que puede recibir',
      body: 'Con una cuenta de prueba se pueden proporcionar nombre, usuario, '
          'correo electrónico y contraseña, además de materias, grupos, '
          'calificaciones, horarios, asistencias, actividades, solicitudes, '
          'archivos y resultados de ejercicios. La contraseña se procesa '
          'en Django y se almacena mediante un hash, no como texto plano. '
          'El prototipo utiliza tokens de autenticación para acceder a '
          'funciones privadas.',
    ),
    (
      title: '3. Para qué se usan los datos',
      body: 'Los datos se emplean para demostrar el registro y acceso de '
          'usuarios, consulta y edición del perfil, organización académica, '
          'pase de lista, agenda, préstamo de recursos, justificantes, '
          'gestión de archivos, comparativos y actividades de aprendizaje. '
          'No se utilizan como registros escolares oficiales ni para '
          'acreditar calificaciones o asistencias institucionales.',
    ),
    (
      title: '4. Dónde se guardan y quién puede acceder',
      body: 'En Vista previa, algunos registros se conservan en el '
          'almacenamiento de este navegador. Con una cuenta, la información '
          'se envía al backend Django y permanece en la base de datos '
          'configurada por el operador (SQLite en el entorno local actual; '
          'PostgreSQL cuando se configure). Los documentos pueden almacenarse '
          'en el área privada del servidor. El acceso depende del inicio '
          'de sesión y los permisos del módulo. El alojamiento y los '
          'proveedores externos se deben publicar aquí antes de activar '
          'un servicio en Internet.',
    ),
    (
      title: '5. Datos sensibles y documentos',
      body: 'No introduzcas contraseñas institucionales, expedientes, '
          'comprobantes médicos, identificaciones ni datos personales '
          'sensibles. Los justificantes y archivos se deben probar con '
          'documentos ficticios. El acceso público con datos reales exige '
          'medidas técnicas, organizativas y legales adicionales.',
    ),
    (
      title: '6. Conservación, corrección y eliminación',
      body: 'En Vista previa puedes borrar los datos locales desde el '
          'navegador. Con una cuenta, la aplicación permite consultar '
          'y modificar información del perfil y solicitar la eliminación '
          'de la cuenta; determinados registros pueden quedar disociados '
          'para conservar integridad del historial. No se ha definido '
          'todavía un calendario institucional de conservación, borrado '
          'de respaldos o atención formal de derechos. Estos puntos deben '
          'quedar establecidos antes de utilizar datos reales.',
    ),
    (
      title: '7. Servicios externos, seguridad y transferencias',
      body: 'El funcionamiento puede depender de servicios de alojamiento '
          'web, base de datos y almacenamiento elegidos por quien despliegue '
          'la aplicación. El prototipo aún no tiene una lista definitiva '
          'de proveedores, transferencias ni ubicaciones de procesamiento. '
          'Para uso público se debe utilizar HTTPS, restringir accesos, '
          'configurar secretos, respaldos y una política de retención.',
    ),
    (
      title: '8. Derechos y vías de atención',
      body: 'Para los datos del prototipo, consulta al responsable efectivo '
          'de la instancia que estés utilizando. Hasta que exista un '
          'contacto verificado, esta demostración no constituye un canal '
          'formal de solicitudes ARCO. Los derechos sobre datos de sistemas '
          'oficiales de la UTTEC se atienden conforme a los canales y avisos '
          'de esa institución; este proyecto no recibe solicitudes en su nombre.',
    ),
    (
      title: '9. Aviso oficial y fecha',
      body: 'Esta información, versión 2.0 del 23 de noviembre de 2026, '
          'describe únicamente el prototipo. Para conocer cómo la UTTEC '
          'trata datos en sus propios servicios, consulta su aviso '
          'institucional publicado en el portal oficial. No debe '
          'confundirse con este documento de prueba.',
    ),
  ];

  @override
  Widget build(BuildContext context) {
    final textTheme = Theme.of(context).textTheme;
    return ListView(
      padding: const EdgeInsets.all(24),
      children: [
        Center(
          child: ConstrainedBox(
            constraints: const BoxConstraints(maxWidth: 760),
            child: Card(
              margin: EdgeInsets.zero,
              child: Padding(
                padding: const EdgeInsets.all(24),
                child: SelectionArea(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: [
                      Text('Privacidad de PIUTTEC 2.0 — Prototipo académico',
                          style: textTheme.titleLarge),
                      const SizedBox(height: 8),
                      Text('Versión 2.0 · 23 de noviembre de 2026 · No oficial',
                          style: textTheme.bodySmall),
                      const SizedBox(height: 12),
                      const Text('Usa únicamente cuentas, materias y archivos ficticios. '
                          'Este texto es informativo y no sustituye un aviso de '
                          'privacidad validado para un servicio público.'),
                      for (final section in _sections) ...[
                        const SizedBox(height: 20),
                        Semantics(
                          header: true,
                          child: Text(section.title, style: textTheme.titleMedium),
                        ),
                        const SizedBox(height: 6),
                        Text(section.body, style: textTheme.bodyMedium),
                      ],
                      const SizedBox(height: 16),
                      Text('Referencia: aviso institucional publicado por UTTEC',
                          style: textTheme.titleSmall),
                      const SizedBox(height: 8),
                      SelectableText(officialNoticeUrl),
                      Align(
                        alignment: Alignment.centerLeft,
                        child: TextButton.icon(
                          onPressed: () => Clipboard.setData(
                            const ClipboardData(text: officialNoticeUrl)),
                          icon: const Icon(Icons.copy_outlined),
                          label: const Text('Copiar enlace al aviso oficial'),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ),
        ),
      ],
    );
  }
}
