/* ==========================================================================
   PIUTTEC 2.0 - LÓGICA PRINCIPAL E INTERACTIVIDAD (Script_Main.js)
   ========================================================================== */

const STORAGE_KEY = 'piuttec_v2_state_2026';

const defaultState = {
    darkMode: null, // null = detecta preferencia del sistema operativo automáticamente
    materias: [
        { id: 'm1', codigo: 'TICS-901', nombre: 'Bases de Datos Distribuidas', profesor: 'MTI Jesús E. Romero', email: 'j.romero@uttec.edu.mx', cubiculo: 'Edif. D - Cub. 12', asesoria: 'Mar y Jue 14:00-15:00', salon: 'Lab Cómputo 2', horario: 'Lun y Mié 15:00 - 17:00', nota: 9.5, grupal: 8.2, p: 18, r: 1, j: 0, f: 1, color: '#4f46e5' },
        { id: 'm2', codigo: 'TICS-902', nombre: 'Extracción y Visualización de Datos', profesor: 'Dra. Elena Ríos', email: 'e.rios@uttec.edu.mx', cubiculo: 'Edif. D - Cub. 04', asesoria: 'Lun y Mié 17:00-18:00', salon: 'Lab Big Data A-102', horario: 'Mar y Jue 15:00 - 17:00', nota: 9.8, grupal: 8.5, p: 20, r: 0, j: 0, f: 0, color: '#0ea5e9' },
        { id: 'm3', codigo: 'TICS-903', nombre: 'Seguridad en Redes y Criptografía', profesor: 'Ing. Carlos Mendoza', email: 'c.mendoza@uttec.edu.mx', cubiculo: 'Edif. B - Cub. 08', asesoria: 'Vie 15:00-16:30', salon: 'Lab Redes B-204', horario: 'Lun y Mié 17:00 - 19:00', nota: 8.7, grupal: 7.9, p: 15, r: 2, j: 1, f: 2, color: '#10b981' },
        { id: 'm4', codigo: 'TICS-904', nombre: 'Desarrollo Web Fullstack', profesor: 'Mtra. Laura Sánchez', email: 'l.sanchez@uttec.edu.mx', cubiculo: 'Edif. D - Cub. 09', asesoria: 'Mar 17:00-18:30', salon: 'Aula Audiovisual 3', horario: 'Mar y Jue 17:00 - 19:00', nota: 9.2, grupal: 8.4, p: 19, r: 0, j: 0, f: 1, color: '#8b5cf6' },
        { id: 'm5', codigo: 'TICS-905', nombre: 'Gestión de Proyectos de TI (Scrum)', profesor: 'Dr. Roberto Méndez', email: 'r.mendez@uttec.edu.mx', cubiculo: 'Edif. C - Cub. 02', asesoria: 'Jue 19:00-20:00', salon: 'Aula C-105', horario: 'Lun y Mié 19:00 - 21:00', nota: 8.9, grupal: 8.6, p: 17, r: 1, j: 0, f: 2, color: '#f59e0b' },
        { id: 'm6', codigo: 'TICS-906', nombre: 'Inglés Técnico VIII', profesor: 'Lic. Patricia Ortega', email: 'p.ortega@uttec.edu.mx', cubiculo: 'Centro de Idiomas', asesoria: 'Vie 17:00-18:00', salon: 'Lab Idiomas 1', horario: 'Vie 16:00 - 19:00', nota: 8.5, grupal: 8.0, p: 14, r: 1, j: 0, f: 3, color: '#ec4899' }
    ],
    asistenciaLogs: [
        { id: 'al1', materia: 'Bases de Datos Distribuidas', tipo: 'P', fecha: '2026-11-13', hora: '15:04' },
        { id: 'al2', materia: 'Extracción y Visualización de Datos', tipo: 'P', fecha: '2026-11-12', hora: '15:01' },
        { id: 'al3', materia: 'Seguridad en Redes y Criptografía', tipo: 'R', fecha: '2026-11-11', hora: '17:14' }
    ],
    archivos: [
        { id: 'f1', titulo: 'Replicacion_PostgreSQL_3Nodos.pdf', materia: 'Bases de Datos Distribuidas', categoria: 'Prácticas', size: '3.4 MB', fecha: '2026-11-14', ext: 'PDF' },
        { id: 'f2', titulo: 'Dashboard_Ventas_PowerBI.pbix', materia: 'Extracción y Visualización de Datos', categoria: 'Tareas', size: '14.8 MB', fecha: '2026-11-13', ext: 'PBIX' },
        { id: 'f3', titulo: 'Apuntes_Firewall_VLANs_Cisco.pdf', materia: 'Seguridad en Redes y Criptografía', categoria: 'Apuntes', size: '2.1 MB', fecha: '2026-11-10', ext: 'PDF' },
        { id: 'f4', titulo: 'API_REST_SpringBoot_JWT.zip', materia: 'Desarrollo Web Fullstack', categoria: 'Prácticas', size: '8.6 MB', fecha: '2026-11-09', ext: 'ZIP' },
        { id: 'f5', titulo: 'Guia_Scrum_SprintReview.pdf', materia: 'Gestión de Proyectos de TI (Scrum)', categoria: 'Guías', size: '1.9 MB', fecha: '2026-11-05', ext: 'PDF' },
        { id: 'f6', titulo: 'ETL_Pentaho_DataWarehouse.ktr', materia: 'Extracción y Visualización de Datos', categoria: 'Prácticas', size: '4.2 MB', fecha: '2026-11-04', ext: 'KTR' },
        { id: 'f7', titulo: 'Technical_Vocabulary_IT.docx', materia: 'Inglés Técnico VIII', categoria: 'Apuntes', size: '1.1 MB', fecha: '2026-11-02', ext: 'DOCX' },
        { id: 'f8', titulo: 'Esquema_Dimensional_Chinook.sql', materia: 'Bases de Datos Distribuidas', categoria: 'Tareas', size: '0.8 MB', fecha: '2026-10-30', ext: 'SQL' }
    ],
    recursos: [
        { id: 'r1', nombre: 'Lab Cómputo 2 (30 Workstations)', categoria: 'Salón', ubicacion: 'Edificio D - Planta Alta', disponible: true, specs: 'Core i7 • 32GB RAM • PostgreSQL/Docker' },
        { id: 'r2', nombre: 'Lab Redes Cisco & Fibra Óptica', categoria: 'Salón', ubicacion: 'Edificio B - Aula 204', disponible: true, specs: 'Routers ISR 4321 • Switches Catalyst' },
        { id: 'r3', nombre: 'Laptop Dell Latitude 5540 #08', categoria: 'Equipo', ubicacion: 'Centro de Cómputo', disponible: true, specs: 'i7 13th Gen • 16GB RAM • Cargador USB-C' },
        { id: 'r4', nombre: 'Sala Audiovisual / Pitch Room', categoria: 'Salón', ubicacion: 'Edificio A - Planta Baja', disponible: false, specs: 'Proyector 4K • Audio • Cap. 45 personas' },
        { id: 'r5', nombre: 'Kit Raspberry Pi 5 + Sensores IoT', categoria: 'Equipo', ubicacion: 'Lab Electrónica', disponible: true, specs: '8GB RAM • Protoboard • Módulos NFC/WiFi' },
        { id: 'r6', nombre: 'Proyector Epson PowerLite HD', categoria: 'Equipo', ubicacion: 'Almacén Académico', disponible: true, specs: '3800 Lúmenes • HDMI + Adaptador' }
    ],
    prestamos: [
        { id: 'PR-2026-104', recurso: 'Laptop Dell Latitude 5540 #04', categoria: 'Equipo', fecha: '2026-11-16', horario: '15:00 - 19:00', motivo: 'Práctica de replicación PostgreSQL en VirtualBox', estado: 'Aprobado' },
        { id: 'PR-2026-109', recurso: 'Lab Cómputo 2 (30 Workstations)', categoria: 'Salón', fecha: '2026-11-18', horario: '17:00 - 19:00', motivo: 'Pruebas de integración equipo PIUTTEC 2.0', estado: 'En Uso' }
    ],
    tramites: [
        { id: 'TR-8841', tipo: 'Constancia de Estudios Vigente', detalle: 'Folio UTT-2026-8841 • Validado por Control Escolar', fecha: '2026-11-08', estado: 'Emitido' },
        { id: 'TR-8790', tipo: 'Justificante Médico IMSS', detalle: 'Seguridad en Redes y Criptografía • UMF-68', fecha: '2026-10-24', estado: 'Aplicado' }
    ],
    tareas: [
        { id: 't1', titulo: 'Implementar Replicación Maestro-Esclavo en PostgreSQL + schtasks', materia: 'Bases de Datos Distribuidas', fecha: '2026-11-19', prioridad: 'Alta', completada: false },
        { id: 't2', titulo: 'Entregar Dashboard Power BI + Tableau y Video Explicativo', materia: 'Extracción y Visualización de Datos', fecha: '2026-11-20', prioridad: 'Alta', completada: false },
        { id: 't3', titulo: 'Configurar ACLs extendidas y VPN Site-to-Site en Packet Tracer', materia: 'Seguridad en Redes y Criptografía', fecha: '2026-11-22', prioridad: 'Media', completada: false },
        { id: 't4', titulo: 'Transformación ETL y carga a Data Warehouse en Pentaho Spoon', materia: 'Extracción y Visualización de Datos', fecha: '2026-11-05', prioridad: 'Alta', completada: true }
    ],
    notificaciones: [
        { id: 'n1', titulo: 'Préstamo aprobado', desc: 'Tu solicitud PR-2026-104 (Laptop Dell #04) fue aprobada.', tiempo: 'Hace 25 min', leida: false },
        { id: 'n2', titulo: 'Entrega próxima (Semana 13)', desc: 'Proyecto adicional de Bases de Datos vence el 19 de noviembre.', tiempo: 'Hace 2 hrs', leida: false },
        { id: 'n3', titulo: 'Calificación publicada', desc: 'Dra. Elena Ríos registró 9.8 en Extracción de Datos.', tiempo: 'Ayer', leida: true }
    ]
};

