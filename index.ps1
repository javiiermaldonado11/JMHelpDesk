# ==============================================================================
# JMHelpDesk - Menú Interactivo de Tweaks & Mantenimiento
# ==============================================================================

# Forzar TLS 1.2
[Net.ServicePointManager]::SecurityProtocol = [Net.SecurityProtocolType]::Tls12

# URL RAW directa
$rawUrl = "https://raw.githubusercontent.com/javiiermaldonado11/JMHelpDesk/main/index.ps1"

# Elevación a Administrador
if (-not ([Security.Principal.WindowsPrincipal][Security.Principal.WindowsIdentity]::GetCurrent()).IsInRole([Security.Principal.WindowsBuiltInRole]::Administrator)) {
    Start-Process powershell -ArgumentList "-NoProfile -ExecutionPolicy Bypass -STA -NoExit -Command `"irm '$rawUrl?v=$(Get-Random)' | iex`"" -Verb RunAs
    exit
}

# Cargar librerías GUI de Windows
Add-Type -AssemblyName System.Windows.Forms
Add-Type -AssemblyName System.Drawing
[System.Windows.Forms.Application]::EnableVisualStyles()

# Crear ventana principal
$form = New-Object System.Windows.Forms.Form
$form.Text = "JMHelpDesk - Selección de Tweaks"
$form.Size = New-Object System.Drawing.Size(460, 570)
$form.StartPosition = "CenterScreen"
$form.FormBorderStyle = "FixedSingle"
$form.MaximizeBox = $false
$form.TopMost = $true

# Título
$label = New-Object System.Windows.Forms.Label
$label.Text = "Marque los ajustes que desea aplicar:"
$label.Location = New-Object System.Drawing.Point(20, 10)
$label.Size = New-Object System.Drawing.Size(400, 22)
$label.Font = New-Object System.Drawing.Font("Segoe UI", 10, [System.Drawing.FontStyle]::Bold)
$form.Controls.Add($label)

# Opciones
$items = @(
    @{ ID="DarkMode"; Text="Activar Modo Oscuro (Apps y Sistema)" },
    @{ ID="ShowHidden"; Text="Mostrar Extensiones y Archivos Ocultos" },
    @{ ID="LongPaths"; Text="Habilitar Rutas Largas (>260 caracteres)" },
    @{ ID="GameMode"; Text="Activar Modo Juego (Game Mode)" },
    @{ ID="DisableBing"; Text="Desactivar Búsqueda de Bing en Inicio" },
    @{ ID="DisableTelemetry"; Text="Desactivar Telemetría y Rastreo" },
    @{ ID="CleanTemp"; Text="Limpiar Archivos Temporales de Usuario" },
    @{ ID="EmptyBin"; Text="Vaciar Papelera de Reciclaje" },
    @{ ID="CleanWinUpdate"; Text="Limpiar Actualizaciones y Componentes de Windows (DISM)" }
)

$checkBoxes = @{}
$y = 35

foreach ($item in $items) {
    $cb = New-Object System.Windows.Forms.CheckBox
    $cb.Text = $item.Text
    $cb.Location = New-Object System.Drawing.Point(22, $y)
    $cb.Size = New-Object System.Drawing.Size(400, 24)
    $cb.Font = New-Object System.Drawing.Font("Segoe UI", 8.5)
    $cb.Checked = $true
    $form.Controls.Add($cb)
    $checkBoxes[$item.ID] = $cb
    $y += 26
}

# Cuadro de Consola / Log de Registro
$txtLog = New-Object System.Windows.Forms.TextBox
$txtLog.Multiline = $true
$txtLog.ReadOnly = $true
$txtLog.ScrollBars = "Vertical"
$logY = [int]($y + 48)
$txtLog.Location = New-Object System.Drawing.Point(22, $logY)
$txtLog.Size = New-Object System.Drawing.Size(400, 160)
$txtLog.Font = New-Object System.Drawing.Font("Consolas", 8.5)
$txtLog.BackColor = [System.Drawing.Color]::Black
$txtLog.ForeColor = [System.Drawing.Color]::LightGreen
$form.Controls.Add($txtLog)

# Función para registrar mensajes y forzar actualización visual de la ventana
function Log-Msg ($text) {
    $timestamp = (Get-Date).ToString("HH:mm:ss")
    $txtLog.AppendText("[$timestamp] $text`r`n")
    $txtLog.SelectionStart = $txtLog.TextLength
    $txtLog.ScrollToCaret()
    [System.Windows.Forms.Application]::DoEvents()
}

# Botón Ejecutar
$btnRun = New-Object System.Windows.Forms.Button
$btnRun.Text = "Aplicar Seleccionados"
$btnY = [int]($y + 8)
$btnRun.Location = New-Object System.Drawing.Point(22, $btnY)
$btnRun.Size = New-Object System.Drawing.Size(400, 34)
$btnRun.Font = New-Object System.Drawing.Font("Segoe UI", 9, [System.Drawing.FontStyle]::Bold)
$btnRun.BackColor = [System.Drawing.Color]::FromArgb(0, 120, 215)
$btnRun.ForeColor = [System.Drawing.Color]::White
$btnRun.FlatStyle = [System.Windows.Forms.FlatStyle]::Flat

$btnRun.Add_Click({
    $btnRun.Enabled = $false
    Log-Msg "Iniciando proceso de optimización..."

    if ($checkBoxes["DarkMode"].Checked) {
        Log-Msg "Aplicando Modo Oscuro..."
        Set-ItemProperty -Path "HKCU:\SOFTWARE\Microsoft\Windows\CurrentVersion\Themes\Personalize" -Name "AppsUseLightTheme" -Type DWord -Value 0 -ErrorAction SilentlyContinue
        Set-ItemProperty -Path "HKCU:\SOFTWARE\Microsoft\Windows\CurrentVersion\Themes\Personalize" -Name "SystemUsesLightTheme" -Type DWord -Value 0 -ErrorAction SilentlyContinue
    }

    if ($checkBoxes["ShowHidden"].Checked) {
        Log-Msg "Configurando archivos ocultos y extensiones..."
        Set-ItemProperty -Path "HKCU:\Software\Microsoft\Windows\CurrentVersion\Explorer\Advanced" -Name "HideFileExt" -Type DWord -Value 0 -ErrorAction SilentlyContinue
        Set-ItemProperty -Path "HKCU:\Software\Microsoft\Windows\CurrentVersion\Explorer\Advanced" -Name "Hidden" -Type DWord -Value 1 -ErrorAction SilentlyContinue
    }

    if ($checkBoxes["LongPaths"].Checked) {
        Log-Msg "Habilitando rutas de archivo largas (>260 chars)..."
        Set-ItemProperty -Path "HKLM:\SYSTEM\CurrentControlSet\Control\FileSystem" -Name "LongPathsEnabled" -Type DWord -Value 1 -ErrorAction SilentlyContinue
    }

    if ($checkBoxes["GameMode"].Checked) {
        Log-Msg "Activando Modo Juego de Windows..."
        Set-ItemProperty -Path "HKCU:\Software\Microsoft\GameBar" -Name "AllowAutoGameMode" -Type DWord -Value 1 -ErrorAction SilentlyContinue
    }

    if ($checkBoxes["DisableBing"].Checked) {
        Log-Msg "Desactivando Búsqueda de Bing en menú Inicio..."
        Set-ItemProperty -Path "HKCU:\Software\Policies\Microsoft\Windows\Explorer" -Name "DisableSearchBoxSuggestions" -Type DWord -Value 1 -ErrorAction SilentlyContinue
    }

    if ($checkBoxes["DisableTelemetry"].Checked) {
        Log-Msg "Desactivando servicios de telemetría..."
        Set-ItemProperty -Path "HKLM:\SOFTWARE\Policies\Microsoft\Windows\DataCollection" -Name "AllowTelemetry" -Type DWord -Value 0 -ErrorAction SilentlyContinue
        Set-Service -Name "DiagTrack" -StartupType Disabled -ErrorAction SilentlyContinue
        Stop-Service -Name "DiagTrack" -ErrorAction SilentlyContinue
    }

    if ($checkBoxes["CleanTemp"].Checked) {
        Log-Msg "Eliminando archivos temporales..."
        Get-ChildItem -Path "$env:TEMP\*" -Recurse -Force -ErrorAction SilentlyContinue | Remove-Item -Force -Recurse -ErrorAction SilentlyContinue
    }

    if ($checkBoxes["EmptyBin"].Checked) {
        Log-Msg "Vaciando Papelera de Reciclaje..."
        Clear-RecycleBin -Force -ErrorAction SilentlyContinue
    }

    if ($checkBoxes["CleanWinUpdate"].Checked) {
        Log-Msg "Ejecutando limpieza de componentes y actualizaciones de Windows (DISM)..."
        Log-Msg "Este proceso puede demorar un par de minutos, por favor espere..."
        Start-Process -FilePath "dism.exe" -ArgumentList "/Online /Cleanup-Image /StartComponentCleanup" -WindowStyle Hidden -Wait
    }

    Log-Msg "Reiniciando Explorador de Windows..."
    Stop-Process -Name explorer -Force -ErrorAction SilentlyContinue
    
    Log-Msg "--- ¡Proceso finalizado correctamente! ---"
    $btnRun.Enabled = $true
})

$form.Controls.Add($btnRun)

# Mostrar la ventana
$form.ShowDialog() | Out-Null
