# PowerShell 5.1 / Windows 11. Ejecutar desde cualquier ruta.
# Genera evidencias por módulo; no modifica ni borra la base de datos local.
param([switch]$OmitirBuildWeb)
$ErrorActionPreference = 'Stop'
$root = Split-Path -Parent $MyInvocation.MyCommand.Path
$backend = Join-Path $root 'backend'
$frontend = Join-Path $root 'frontend'
$evidencias = Join-Path $root 'evidencias_pruebas'
New-Item -ItemType Directory -Path $evidencias -Force | Out-Null
$python = Join-Path $backend '.venv\Scripts\python.exe'
if (-not (Test-Path $python)) {
    throw "No existe $python. Crea el entorno e instala requirements.txt primero."
}
$results = @()
function Ejecutar($nombre, $ruta, $programa, $argsList) {
    $log = Join-Path $evidencias "$nombre.log"
    Write-Host "`n=== $nombre ===" -ForegroundColor Cyan
    Push-Location $ruta
    try {
        # En Windows PowerShell 5.1 la salida de error de programas nativos
        # puede convertirse en excepción con ErrorActionPreference=Stop.
        $ErrorActionPreference = "Continue"
        & $programa @argsList 2>&1 | Out-File -FilePath $log -Encoding UTF8
        $codigo = $LASTEXITCODE
    } finally {
        Pop-Location
    }
    $script:results += [PSCustomObject]@{ Comprobacion=$nombre; Codigo=$codigo; Log=$log }
    if ($codigo -eq 0) { Write-Host "OK - $nombre" -ForegroundColor Green }
    else { Write-Host "FALLO ($codigo) - $nombre. Mira $log" -ForegroundColor Red }
}
Ejecutar 'django_check' $backend $python @('manage.py','check')
Ejecutar 'migraciones_sin_cambios' $backend $python @('manage.py','makemigrations','--check','--dry-run')
Ejecutar 'django_tests' $backend $python @('manage.py','test','--verbosity','2')
$flutter = Get-Command flutter -ErrorAction SilentlyContinue
if ($null -eq $flutter) {
    Write-Warning 'Flutter no está disponible en PATH. Se omiten sus comprobaciones.'
} else {
    Ejecutar 'flutter_pub_get' $frontend 'flutter' @('pub','get')
    Ejecutar 'flutter_analyze' $frontend 'flutter' @('analyze')
    Ejecutar 'flutter_test' $frontend 'flutter' @('test')
    if (-not $OmitirBuildWeb) {
        Ejecutar 'flutter_build_web' $frontend 'flutter' @('build','web','--release')
    }
}
$results | Format-Table -AutoSize
$results | Export-Csv -Path (Join-Path $evidencias 'resumen.csv') -NoTypeInformation -Encoding UTF8
if ($results | Where-Object { $_.Codigo -ne 0 }) {
    throw 'Una o más comprobaciones fallaron. Consulta evidencias_pruebas/*.log.'
}
Write-Host "Pruebas terminadas; evidencias: $evidencias" -ForegroundColor Green