let appState = loadState();
let currentFileCategory = 'ALL';
let currentResourceFilter = 'ALL';
let gradesChartInstance = null;
let pomodoroSeconds = 25 * 60;
let pomodoroInterval = null;

function loadState() {
    try {
        const saved = localStorage.getItem(STORAGE_KEY);
        if (saved) return JSON.parse(saved);
    } catch (e) {
        console.warn('Error leyendo localStorage', e);
    }
    return JSON.parse(JSON.stringify(defaultState));
}

function saveState() {
    try {
        localStorage.setItem(STORAGE_KEY, JSON.stringify(appState));
    } catch (e) {
        console.warn('Error guardando localStorage', e);
    }
}

function resetDemoData() {
    localStorage.removeItem(STORAGE_KEY);
    appState = JSON.parse(JSON.stringify(defaultState));
    applyTheme();
    renderAll();
    showToast('Datos restaurados al estado inicial de demostración.', 'info');
}

/* ==========================================================
   GESTIÓN DE MODO OSCURO (MANUAL + DETECCIÓN DEL SISTEMA)
   ========================================================== */
function isDarkModeActive() {
    if (typeof appState.darkMode === 'boolean') {
        return appState.darkMode;
    }
    return window.matchMedia && window.matchMedia('(prefers-color-scheme: dark)').matches;
}

function toggleDarkMode() {
    const nextDark = !isDarkModeActive();
    appState.darkMode = nextDark;
    saveState();
    applyTheme();
    updateGradesChart();
    showToast(nextDark ? 'Modo oscuro activado' : 'Modo claro activado', 'info');
}

function applyTheme() {
    const html = document.documentElement;
    const icon = document.getElementById('themeIcon');
    const toggleBtn = document.getElementById('darkModeToggleBtn');
    const dark = isDarkModeActive();

    if (dark) {
        html.classList.add('dark');
        html.classList.remove('light');
        if (icon) icon.className = 'fa-solid fa-sun text-amber-400';
        if (toggleBtn) toggleBtn.setAttribute('aria-pressed', 'true');
    } else {
        html.classList.remove('dark');
        html.classList.add('light');
        if (icon) icon.className = 'fa-solid fa-moon';
        if (toggleBtn) toggleBtn.setAttribute('aria-pressed', 'false');
    }
}

// Escucha cambios del tema del sistema operativo si el usuario no forzó uno manualmente
if (window.matchMedia) {
    window.matchMedia('(prefers-color-scheme: dark)').addEventListener('change', () => {
        if (appState.darkMode === null) {
            applyTheme();
            updateGradesChart();
        }
    });
}

/* ==========================================================
   NAVEGACIÓN Y SIDEBAR MÓVIL
   ========================================================== */
function switchTab(tabId) {
    document.querySelectorAll('.tab-view').forEach(el => el.classList.add('hidden'));
    const target = document.getElementById(`view-${tabId}`);
    if (target) target.classList.remove('hidden');

    document.querySelectorAll('.nav-btn').forEach(btn => {
        const isSelected = btn.getAttribute('data-tab') === tabId;
        btn.className = isSelected
            ? 'nav-btn w-full flex items-center justify-between px-3 py-2.5 rounded-xl text-sm font-semibold transition-all bg-brand-50 text-brand-600 dark:bg-brand-900/30 dark:text-brand-400'
            : 'nav-btn w-full flex items-center justify-between px-3 py-2.5 rounded-xl text-sm font-medium text-slate-600 dark:text-slate-300 hover:bg-slate-100 dark:hover:bg-slate-800 transition-all';
    });

    if (tabId === 'dashboard') updateGradesChart();
    closeMobileSidebar();
}

function toggleMobileSidebar() {
    const sidebar = document.getElementById('sidebar');
    const overlay = document.getElementById('sidebarOverlay');
    const isHidden = sidebar.classList.contains('-translate-x-full');
    if (isHidden) {
        sidebar.classList.remove('-translate-x-full');
        overlay.classList.remove('hidden');
    } else {
        sidebar.classList.add('-translate-x-full');
        overlay.classList.add('hidden');
    }
}

function closeMobileSidebar() {
    document.getElementById('sidebar')?.classList.add('-translate-x-full');
    document.getElementById('sidebarOverlay')?.classList.add('hidden');
}

/* ==========================================================
   MODALES Y NOTIFICACIONES TOAST
   ========================================================== */
function openModal(id) { document.getElementById(id)?.classList.remove('hidden'); }
function closeModal(id) { document.getElementById(id)?.classList.add('hidden'); }

function openReservaModal(preselectedResource = null) {
    populateSelects();
    if (preselectedResource) {
        document.getElementById('reservaResourceSelect').value = preselectedResource;
    }
    openModal('modalReserva');
}
function openUploadModal() { populateSelects(); openModal('modalUpload'); }
function openMateriaModal() { openModal('modalMateria'); }
function openTaskModal() { populateSelects(); openModal('modalTask'); }

function showToast(message, type = 'success') {
    const container = document.getElementById('toastContainer');
    if (!container) return;
    const colors = {
        success: 'bg-emerald-600 text-white',
        warning: 'bg-amber-600 text-white',
        danger: 'bg-rose-600 text-white',
        info: 'bg-slate-800 text-white dark:bg-brand-600'
    };
    const icons = {
        success: 'fa-circle-check',
        warning: 'fa-triangle-exclamation',
        danger: 'fa-circle-xmark',
        info: 'fa-circle-info'
    };
    const toast = document.createElement('div');
    toast.className = `${colors[type] || colors.info} px-4 py-3 rounded-2xl shadow-xl text-xs font-semibold flex items-center gap-2.5 fade-in pointer-events-auto`;
    toast.innerHTML = `<i class="fa-solid ${icons[type] || icons.info} text-sm"></i><span>${message}</span>`;
    container.appendChild(toast);
    setTimeout(() => {
        toast.style.opacity = '0';
        toast.style.transition = 'opacity 0.3s ease';
        setTimeout(() => toast.remove(), 300);
    }, 3200);
}

/* ==========================================================
   CÁLCULOS ACADÉMICOS Y KPIs
   ========================================================== */
function calcMateriaAsistenciaPct(m) {
    const penalizacionRetardos = Math.floor(m.r / 3);
    const totalSesiones = m.p + m.r + m.j + m.f;
    if (totalSesiones === 0) return 100;
    const asistenciasValidas = Math.max(0, (m.p + m.r + m.j) - penalizacionRetardos);
    return Math.round((asistenciasValidas / totalSesiones) * 100);
}

function calcGlobalAverage() {
    if (!appState.materias.length) return 0;
    const sum = appState.materias.reduce((acc, m) => acc + Number(m.nota || 0), 0);
    return (sum / appState.materias.length).toFixed(1);
}

function calcGlobalAttendance() {
    if (!appState.materias.length) return 100;
    const sum = appState.materias.reduce((acc, m) => acc + calcMateriaAsistenciaPct(m), 0);
    return Math.round(sum / appState.materias.length);
}

/* ==========================================================
   RENDERIZADO GENERAL
   ========================================================== */
function renderAll() {
    populateSelects();
    renderDashboard();
    renderMaterias();
    renderHorario();
    renderAsistencias();
    renderFiles();
    renderReservas();
    renderTramites();
    renderTareas();
    renderHerramientas();
    renderNotifications();
    updateBadges();
}

