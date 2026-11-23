/* PIUTTEC 2.0 — Información de privacidad del prototipo (NO institucional). */
(function () {
  'use strict';

  const VERSION = '2.0';
  const CONSENT_KEY = 'PIUTTEC_PRIVACY_INFO_V2';
  const OLD_KEY = 'PIUTTEC_PRIVACY_V1';
  const OFFICIAL_NOTICE = 'https://uttecamac.edomex.gob.mx/sites/uttecamac.edomex.gob.mx/files/files/PDFs/DPL/SLIDERS/AVISO_DE_PRIVACIDAD_UTTEC.pdf';
  let preferences = {};
  let persisted = true;

  try {
    const saved = JSON.parse(localStorage.getItem(CONSENT_KEY));
    if (saved && saved.version === VERSION) preferences = saved;
  } catch {
    // Sin acceso a localStorage, se permite leer el documento en esta sesión.
  }

  function saveRead() {
    preferences = { version: VERSION, fecha: new Date().toISOString() };
    try {
      localStorage.setItem(CONSENT_KEY, JSON.stringify(preferences));
      persisted = true;
    } catch {
      persisted = false;
    }
    refreshConsentInfo();
  }

  const summary = `
<p><strong>PIUTTEC 2.0 es un prototipo académico no oficial.</strong> No está autorizado para representar a la Universidad Tecnológica de Tecámac ni reemplaza sus sistemas institucionales.</p>
<p class="mt-2">En la vista previa, parte de la información se almacena en este navegador. Si usas una cuenta de prueba, los datos pueden enviarse a Django y guardarse en la base de datos configurada por quien opera esta instalación.</p>
<p class="mt-2"><strong>Utiliza exclusivamente datos y archivos ficticios.</strong> La lectura de este texto no equivale a una autorización institucional ni a un consentimiento general para otros tratamientos.</p>`;

  const details = `
<p class="mt-2"><strong>Información de privacidad del prototipo, versión 2.0 · 23 de noviembre de 2026.</strong> Este documento describe PIUTTEC 2.0 como práctica académica, no como servicio oficial de UTTEC.</p>
<h3 class="font-bold text-sm mt-4">1. Responsable del entorno</h3>
<p>PIUTTEC 2.0 es un proyecto académico independiente. La persona o entidad que publique una instancia y administre el servidor debe identificarse como responsable efectivo del tratamiento. Antes de habilitar una instancia pública se deben declarar su nombre, domicilio y contacto verificable. <strong>La UTTEC no debe presentarse como operadora de este prototipo sin autorización.</strong></p>
<h3 class="font-bold text-sm mt-4">2. Información que puede registrarse</h3>
<p>Nombre, usuario, correo electrónico, contraseña (almacenada en Django como hash), materias, grupos, notas, horarios, asistencias, tareas, reservas, justificantes, documentos y resultados de aprendizaje. No uses datos ni contraseñas institucionales reales.</p>
<h3 class="font-bold text-sm mt-4">3. Finalidades del prototipo</h3>
<p>Demostrar registro y autenticación, gestión académica, seguimiento de actividades, reservas, justificantes, archivos y refuerzo académico. No se emiten calificaciones o asistencias oficiales ni se realizan encuestas, tutorías o campañas de comunicación.</p>
<h3 class="font-bold text-sm mt-4">4. Almacenamiento y acceso</h3>
<p>Los datos de la <strong>vista previa</strong> se guardan en el navegador. Los datos de una <strong>cuenta de prueba</strong> se transmiten a la API Django y se almacenan en la base de datos configurada (SQLite local o PostgreSQL). Los archivos de cuentas pueden conservarse en el servidor. Las restricciones de acceso se gestionan por autenticación y roles; su seguridad debe evaluarse antes de cualquier despliegue público.</p>
<h3 class="font-bold text-sm mt-4">5. Documentos y datos sensibles</h3>
<p>No subas justificantes médicos, identificaciones, expedientes ni otros datos sensibles reales. Emplea únicamente archivos ficticios y contraseñas creadas para pruebas.</p>
<h3 class="font-bold text-sm mt-4">6. Conservación y eliminación</h3>
<p>Desde esta sección puedes exportar o borrar el estado local del prototipo HTML. Esto <strong>no elimina datos registrados en Django</strong>. En la aplicación Flutter, la cuenta tiene opciones para consultar, editar o eliminar su perfil; parte del historial puede quedar disociado por integridad. Todavía no se ha definido un plazo operativo de conservación o borrado de respaldos.</p>
<h3 class="font-bold text-sm mt-4">7. Servicios externos y seguridad</h3>
<p>El prototipo HTML carga bibliotecas y fuentes de terceros. Un despliegue web podría usar servicios externos de frontend, API, base de datos y almacenamiento que deben declararse antes de operar con personas reales. Se requiere HTTPS, protección de secretos, controles de acceso y respaldos adecuados.</p>
<h3 class="font-bold text-sm mt-4">8. Consultas sobre datos y derechos</h3>
<p>Para los datos de este prototipo consulta directamente a la persona que administra la instancia. Mientras no se haya identificado públicamente a ese responsable, esta demostración no ofrece un canal formal para solicitudes ARCO. No envíes a UTTEC solicitudes sobre registros de prueba alojados por terceros.</p>
<h3 class="font-bold text-sm mt-4">9. Aviso institucional de UTTEC</h3>
<p>El tratamiento de datos en los sistemas <strong>oficiales</strong> de UTTEC es independiente. Puedes consultar el <a class="underline text-brand-400" href="${OFFICIAL_NOTICE}" target="_blank" rel="noopener noreferrer">aviso de privacidad publicado por UTTEC</a>, sin confundirlo con la presente información.</p>
<h3 class="font-bold text-sm mt-4">10. Cambios y preparación del despliegue</h3>
<p>Versión 2.0 (23/11/2026). Antes de publicar la plataforma con usuarios reales debe revisarse este texto, identificar al operador, confirmar proveedores, plazos y transferencias, y preparar un aviso legal aplicable. La casilla de lectura de la demo no sustituye esos requisitos.</p>`;

  const main = document.querySelector('main');
  if (!main) return;

  if (!document.getElementById('view-privacidad')) {
    const section = document.createElement('section');
    section.id = 'view-privacidad';
    section.className = 'tab-view hidden fade-in space-y-6';
    section.innerHTML = `
      <div class="max-w-3xl mx-auto space-y-6">
        <div class="bg-white dark:bg-slate-800 p-5 rounded-2xl border border-slate-200/80 dark:border-slate-700">
          <h2 class="text-lg font-bold" id="privNoticeTitle" tabindex="-1">Privacidad del prototipo — Información completa</h2>
          <div class="text-sm text-slate-700 dark:text-slate-200 leading-relaxed">${details}</div>
        </div>
        <div class="bg-white dark:bg-slate-800 p-5 rounded-2xl border border-slate-200/80 dark:border-slate-700 space-y-4">
          <h2 class="text-lg font-bold">Datos locales de esta demostración</h2>
          <p class="text-xs text-slate-500 dark:text-slate-400" id="privConsentInfo" role="status"></p>
          <button type="button" id="privRead" class="px-4 py-2 rounded-xl bg-brand-600 hover:bg-brand-700 text-white text-xs font-semibold">Confirmar que leí la información</button>
          <p class="text-xs text-slate-500 dark:text-slate-400">Exportar o borrar aquí afecta únicamente el estado de este prototipo HTML en este navegador. No modifica cuentas ni registros guardados en Django.</p>
          <div class="flex flex-wrap gap-2 text-xs">
            <button type="button" id="privExport" class="px-4 py-2 rounded-xl bg-brand-600 hover:bg-brand-700 text-white font-semibold"><i class="fa-solid fa-download mr-1"></i>Exportar datos locales</button>
            <button type="button" id="privDelete" class="px-4 py-2 rounded-xl bg-rose-600 hover:bg-rose-700 text-white font-semibold"><i class="fa-regular fa-trash-can mr-1"></i>Borrar datos locales</button>
          </div>
        </div>
      </div>`;
    main.appendChild(section);
  }

  const navLinks = document.getElementById('navLinks');
  if (navLinks && !navLinks.querySelector('[data-tab="privacidad"]')) {
    const navBtn = document.createElement('button');
    navBtn.type = 'button';
    navBtn.dataset.tab = 'privacidad';
    navBtn.className = 'nav-btn w-full flex items-center justify-between px-3 py-2.5 rounded-xl text-sm font-medium text-slate-600 dark:text-slate-300 hover:bg-slate-100 dark:hover:bg-slate-800 transition-all';
    navBtn.innerHTML = `<div class="flex items-center gap-3"><i class="fa-solid fa-user-shield w-5 text-center" aria-hidden="true"></i><span>Privacidad del prototipo</span></div>`;
    navBtn.onclick = () => {
      if (typeof switchTab === 'function') switchTab('privacidad');
    };
    navLinks.appendChild(navBtn);
  }

  const sidebar = document.getElementById('sidebar');
  if (sidebar && !sidebar.querySelector('[data-privacy-footer]')) {
    const footerLink = document.createElement('button');
    footerLink.type = 'button';
    footerLink.dataset.privacyFooter = 'true';
    footerLink.className = 'w-full text-center text-[11px] text-slate-500 dark:text-slate-400 hover:underline py-2';
    footerLink.textContent = 'Privacidad del prototipo';
    footerLink.onclick = () => {
      if (typeof switchTab === 'function') switchTab('privacidad');
    };
    sidebar.appendChild(footerLink);
  }
  if (typeof tabTitles !== 'undefined') {
    tabTitles.privacidad = 'Privacidad del prototipo académico';
  }

  let modal = document.getElementById('modalPrivacidad');
  if (!modal) {
    modal = document.createElement('dialog');
    modal.id = 'modalPrivacidad';
    modal.className = 'm-auto w-[calc(100%_-_2rem)] max-w-lg max-h-[90vh] overflow-y-auto rounded-2xl bg-white dark:bg-slate-800 text-slate-900 dark:text-slate-100 p-6 shadow-xl backdrop:bg-slate-900/70';
    modal.setAttribute('aria-modal', 'true');
    modal.setAttribute('aria-labelledby', 'privModalTitle');
    modal.innerHTML = `
      <div>
        <h3 id="privModalTitle" class="font-bold text-base flex items-center gap-2"><i class="fa-solid fa-user-shield text-brand-600"></i> Información de privacidad</h3>
        <div class="text-xs text-slate-700 dark:text-slate-200 leading-relaxed mt-3">${summary}</div>
        <div class="flex flex-wrap justify-end gap-2 pt-4 text-xs">
          <button type="button" id="privModalLeer" class="px-4 py-2 rounded-xl border border-slate-200 dark:border-slate-700 font-medium">Leer información completa</button>
          <button type="button" id="privModalOk" class="px-4 py-2 rounded-xl bg-brand-600 hover:bg-brand-700 text-white font-semibold">Confirmo lectura y continuar</button>
        </div>
      </div>`;
    document.body.appendChild(modal);
  }

  const readButton = document.getElementById('privRead');
  function refreshConsentInfo() {
    const readAt = preferences.fecha && new Date(preferences.fecha);
    const read = Boolean(readAt && Number.isFinite(readAt.getTime()));
    document.getElementById('privConsentInfo').textContent = (read
      ? `Lectura de la versión ${VERSION} registrada el ${readAt.toLocaleString('es-MX')}.`
      : 'Lectura de esta versión pendiente.') + (persisted ? '' : ' No se pudo guardar en el navegador.');
    readButton.hidden = read;
  }

  document.getElementById('privModalOk').onclick = () => {
    saveRead();
    modal.close();
  };
  document.getElementById('privModalLeer').onclick = () => {
    modal.close();
    if (typeof switchTab === 'function') switchTab('privacidad');
    document.getElementById('privNoticeTitle')?.focus();
  };
  readButton.onclick = () => {
    saveRead();
    document.getElementById('privNoticeTitle')?.focus();
  };

  document.getElementById('privExport').onclick = () => {
    const data = {
      exportado: new Date().toISOString(),
      informacion_privacidad: preferences,
      datos: typeof appState !== 'undefined' ? appState : {},
    };
    const blob = new Blob([JSON.stringify(data, null, 2)], { type: 'application/json' });
    const url = URL.createObjectURL(blob);
    const link = document.createElement('a');
    link.href = url;
    link.download = 'mis_datos_piuttec_local.json';
    link.click();
    setTimeout(() => URL.revokeObjectURL(url), 1000);
    if (typeof showToast === 'function') showToast('Datos locales exportados', 'success');
  };

  document.getElementById('privDelete').onclick = () => {
    if (!confirm('¿Borrar los datos de esta demo HTML en el navegador? Esto no borra cuentas ni registros Django.')) return;
    try {
      if (typeof STORAGE_KEY !== 'undefined') localStorage.removeItem(STORAGE_KEY);
      localStorage.removeItem(CONSENT_KEY);
      localStorage.removeItem(OLD_KEY);
    } catch {
      if (typeof showToast === 'function') showToast('El navegador impidió borrar los datos locales', 'error');
      return;
    }
    location.reload();
  };

  refreshConsentInfo();
  if (!readButton.hidden && typeof modal.showModal === 'function') modal.showModal();
})();