function updateBadges() {
    const pendingTasks = appState.tareas.filter(t => !t.completada).length;
    const activeLoans = appState.prestamos.filter(p => p.estado !== 'Devuelto').length;
    const avg = calcGlobalAverage();
    const att = calcGlobalAttendance();
    const hasRisk = appState.materias.some(m => calcMateriaAsistenciaPct(m) < 80);

    document.getElementById('badgeMaterias').textContent = appState.materias.length;
    document.getElementById('badgeArchivos').textContent = appState.archivos.length;
    document.getElementById('badgeTareas').textContent = pendingTasks;
    document.getElementById('badgeReservas').textContent = activeLoans;
    document.getElementById('badgeAsistenciaAlert').classList.toggle('hidden', !hasRisk);

    document.getElementById('kpiPromedioGlobal').textContent = avg;
    document.getElementById('kpiMateriasSub').textContent = `${appState.materias.length} materias cursando`;
    document.getElementById('kpiAsistencia').textContent = `${att}%`;
    document.getElementById('kpiReservas').textContent = `${activeLoans} Activos`;
    document.getElementById('kpiTareasPendientes').textContent = pendingTasks;
    document.getElementById('dashPendingCountText').textContent = `${pendingTasks} entrega${pendingTasks === 1 ? '' : 's'} pendiente${pendingTasks === 1 ? '' : 's'}`;

    const totalMB = appState.archivos.reduce((acc, f) => acc + (parseFloat(f.size) || 1.5), 0).toFixed(1);
    const pct = Math.min(100, Math.round((totalMB / 5120) * 100) + 12);
    document.getElementById('storageText').textContent = `${totalMB} MB / 5 GB`;
    document.getElementById('storageBar').style.width = `${pct}%`;
}

function populateSelects() {
    const materiaOptions = appState.materias.map(m => `<option value="${m.nombre}">${m.nombre} (${m.codigo})</option>`).join('');
    const materiaIdOptions = appState.materias.map(m => `<option value="${m.id}">${m.nombre} (${m.codigo})</option>`).join('');

    ['fileSubjectFilter', 'uploadFileSubject', 'taskMateriaSelect'].forEach(id => {
        const el = document.getElementById(id);
        if (!el) return;
        const prefix = id === 'fileSubjectFilter' ? '<option value="ALL">Todas las materias</option>' : '';
        el.innerHTML = prefix + materiaOptions;
    });

    const justSelect = document.getElementById('justificanteMateriaSelect');
    if (justSelect) justSelect.innerHTML = materiaIdOptions;

    const resSelect = document.getElementById('reservaResourceSelect');
    if (resSelect) {
        resSelect.innerHTML = appState.recursos
            .filter(r => r.disponible)
            .map(r => `<option value="${r.nombre}">${r.nombre} — ${r.ubicacion}</option>`).join('');
    }
}

/* --- 1. DASHBOARD --- */
function renderDashboard() {
    const activeLoans = appState.prestamos.filter(p => p.estado !== 'Devuelto');
    const loansContainer = document.getElementById('dashboardActiveLoans');
    loansContainer.innerHTML = activeLoans.length ? activeLoans.map(l => `
        <div class="p-3 rounded-xl bg-slate-50 dark:bg-slate-800/70 border border-slate-200/70 dark:border-slate-700 flex items-center justify-between gap-2">
            <div class="overflow-hidden">
                <p class="text-xs font-bold truncate">${l.recurso}</p>
                <p class="text-[11px] text-slate-500 dark:text-slate-400">${l.fecha} • ${l.horario}</p>
            </div>
            <span class="text-[10px] font-bold px-2 py-0.5 rounded-full bg-emerald-100 text-emerald-800 dark:bg-emerald-950 dark:text-emerald-300 shrink-0">${l.estado}</span>
        </div>
    `).join('') : '<p class="text-xs text-slate-400">Sin préstamos activos actualmente.</p>';

    const upcoming = appState.tareas.filter(t => !t.completada).slice(0, 3);
    const tasksContainer = document.getElementById('dashboardUpcomingTasks');
    tasksContainer.innerHTML = upcoming.length ? upcoming.map(t => `
        <div class="p-3 rounded-xl bg-slate-50 dark:bg-slate-800/70 border border-slate-200/70 dark:border-slate-700 flex items-start justify-between gap-2">
            <div class="overflow-hidden">
                <p class="text-xs font-bold truncate">${t.titulo}</p>
                <p class="text-[11px] text-slate-500 dark:text-slate-400 truncate">${t.materia} • Límite: ${t.fecha}</p>
            </div>
            <button onclick="toggleTaskComplete('${t.id}')" class="text-xs text-emerald-600 hover:text-emerald-700 font-bold shrink-0" title="Marcar completada">
                <i class="fa-regular fa-circle-check text-base"></i>
            </button>
        </div>
    `).join('') : '<p class="text-xs text-emerald-600 font-semibold">¡Todas tus entregas están al día!</p>';

    const schedContainer = document.getElementById('dashboardScheduleList');
    schedContainer.innerHTML = appState.materias.map(m => {
        const pct = calcMateriaAsistenciaPct(m);
        const badgeColor = pct >= 80 ? 'text-emerald-600 bg-emerald-50 dark:bg-emerald-950 dark:text-emerald-400' : 'text-rose-600 bg-rose-50 dark:bg-rose-950 dark:text-rose-400';
        return `
            <div class="p-3.5 rounded-2xl border border-slate-200/80 dark:border-slate-800 bg-slate-50/50 dark:bg-slate-800/40 flex items-center justify-between gap-3">
                <div class="overflow-hidden">
                    <div class="flex items-center gap-2">
                        <span class="w-2.5 h-2.5 rounded-full shrink-0" style="background:${m.color}"></span>
                        <h4 class="text-xs font-bold truncate">${m.nombre}</h4>
                    </div>
                    <p class="text-[11px] text-slate-500 dark:text-slate-400 mt-0.5">${m.salon} • ${m.horario}</p>
                </div>
                <div class="flex items-center gap-1.5 shrink-0">
                    <span class="text-[11px] font-bold px-2 py-0.5 rounded-lg ${badgeColor}">${pct}%</span>
                    <button onclick="registerAttendance('${m.id}', 'P')" class="w-7 h-7 rounded-lg bg-emerald-600 hover:bg-emerald-700 text-white text-xs font-bold transition" title="Registrar Presente">P</button>
                    <button onclick="registerAttendance('${m.id}', 'R')" class="w-7 h-7 rounded-lg bg-amber-500 hover:bg-amber-600 text-white text-xs font-bold transition" title="Registrar Retardo">R</button>
                </div>
            </div>
        `;
    }).join('');

    updateGradesChart();
}

function updateGradesChart() {
    const ctx = document.getElementById('gradesChart');
    if (!ctx || typeof Chart === 'undefined') return;
    if (gradesChartInstance) gradesChartInstance.destroy();

    const isDark = isDarkModeActive();
    const gridColor = isDark ? 'rgba(148, 163, 184, 0.12)' : 'rgba(148, 163, 184, 0.2)';
    const textColor = isDark ? '#cbd5e1' : '#475569';

    gradesChartInstance = new Chart(ctx, {
        type: 'bar',
        data: {
            labels: appState.materias.map(m => m.codigo),
            datasets: [
                {
                    label: 'Tu Calificación',
                    data: appState.materias.map(m => m.nota),
                    backgroundColor: isDark ? '#6366f1' : '#4f46e5',
                    borderRadius: 8,
                    barPercentage: 0.55
                },
                {
                    label: 'Promedio Grupal',
                    data: appState.materias.map(m => m.grupal),
                    backgroundColor: isDark ? '#334155' : '#cbd5e1',
                    borderRadius: 8,
                    barPercentage: 0.55
                }
            ]
        },
        options: {
            responsive: true,
            maintainAspectRatio: false,
            plugins: {
                legend: { display: false },
                tooltip: {
                    callbacks: {
                        title: (items) => {
                            const idx = items[0].dataIndex;
                            return appState.materias[idx]?.nombre || '';
                        }
                    }
                }
            },
            scales: {
                y: { min: 5, max: 10, grid: { color: gridColor }, ticks: { color: textColor, font: { size: 11 } } },
                x: { grid: { display: false }, ticks: { color: textColor, font: { size: 11, weight: '600' } } }
            }
        }
    });
}

/* --- 2. MATERIAS --- */
function renderMaterias() {
    const grid = document.getElementById('materiasGrid');
    grid.innerHTML = appState.materias.map(m => {
        const pct = calcMateriaAsistenciaPct(m);
        const statusBadge = pct >= 80
            ? `<span class="text-[11px] font-bold text-emerald-700 bg-emerald-100 dark:bg-emerald-950 dark:text-emerald-300 px-2.5 py-0.5 rounded-full">Asistencia ${pct}%</span>`
            : `<span class="text-[11px] font-bold text-rose-700 bg-rose-100 dark:bg-rose-950 dark:text-rose-300 px-2.5 py-0.5 rounded-full">Riesgo ${pct}%</span>`;

        return `
            <div class="bg-white dark:bg-slate-900 rounded-2xl border border-slate-200/80 dark:border-slate-800 p-5 shadow-xs flex flex-col justify-between space-y-4">
                <div>
                    <div class="flex items-center justify-between gap-2 mb-2">
                        <span class="text-[11px] font-bold px-2.5 py-1 rounded-lg text-white" style="background:${m.color}">${m.codigo}</span>
                        ${statusBadge}
                    </div>
                    <h3 class="font-display font-bold text-base leading-snug">${m.nombre}</h3>
                    <p class="text-xs text-slate-500 dark:text-slate-400 mt-1"><i class="fa-solid fa-chalkboard-user mr-1.5 text-slate-400"></i>${m.profesor}</p>
                    <p class="text-xs text-slate-500 dark:text-slate-400 mt-0.5"><i class="fa-solid fa-location-dot mr-1.5 text-slate-400"></i>${m.salon} • ${m.horario}</p>
                </div>

                <div class="pt-3 border-t border-slate-100 dark:border-slate-800 flex items-center justify-between">
                    <div>
                        <span class="text-[11px] text-slate-400 block">Calificación Actual</span>
                        <div class="flex items-center gap-2 mt-0.5">
                            <input type="number" step="0.1" min="0" max="10" value="${m.nota}" onchange="updateMateriaGrade('${m.id}', this.value)" class="w-16 text-sm font-extrabold bg-slate-100 dark:bg-slate-800 rounded-lg px-2 py-1 text-center border border-slate-200 dark:border-slate-700">
                            <span class="text-[11px] text-slate-400">Grupal: ${m.grupal}</span>
                        </div>
                    </div>
                    <button onclick="deleteMateria('${m.id}')" class="p-2 text-slate-400 hover:text-rose-600 rounded-xl hover:bg-rose-50 dark:hover:bg-rose-950/50 transition" title="Dar de baja materia">
                        <i class="fa-solid fa-trash-can"></i>
                    </button>
                </div>
            </div>
        `;
    }).join('');
}

function updateMateriaGrade(id, newVal) {
    const val = Math.min(10, Math.max(0, parseFloat(newVal) || 0));
    const mat = appState.materias.find(m => m.id === id);
    if (mat) {
        mat.nota = Number(val.toFixed(1));
        saveState();
        renderAll();
        showToast(`Calificación de ${mat.codigo} actualizada a ${mat.nota}.`, 'success');
    }
}

function submitNewMateria(e) {
    e.preventDefault();
    const colors = ['#4f46e5', '#0ea5e9', '#10b981', '#8b5cf6', '#f59e0b', '#ec4899'];
    const nueva = {
        id: 'm' + Date.now(),
        codigo: document.getElementById('matCodigo').value.trim().toUpperCase(),
        nombre: document.getElementById('matNombre').value.trim(),
        profesor: document.getElementById('matProfesor').value.trim(),
        email: 'docente@uttec.edu.mx',
        cubiculo: 'Edif. Académico',
        asesoria: 'Previa cita',
        salon: document.getElementById('matSalon').value.trim(),
        horario: document.getElementById('matHorario').value.trim(),
        nota: 9.0,
        grupal: 8.3,
        p: 10, r: 0, j: 0, f: 0,
        color: colors[appState.materias.length % colors.length]
    };
    appState.materias.push(nueva);
    saveState();
    e.target.reset();
    closeModal('modalMateria');
    renderAll();
    showToast(`Asignatura "${nueva.nombre}" inscrita correctamente.`, 'success');
}

function deleteMateria(id) {
    if (appState.materias.length <= 1) {
        showToast('Debes mantener al menos una materia inscrita.', 'warning');
        return;
    }
    appState.materias = appState.materias.filter(m => m.id !== id);
    saveState();
    renderAll();
    showToast('Asignatura eliminada de tu carga académica.', 'info');
}

/* --- 3. HORARIO SEMANAL --- */
function renderHorario() {
    const bloques = [
        { hora: '15:00 - 17:00', lun: 'TICS-901', mar: 'TICS-902', mie: 'TICS-901', jue: 'TICS-902', vie: 'Asesorías / Lab' },
        { hora: '17:00 - 19:00', lun: 'TICS-903', mar: 'TICS-904', mie: 'TICS-903', jue: 'TICS-904', vie: 'TICS-906' },
        { hora: '19:00 - 21:00', lun: 'TICS-905', mar: 'Proyecto Int.', mie: 'TICS-905', jue: 'Proyecto Int.', vie: 'Libre' }
    ];
    const tbody = document.getElementById('scheduleTableBody');
    tbody.innerHTML = bloques.map(b => {
        const renderCell = (code) => {
            const mat = appState.materias.find(m => m.codigo === code);
            if (!mat) return `<span class="text-slate-400 italic">${code}</span>`;
            return `
                <div class="p-2.5 rounded-xl border border-slate-200/80 dark:border-slate-700 bg-slate-50/80 dark:bg-slate-800/60" style="border-left: 3px solid ${mat.color}">
                    <span class="font-bold text-slate-900 dark:text-white block">${mat.nombre}</span>
                    <span class="text-[11px] text-slate-500 dark:text-slate-400 block mt-0.5">${mat.salon}</span>
                </div>
            `;
        };
        return `
            <tr>
                <td class="py-3.5 px-4 font-bold text-slate-600 dark:text-slate-300 whitespace-nowrap">${b.hora}</td>
                <td class="py-2.5 px-3">${renderCell(b.lun)}</td>
                <td class="py-2.5 px-3">${renderCell(b.mar)}</td>
                <td class="py-2.5 px-3">${renderCell(b.mie)}</td>
                <td class="py-2.5 px-3">${renderCell(b.jue)}</td>
                <td class="py-2.5 px-3">${renderCell(b.vie)}</td>
            </tr>
        `;
    }).join('');
}

/* --- 4. ASISTENCIAS --- */
function renderAsistencias() {
    const tbody = document.getElementById('asistenciasTableBody');
    tbody.innerHTML = appState.materias.map(m => {
        const total = m.p + m.r + m.j + m.f;
        const pct = calcMateriaAsistenciaPct(m);
        const barColor = pct >= 85 ? 'bg-emerald-500' : pct >= 80 ? 'bg-amber-500' : 'bg-rose-500';
        const statusText = pct >= 80
            ? `<span class="text-xs font-bold text-emerald-600 dark:text-emerald-400">Ordinario (${pct}%)</span>`
            : `<span class="text-xs font-bold text-rose-600 dark:text-rose-400">Extraordinario (${pct}%)</span>`;

        return `
            <tr class="hover:bg-slate-50/70 dark:hover:bg-slate-800/40 transition">
                <td class="py-3.5 px-4">
                    <p class="font-bold text-xs">${m.nombre}</p>
                    <p class="text-[11px] text-slate-500">${m.codigo} • ${m.salon}</p>
                </td>
                <td class="py-3.5 px-4 text-center font-bold text-xs">${total}</td>
                <td class="py-3.5 px-4 text-center text-xs font-semibold">
                    <span class="text-emerald-600">${m.p}</span> /
                    <span class="text-amber-600">${m.r}</span> /
                    <span class="text-sky-600">${m.j}</span> /
                    <span class="text-rose-600">${m.f}</span>
                </td>
                <td class="py-3.5 px-4">
                    <div class="flex items-center justify-between mb-1">${statusText}</div>
                    <div class="w-36 h-2 bg-slate-200 dark:bg-slate-700 rounded-full overflow-hidden">
                        <div class="h-full ${barColor} rounded-full transition-all" style="width:${pct}%"></div>
                    </div>
                </td>
                <td class="py-3.5 px-4 text-right space-x-1 whitespace-nowrap">
                    <button onclick="registerAttendance('${m.id}', 'P')" class="px-2.5 py-1 rounded-lg bg-emerald-600 hover:bg-emerald-700 text-white text-xs font-bold" title="Presente">P</button>
                    <button onclick="registerAttendance('${m.id}', 'R')" class="px-2.5 py-1 rounded-lg bg-amber-500 hover:bg-amber-600 text-white text-xs font-bold" title="Retardo">R</button>
                    <button onclick="registerAttendance('${m.id}', 'J')" class="px-2.5 py-1 rounded-lg bg-sky-600 hover:bg-sky-700 text-white text-xs font-bold" title="Justificado">J</button>
                    <button onclick="registerAttendance('${m.id}', 'F')" class="px-2.5 py-1 rounded-lg bg-rose-600 hover:bg-rose-700 text-white text-xs font-bold" title="Falta">F</button>
                </td>
            </tr>
        `;
    }).join('');

    const logsContainer = document.getElementById('asistenciaHistoryLogs');
    logsContainer.innerHTML = appState.asistenciaLogs.slice(0, 6).map(log => {
        const badges = {
            P: 'bg-emerald-100 text-emerald-800 dark:bg-emerald-950 dark:text-emerald-300',
            R: 'bg-amber-100 text-amber-800 dark:bg-amber-950 dark:text-amber-300',
            J: 'bg-sky-100 text-sky-800 dark:bg-sky-950 dark:text-sky-300',
            F: 'bg-rose-100 text-rose-800 dark:bg-rose-950 dark:text-rose-300'
        };
        const labels = { P: 'Presente', R: 'Retardo', J: 'Justificado', F: 'Falta' };
        return `
            <div class="p-3 rounded-xl bg-slate-50 dark:bg-slate-800/60 border border-slate-200/70 dark:border-slate-700 flex items-center justify-between gap-2">
                <div class="overflow-hidden">
                    <p class="text-xs font-bold truncate">${log.materia}</p>
                    <p class="text-[11px] text-slate-400">${log.fecha} • ${log.hora} hrs</p>
                </div>
                <span class="text-[10px] font-bold px-2 py-0.5 rounded-full ${badges[log.tipo]}">${labels[log.tipo]}</span>
            </div>
        `;
    }).join('');
}

function registerAttendance(materiaId, tipo) {
    const mat = appState.materias.find(m => m.id === materiaId);
    if (!mat) return;
    mat[tipo.toLowerCase()] += 1;
    const fechaInput = document.getElementById('asistenciaDateInput')?.value || '2026-11-15';
    const now = new Date();
    const hora = `${String(now.getHours()).padStart(2, '0')}:${String(now.getMinutes()).padStart(2, '0')}`;
    appState.asistenciaLogs.unshift({ id: 'al' + Date.now(), materia: mat.nombre, tipo, fecha: fechaInput, hora });
    saveState();
    renderAll();
    showToast(`Asistencia (${tipo}) registrada en ${mat.codigo}.`, tipo === 'F' ? 'danger' : 'success');
}

function markAllPresentToday() {
    const fechaInput = document.getElementById('asistenciaDateInput')?.value || '2026-11-15';
    appState.materias.forEach(m => {
        m.p += 1;
        appState.asistenciaLogs.unshift({ id: 'al' + Date.now() + m.id, materia: m.nombre, tipo: 'P', fecha: fechaInput, hora: '15:00' });
    });
    saveState();
    renderAll();
    showToast('Se registró Presente (P) en todas tus asignaturas del día.', 'success');
}

/* --- 5. ARCHIVOS --- */
function setFileCategory(cat) {
    currentFileCategory = cat;
    document.querySelectorAll('.file-cat-btn').forEach(btn => {
        const active = btn.getAttribute('data-cat') === cat;
        btn.className = active
            ? 'file-cat-btn px-3.5 py-1.5 rounded-xl text-xs font-semibold bg-brand-600 text-white transition'
            : 'file-cat-btn px-3.5 py-1.5 rounded-xl text-xs font-medium bg-white dark:bg-slate-900 border border-slate-200 dark:border-slate-700 hover:bg-slate-100 dark:hover:bg-slate-800 transition';
    });
    renderFiles();
}

function renderFiles() {
    const search = (document.getElementById('fileSearchInput')?.value || '').toLowerCase();
    const subjectFilter = document.getElementById('fileSubjectFilter')?.value || 'ALL';

    const filtered = appState.archivos.filter(f => {
        const matchCat = currentFileCategory === 'ALL' || f.categoria === currentFileCategory;
        const matchSub = subjectFilter === 'ALL' || f.materia === subjectFilter;
        const matchText = f.titulo.toLowerCase().includes(search) || f.materia.toLowerCase().includes(search);
        return matchCat && matchSub && matchText;
    });

    const grid = document.getElementById('filesGrid');
    grid.innerHTML = filtered.length ? filtered.map(f => `
        <div class="bg-white dark:bg-slate-900 rounded-2xl border border-slate-200/80 dark:border-slate-800 p-4 shadow-xs hover:shadow-md transition flex flex-col justify-between space-y-3">
            <div class="flex items-start justify-between gap-2">
                <div class="w-10 h-10 rounded-xl bg-brand-50 dark:bg-brand-950 text-brand-600 dark:text-brand-400 flex items-center justify-center font-bold text-xs shrink-0">
                    ${f.ext}
                </div>
                <span class="text-[10px] font-semibold px-2 py-0.5 rounded-full bg-slate-100 dark:bg-slate-800 text-slate-600 dark:text-slate-300">${f.categoria}</span>
            </div>
            <div>
                <h4 class="text-xs font-bold truncate" title="${f.titulo}">${f.titulo}</h4>
                <p class="text-[11px] text-slate-500 dark:text-slate-400 truncate mt-0.5">${f.materia}</p>
            </div>
            <div class="pt-2.5 border-t border-slate-100 dark:border-slate-800 flex items-center justify-between text-[11px] text-slate-400">
                <span>${f.size} • ${f.fecha}</span>
                <div class="flex items-center gap-1">
                    <button onclick="downloadSimulatedFile('${f.id}')" class="p-1.5 text-brand-600 dark:text-brand-400 hover:bg-brand-50 dark:hover:bg-brand-950 rounded-lg transition" title="Descargar">
                        <i class="fa-solid fa-download"></i>
                    </button>
                    <button onclick="deleteFile('${f.id}')" class="p-1.5 text-slate-400 hover:text-rose-600 rounded-lg transition" title="Eliminar">
                        <i class="fa-solid fa-trash"></i>
                    </button>
                </div>
            </div>
        </div>
    `).join('') : '<div class="col-span-full text-center py-10 text-xs text-slate-400">No se encontraron archivos con esos filtros.</div>';
}

function handleRealFileSelect(e) {
    const file = e.target.files[0];
    if (!file) return;
    document.getElementById('selectedFileNameDisplay').textContent = `${file.name} (${(file.size / (1024 * 1024)).toFixed(2)} MB)`;
    if (!document.getElementById('uploadFileTitle').value) {
        document.getElementById('uploadFileTitle').value = file.name;
    }
}

function submitFileUpload(e) {
    e.preventDefault();
    const titulo = document.getElementById('uploadFileTitle').value.trim();
    const extMatch = titulo.split('.');
    const ext = extMatch.length > 1 ? extMatch.pop().toUpperCase().slice(0, 4) : 'DOC';
    const realFile = document.getElementById('realFileInput').files[0];
    const size = realFile ? `${Math.max(0.2, (realFile.size / (1024 * 1024))).toFixed(1)} MB` : '2.4 MB';

    appState.archivos.unshift({
        id: 'f' + Date.now(),
        titulo,
        materia: document.getElementById('uploadFileSubject').value,
        categoria: document.getElementById('uploadFileCategory').value,
        size,
        fecha: '2026-11-15',
        ext
    });
    saveState();
    e.target.reset();
    document.getElementById('selectedFileNameDisplay').textContent = 'Haz clic para seleccionar un archivo de tu dispositivo';
    closeModal('modalUpload');
    renderAll();
    showToast(`Archivo "${titulo}" guardado en la Nube Académica.`, 'success');
}

function downloadSimulatedFile(id) {
    const file = appState.archivos.find(f => f.id === id);
    if (!file) return;
    const blob = new Blob([`PIUTTEC 2.0 - Archivo Académico
Documento: ${file.titulo}
Materia: ${file.materia}
Categoría: ${file.categoria}
Fecha: ${file.fecha}
Alumno: Sofía Martínez (2026-0842)`], { type: 'text/plain;charset=utf-8' });
    const url = URL.createObjectURL(blob);
    const a = document.createElement('a');
    a.href = url;
    a.download = `${file.titulo}.txt`;
    a.click();
    URL.revokeObjectURL(url);
    showToast(`Descargando "${file.titulo}"...`, 'info');
}

function deleteFile(id) {
    appState.archivos = appState.archivos.filter(f => f.id !== id);
    saveState();
    renderAll();
    showToast('Archivo eliminado del repositorio.', 'info');
}

/* --- 6. RESERVAS DE SALONES Y EQUIPOS --- */
function filterResources(cat) {
    currentResourceFilter = cat;
    document.querySelectorAll('.res-filter-btn').forEach(btn => {
        const active = btn.getAttribute('data-res') === cat;
        btn.className = active
            ? 'res-filter-btn px-3.5 py-1.5 rounded-xl text-xs font-semibold bg-brand-600 text-white'
            : 'res-filter-btn px-3.5 py-1.5 rounded-xl text-xs font-medium bg-slate-100 dark:bg-slate-800 text-slate-700 dark:text-slate-200';
    });
    renderReservas();
}

function renderReservas() {
    const filtered = appState.recursos.filter(r => currentResourceFilter === 'ALL' || r.categoria === currentResourceFilter);
    document.getElementById('resourcesCatalogGrid').innerHTML = filtered.map(r => `
        <div class="bg-white dark:bg-slate-900 rounded-2xl border border-slate-200/80 dark:border-slate-800 p-4 shadow-xs flex flex-col justify-between space-y-3">
            <div>
                <div class="flex items-center justify-between mb-2">
                    <span class="text-[10px] font-bold uppercase px-2 py-0.5 rounded-md bg-slate-100 dark:bg-slate-800 text-slate-600 dark:text-slate-300">${r.categoria}</span>
                    <span class="text-[10px] font-bold px-2 py-0.5 rounded-full ${r.disponible ? 'bg-emerald-100 text-emerald-800 dark:bg-emerald-950 dark:text-emerald-300' : 'bg-rose-100 text-rose-800 dark:bg-rose-950 dark:text-rose-300'}">
                        ${r.disponible ? 'Disponible' : 'Ocupado'}
                    </span>
                </div>
                <h4 class="text-xs font-bold">${r.nombre}</h4>
                <p class="text-[11px] text-slate-500 mt-0.5"><i class="fa-solid fa-map-pin mr-1"></i>${r.ubicacion}</p>
                <p class="text-[11px] text-slate-400 mt-1.5">${r.specs}</p>
            </div>
            <button ${r.disponible ? `onclick="openReservaModal('${r.nombre}')"` : 'disabled'} class="w-full py-2 rounded-xl text-xs font-semibold transition ${r.disponible ? 'bg-brand-600 hover:bg-brand-700 text-white' : 'bg-slate-100 dark:bg-slate-800 text-slate-400 cursor-not-allowed'}">
                ${r.disponible ? 'Solicitar Préstamo' : 'No Disponible'}
            </button>
        </div>
    `).join('');

    document.getElementById('loansTableBody').innerHTML = appState.prestamos.map(p => {
        const badge = p.estado === 'Devuelto'
            ? 'bg-slate-100 text-slate-600 dark:bg-slate-800 dark:text-slate-400'
            : 'bg-emerald-100 text-emerald-800 dark:bg-emerald-950 dark:text-emerald-300';
        return `
            <tr>
                <td class="py-3 px-4">
                    <span class="font-mono text-[11px] text-brand-600 dark:text-brand-400 font-bold block">${p.id}</span>
                    <span class="text-xs font-bold">${p.recurso}</span>
                </td>
                <td class="py-3 px-4 text-xs">${p.categoria}</td>
                <td class="py-3 px-4 text-xs">${p.fecha}<br><span class="text-slate-400">${p.horario}</span></td>
                <td class="py-3 px-4 text-xs max-w-xs truncate">${p.motivo}</td>
                <td class="py-3 px-4"><span class="text-[10px] font-bold px-2.5 py-0.5 rounded-full ${badge}">${p.estado}</span></td>
                <td class="py-3 px-4 text-right">
                    ${p.estado !== 'Devuelto' ? `<button onclick="returnLoan('${p.id}')" class="text-xs font-semibold text-amber-600 hover:underline">Liberar / Devolver</button>` : '<span class="text-xs text-slate-400">Finalizado</span>'}
                </td>
            </tr>
        `;
    }).join('');
}

function submitReserva(e) {
    e.preventDefault();
    const recursoNombre = document.getElementById('reservaResourceSelect').value;
    const resObj = appState.recursos.find(r => r.nombre === recursoNombre);
    appState.prestamos.unshift({
        id: 'PR-2026-' + Math.floor(200 + Math.random() * 799),
        recurso: recursoNombre,
        categoria: resObj ? resObj.categoria : 'Recurso',
        fecha: document.getElementById('reservaFecha').value,
        horario: document.getElementById('reservaHorario').value,
        motivo: document.getElementById('reservaMotivo').value.trim(),
        estado: 'Aprobado'
    });
    saveState();
    e.target.reset();
    closeModal('modalReserva');
    renderAll();
    showToast(`Reserva confirmada para "${recursoNombre}".`, 'success');
}

function returnLoan(id) {
    const loan = appState.prestamos.find(p => p.id === id);
    if (loan) {
        loan.estado = 'Devuelto';
        saveState();
        renderAll();
        showToast(`Préstamo ${id} marcado como devuelto.`, 'info');
    }
}

/* --- 7. TRÁMITES Y DOCUMENTOS OFICIALES --- */
function renderTramites() {
    document.getElementById('tramitesHistoryList').innerHTML = appState.tramites.map(t => `
        <div class="p-4 rounded-2xl bg-slate-50 dark:bg-slate-800/60 border border-slate-200/80 dark:border-slate-700 space-y-1.5">
            <div class="flex items-center justify-between">
                <span class="font-mono text-xs font-bold text-brand-600 dark:text-brand-400">${t.id}</span>
                <span class="text-[10px] font-bold px-2 py-0.5 rounded-full bg-emerald-100 text-emerald-800 dark:bg-emerald-950 dark:text-emerald-300">${t.estado}</span>
            </div>
            <h4 class="text-xs font-bold">${t.tipo}</h4>
            <p class="text-[11px] text-slate-500 dark:text-slate-400">${t.detalle}</p>
            <p class="text-[10px] text-slate-400">Fecha: ${t.fecha}</p>
        </div>
    `).join('');
}

function submitJustificante(e) {
    e.preventDefault();
    const matId = document.getElementById('justificanteMateriaSelect').value;
    const mat = appState.materias.find(m => m.id === matId);
    const fecha = document.getElementById('justificanteFecha').value;
    const tipo = document.getElementById('justificanteTipo').value;
    const detalle = document.getElementById('justificanteDetalle').value.trim();

    if (mat) mat.j += 1;
    appState.tramites.unshift({
        id: 'TR-' + Math.floor(1000 + Math.random() * 8999),
        tipo: `Justificante (${tipo})`,
        detalle: `${mat ? mat.nombre : ''} • ${detalle}`,
        fecha,
        estado: 'Aplicado'
    });
    saveState();
    e.target.reset();
    renderAll();
    showToast('Justificante aplicado y sumado al control de asistencias.', 'success');
}

function fillDemoToken() {
    document.getElementById('officialAuthToken').value = 'UTT-2026-' + Math.floor(1000 + Math.random() * 8999);
}

function handleDownloadOfficialDoc(e) {
    e.preventDefault();
    const docType = document.getElementById('officialDocType').value;
    const token = document.getElementById('officialAuthToken').value.trim().toUpperCase();
    if (token.length < 6) {
        showToast('Ingresa un token institucional válido (mínimo 6 caracteres).', 'danger');
        return;
    }
    const folio = 'TR-' + Math.floor(1000 + Math.random() * 8999);
    appState.tramites.unshift({
        id: folio,
        tipo: docType,
        detalle: `Token: ${token} • Firma Electrónica UTTec`,
        fecha: '2026-11-15',
        estado: 'Emitido'
    });
    saveState();
    renderAll();

    const win = window.open('', '_blank', 'width=800,height=650');
    if (win) {
        win.document.write(`
            <html><head><title>${docType} - UTTec</title>
            <style>body{font-family:Arial,sans-serif;padding:48px;color:#1e293b;line-height:1.6} .header{border-bottom:3px solid #006847;padding-bottom:16px;margin-bottom:24px} .seal{margin-top:40px;padding:16px;background:#f8fafc;border:1px solid #cbd5e1;font-family:monospace;font-size:12px}</style>
            </head><body>
            <div class="header"><h2>UNIVERSIDAD TECNOLÓGICA DE TECÁMAC</h2><p>Dirección de Servicios Escolares • Campus Tecámac, Edo. Méx.</p></div>
            <h3>${docType.toUpperCase()}</h3>
            <p>A QUIEN CORRESPONDA:</p>
            <p>Por medio de la presente se hace constar que la alumna <strong>SOFÍA MARTÍNEZ LÓPEZ</strong>, con matrícula <strong>2026-0842</strong>, se encuentra inscrita como estudiante regular en el <strong>9° Cuatrimestre</strong> de la carrera de <strong>Ingeniería en Tecnologías de la Información y Comunicación</strong>, con un promedio general acumulado de <strong>${calcGlobalAverage()}</strong>.</p>
            <div class="seal"><strong>SELLO DIGITAL DE AUTENTICIDAD</strong><br>Folio: ${folio} | Token: ${token} | Fecha de emisión: 15 de noviembre de 2026</div>
            <script>window.print();<\/script></body></html>
        `);
        win.document.close();
    }
    showToast(`Documento "${docType}" emitido con folio ${folio}.`, 'success');
}

/* --- 8. TAREAS --- */
function renderTareas() {
    const pending = appState.tareas.filter(t => !t.completada);
    const completed = appState.tareas.filter(t => t.completada);
    document.getElementById('pendingCountPill').textContent = pending.length;
    document.getElementById('completedCountPill').textContent = completed.length;

    const prioColors = {
        Alta: 'bg-rose-100 text-rose-800 dark:bg-rose-950 dark:text-rose-300',
        Media: 'bg-amber-100 text-amber-800 dark:bg-amber-950 dark:text-amber-300',
        Baja: 'bg-sky-100 text-sky-800 dark:bg-sky-950 dark:text-sky-300'
    };

    document.getElementById('pendingTasksList').innerHTML = pending.length ? pending.map(t => `
        <div class="p-3.5 rounded-2xl border border-slate-200/80 dark:border-slate-800 bg-slate-50/50 dark:bg-slate-800/40 flex items-start justify-between gap-3">
            <div class="flex items-start gap-3">
                <input type="checkbox" onchange="toggleTaskComplete('${t.id}')" class="mt-1 w-4 h-4 rounded accent-brand-600 cursor-pointer">
                <div>
                    <h4 class="text-xs font-bold">${t.titulo}</h4>
                    <p class="text-[11px] text-slate-500 mt-0.5">${t.materia} • <span class="font-semibold">Entrega: ${t.fecha}</span></p>
                </div>
            </div>
            <div class="flex items-center gap-2 shrink-0">
                <span class="text-[10px] font-bold px-2 py-0.5 rounded-full ${prioColors[t.prioridad]}">${t.prioridad}</span>
                <button onclick="deleteTask('${t.id}')" class="text-slate-400 hover:text-rose-600"><i class="fa-solid fa-xmark"></i></button>
            </div>
        </div>
    `).join('') : '<p class="text-xs text-slate-400 py-4 text-center">No tienes entregas pendientes.</p>';

    document.getElementById('completedTasksList').innerHTML = completed.length ? completed.map(t => `
        <div class="p-3.5 rounded-2xl border border-slate-200/60 dark:border-slate-800/60 bg-slate-50/30 dark:bg-slate-800/20 flex items-center justify-between gap-3 opacity-75">
            <div class="flex items-center gap-3">
                <input type="checkbox" checked onchange="toggleTaskComplete('${t.id}')" class="w-4 h-4 rounded accent-emerald-600 cursor-pointer">
                <div>
                    <h4 class="text-xs font-semibold line-through">${t.titulo}</h4>
                    <p class="text-[11px] text-slate-400">${t.materia}</p>
                </div>
            </div>
            <button onclick="deleteTask('${t.id}')" class="text-slate-400 hover:text-rose-600 text-xs"><i class="fa-solid fa-trash"></i></button>
        </div>
    `).join('') : '<p class="text-xs text-slate-400 py-4 text-center">Aún no hay entregas marcadas como completadas.</p>';
}

function submitNewTask(e) {
    e.preventDefault();
    appState.tareas.unshift({
        id: 't' + Date.now(),
        titulo: document.getElementById('taskTitulo').value.trim(),
        materia: document.getElementById('taskMateriaSelect').value,
        fecha: document.getElementById('taskFecha').value,
        prioridad: document.getElementById('taskPrioridad').value,
        completada: false
    });
    saveState();
    e.target.reset();
    closeModal('modalTask');
    renderAll();
    showToast('Entrega agregada a tu agenda.', 'success');
}

function toggleTaskComplete(id) {
    const task = appState.tareas.find(t => t.id === id);
    if (task) {
        task.completada = !task.completada;
        saveState();
        renderAll();
        showToast(task.completada ? '¡Entrega completada!' : 'Tarea movida a pendientes.', 'success');
    }
}

function deleteTask(id) {
    appState.tareas = appState.tareas.filter(t => t.id !== id);
    saveState();
    renderAll();
}

/* --- 9. REFUERZO ACADÉMICO --- */
const quizBank = {
    redes: [
        { q: '1. ¿Qué protocolo opera en la capa de transporte y garantiza entrega ordenada mediante Three-Way Handshake?', opts: ['UDP', 'TCP', 'ICMP'], ans: 1, exp: 'TCP establece conexión confiable mediante SYN, SYN-ACK y ACK.' },
        { q: '2. ¿Cuál es el propósito principal de una VLAN en un switch administrable?', opts: ['Aumentar el voltaje del enlace', 'Segmentar dominios de broadcast lógicamente', 'Sustituir el direccionamiento IP'], ans: 1, exp: 'Las VLAN dividen una red física en múltiples redes lógicas aisladas.' },
        { q: '3. ¿Qué puerto utiliza por defecto el protocolo HTTPS?', opts: ['80', '22', '443'], ans: 2, exp: 'HTTPS cifra el tráfico HTTP utilizando TLS/SSL en el puerto 443.' }
    ],
    bd: [
        { q: '1. En replicación PostgreSQL Streaming, ¿qué registros envía el nodo Primario (Master) a las Réplicas?', opts: ['Archivos CSV', 'Registros WAL (Write-Ahead Log)', 'Triggers XML'], ans: 1, exp: 'El servidor primario transmite los segmentos WAL en tiempo real para mantener sincronizados los nodos standby.' },
        { q: '2. ¿Qué propiedad ACID asegura que una transacción se ejecute por completo o no deje cambios parciales?', opts: ['Atomicidad', 'Aislamiento', 'Durabilidad'], ans: 0, exp: 'La atomicidad garantiza el principio de "todo o nada" mediante COMMIT o ROLLBACK.' },
        { q: '3. En un modelo dimensional (Data Warehouse), ¿qué tabla almacena las métricas numéricas del negocio?', opts: ['Tabla de Dimensión', 'Tabla de Hechos (Fact Table)', 'Tabla Temporal'], ans: 1, exp: 'La Fact Table contiene las medidas cuantitativas y llaves foráneas hacia las dimensiones.' }
    ],
    web: [
        { q: '1. ¿Qué código de estado HTTP indica que un recurso fue creado exitosamente tras una petición POST?', opts: ['200 OK', '201 Created', '204 No Content'], ans: 1, exp: '201 Created confirma la creación de un nuevo recurso en el servidor.' },
        { q: '2. ¿Cuál es la función de un JWT (JSON Web Token) en una API REST?', opts: ['Comprimir imágenes', 'Autenticar e intercambiar identidad de forma stateless', 'Crear índices SQL'], ans: 1, exp: 'JWT permite verificar la sesión y roles del usuario mediante firma criptográfica sin estado en servidor.' },
        { q: '3. ¿Qué etiqueta HTML5 mejora la accesibilidad y semántica para la navegación principal?', opts: ['<div id="menu">', '<nav>', '<section>'], ans: 1, exp: '<nav> identifica explícitamente bloques de enlaces de navegación.' }
    ]
};
let currentQuizTopic = 'redes';

function changeRefuerzoTopic(topic) {
    currentQuizTopic = topic;
    clearRefuerzoResult();
    renderRefuerzoQuestions();
}

function renderRefuerzoQuestions() {
    const questions = quizBank[currentQuizTopic] || quizBank.redes;
    const container = document.getElementById('refuerzoQuestions');
    if (!container) return;
    container.innerHTML = questions.map((item, idx) => `
        <fieldset class="p-4 rounded-2xl bg-slate-50 dark:bg-slate-800/50 border border-slate-200/80 dark:border-slate-700 space-y-2">
            <legend class="font-bold text-xs text-slate-800 dark:text-white px-1">${item.q}</legend>
            ${item.opts.map((opt, oIdx) => `
                <label class="flex items-center gap-2.5 text-xs cursor-pointer py-1">
                    <input type="radio" name="q${idx}" value="${oIdx}" required class="accent-brand-600">
                    <span>${opt}</span>
                </label>
            `).join('')}
        </fieldset>
    `).join('');
}

function submitRefuerzo(e) {
    e.preventDefault();
    const questions = quizBank[currentQuizTopic];
    let score = 0;
    const feedbackItems = [];
    questions.forEach((item, idx) => {
        const selected = document.querySelector(`input[name="q${idx}"]:checked`);
        const val = selected ? Number(selected.value) : -1;
        if (val === item.ans) {
            score++;
            feedbackItems.push(`<li class="text-emerald-700 dark:text-emerald-400"><strong>Pregunta ${idx + 1}:</strong> ¡Correcto! ${item.exp}</li>`);
        } else {
            feedbackItems.push(`<li class="text-rose-600 dark:text-rose-400"><strong>Pregunta ${idx + 1}:</strong> Incorrecto. ${item.exp}</li>`);
        }
    });
    document.getElementById('refuerzoResultBox').classList.remove('hidden');
    document.getElementById('refuerzoScore').textContent = `Resultado obtenido: ${score} de ${questions.length} aciertos (${Math.round((score / questions.length) * 100)}%)`;
    document.getElementById('refuerzoFeedback').innerHTML = feedbackItems.join('');
}

function clearRefuerzoResult() {
    document.getElementById('refuerzoResultBox')?.classList.add('hidden');
}

/* --- 10. HERRAMIENTAS (CALCULADORA GPA + DIRECTORIO) --- */
function renderHerramientas() {
    const gpaContainer = document.getElementById('gpaInputsContainer');
    gpaContainer.innerHTML = appState.materias.map(m => `
        <div class="flex items-center justify-between gap-2 p-2.5 rounded-xl bg-slate-50 dark:bg-slate-800/60 border border-slate-200/70 dark:border-slate-700">
            <span class="text-xs font-semibold truncate">${m.nombre}</span>
            <input type="number" step="0.1" min="0" max="10" value="${m.nota}" oninput="recalculateSimulatedGpa()" class="sim-gpa-input w-16 text-xs font-bold text-center rounded-lg bg-white dark:bg-slate-900 border border-slate-200 dark:border-slate-700 py-1">
        </div>
    `).join('');
    recalculateSimulatedGpa();

    document.getElementById('profesoresDirectoryGrid').innerHTML = appState.materias.map(m => `
        <div class="p-4 rounded-2xl border border-slate-200/80 dark:border-slate-800 bg-slate-50/50 dark:bg-slate-800/40 space-y-1.5">
            <span class="text-[10px] font-bold px-2 py-0.5 rounded-md text-white" style="background:${m.color}">${m.codigo}</span>
            <h4 class="text-xs font-bold pt-1">${m.profesor}</h4>
            <p class="text-[11px] text-slate-500 truncate">${m.nombre}</p>
            <div class="pt-2 text-[11px] text-slate-600 dark:text-slate-300 space-y-0.5">
                <p><i class="fa-regular fa-envelope mr-1.5 text-brand-500"></i>${m.email}</p>
                <p><i class="fa-solid fa-door-open mr-1.5 text-brand-500"></i>${m.cubiculo}</p>
                <p><i class="fa-regular fa-clock mr-1.5 text-brand-500"></i>Asesoría: ${m.asesoria}</p>
            </div>
        </div>
    `).join('');
}

function recalculateSimulatedGpa() {
    const inputs = Array.from(document.querySelectorAll('.sim-gpa-input'));
    if (!inputs.length) return;
    const avg = inputs.reduce((acc, el) => acc + (parseFloat(el.value) || 0), 0) / inputs.length;
    document.getElementById('calculatedGpaValue').textContent = avg.toFixed(2);
    const statusEl = document.getElementById('gpaStatusText');
    if (avg >= 9.0) {
        statusEl.textContent = 'Beca de Excelencia Académica (100%)';
        statusEl.className = 'text-xs font-bold text-emerald-600 dark:text-emerald-400';
    } else if (avg >= 8.0) {
        statusEl.textContent = 'Alumno Regular • Buen Rendimiento';
        statusEl.className = 'text-xs font-bold text-brand-600 dark:text-brand-400';
    } else {
        statusEl.textContent = 'Requiere Tutoría Académica';
        statusEl.className = 'text-xs font-bold text-amber-600 dark:text-amber-400';
    }
}

/* --- BUSCADOR GLOBAL Y NOTIFICACIONES --- */
function handleGlobalSearch(query) {
    const box = document.getElementById('globalSearchResults');
    const q = query.trim().toLowerCase();
    if (!q) { box.classList.add('hidden'); return; }

    const results = [];
    appState.materias.forEach(m => {
        if (m.nombre.toLowerCase().includes(q) || m.profesor.toLowerCase().includes(q) || m.codigo.toLowerCase().includes(q)) {
            results.push({ tipo: 'Materia', titulo: `${m.nombre} (${m.codigo})`, sub: `${m.profesor} • ${m.salon}`, tab: 'materias' });
        }
    });
    appState.tareas.forEach(t => {
        if (t.titulo.toLowerCase().includes(q) || t.materia.toLowerCase().includes(q)) {
            results.push({ tipo: 'Tarea', titulo: t.titulo, sub: `${t.materia} • Límite: ${t.fecha}`, tab: 'tareas' });
        }
    });
    appState.archivos.forEach(f => {
        if (f.titulo.toLowerCase().includes(q)) {
            results.push({ tipo: 'Archivo', titulo: f.titulo, sub: `${f.materia} • ${f.size}`, tab: 'archivos' });
        }
    });

    box.classList.remove('hidden');
    box.innerHTML = results.length ? results.map(r => `
        <button onclick="switchTab('${r.tab}'); document.getElementById('globalSearchResults').classList.add('hidden'); document.getElementById('globalSearchInput').value='';" class="w-full text-left p-2.5 rounded-xl hover:bg-slate-100 dark:hover:bg-slate-800 transition flex items-center justify-between gap-2">
            <div class="overflow-hidden">
                <p class="text-xs font-bold truncate">${r.titulo}</p>
                <p class="text-[11px] text-slate-400 truncate">${r.sub}</p>
            </div>
            <span class="text-[10px] font-bold px-2 py-0.5 rounded-md bg-brand-50 dark:bg-brand-950 text-brand-600 dark:text-brand-400 shrink-0">${r.tipo}</span>
        </button>
    `).join('') : '<p class="text-xs text-slate-400 p-2 text-center">Sin coincidencias en el portal.</p>';
}

function toggleNotifications() {
    document.getElementById('notifications-menu')?.classList.toggle('hidden');
}

function renderNotifications() {
    const unread = appState.notificaciones.some(n => !n.leida);
    document.getElementById('notifDot').classList.toggle('hidden', !unread);
    document.getElementById('notificationsList').innerHTML = appState.notificaciones.map(n => `
        <div class="p-2.5 rounded-xl ${n.leida ? 'bg-slate-50/50 dark:bg-slate-800/30' : 'bg-brand-50/60 dark:bg-brand-950/40 border border-brand-200/60 dark:border-brand-800/60'}">
            <div class="flex justify-between items-center">
                <span class="text-xs font-bold">${n.titulo}</span>
                <span class="text-[10px] text-slate-400">${n.tiempo}</span>
            </div>
            <p class="text-[11px] text-slate-600 dark:text-slate-300 mt-0.5">${n.desc}</p>
        </div>
    `).join('');
}

function clearNotifications() {
    appState.notificaciones.forEach(n => n.leida = true);
    saveState();
    renderNotifications();
}

/* --- TEMPORIZADOR POMODORO --- */
function togglePomodoro() {
    const btn = document.getElementById('pomodoroBtn');
    if (pomodoroInterval) {
        clearInterval(pomodoroInterval);
        pomodoroInterval = null;
        btn.innerHTML = '<i class="fa-solid fa-play"></i>';
    } else {
        btn.innerHTML = '<i class="fa-solid fa-pause"></i>';
        pomodoroInterval = setInterval(() => {
            if (pomodoroSeconds > 0) {
                pomodoroSeconds--;
                updatePomodoroDisplay();
            } else {
                clearInterval(pomodoroInterval);
                pomodoroInterval = null;
                btn.innerHTML = '<i class="fa-solid fa-play"></i>';
                showToast('¡Sesión Pomodoro completada! Toma 5 minutos de descanso.', 'success');
            }
        }, 1000);
    }
}

function resetPomodoro() {
    clearInterval(pomodoroInterval);
    pomodoroInterval = null;
    pomodoroSeconds = 25 * 60;
    document.getElementById('pomodoroBtn').innerHTML = '<i class="fa-solid fa-play"></i>';
    updatePomodoroDisplay();
}

function updatePomodoroDisplay() {
    const mins = String(Math.floor(pomodoroSeconds / 60)).padStart(2, '0');
    const secs = String(pomodoroSeconds % 60).padStart(2, '0');
    document.getElementById('pomodoroDisplay').textContent = `${mins}:${secs}`;
}

/* --- ATAJOS DE TECLADO Y EVENTOS GLOBALES --- */
document.addEventListener('keydown', (e) => {
    if ((e.ctrlKey || e.metaKey) && e.key.toLowerCase() === 'k') {
        e.preventDefault();
        document.getElementById('globalSearchInput')?.focus();
    }
    if (e.key === 'Escape') {
        ['modalCredencial', 'modalReserva', 'modalUpload', 'modalMateria', 'modalTask'].forEach(closeModal);
        document.getElementById('globalSearchResults')?.classList.add('hidden');
        document.getElementById('notifications-menu')?.classList.add('hidden');
    }
});

document.addEventListener('click', (e) => {
    const searchInput = document.getElementById('globalSearchInput');
    const searchRes = document.getElementById('globalSearchResults');
    if (searchInput && searchRes && !searchInput.contains(e.target) && !searchRes.contains(e.target)) {
        searchRes.classList.add('hidden');
    }
});

window.addEventListener('DOMContentLoaded', () => {
    const todayStr = '2026-11-15';
    ['asistenciaDateInput', 'reservaFecha', 'justificanteFecha', 'taskFecha'].forEach(id => {
        const el = document.getElementById(id);
        if (el) el.value = todayStr;
    });
    applyTheme();
    renderRefuerzoQuestions();
    renderAll();
});