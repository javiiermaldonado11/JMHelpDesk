# ==============================================================================
# JMHelpDesk - Menú Interactivo de Tweaks
# ==============================================================================

# Forzar protocolo TLS 1.2
[Net.ServicePointManager]::SecurityProtocol = [Net.SecurityProtocolType]::Tls12

# URL RAW directa (Evita caché de GitHub Pages)
$rawUrl = "https://raw.githubusercontent.com/javiermaldonado11/JMHelpDesk/main/index.ps1"

# Elevación a Administrador con modo gráfico habilitado (-STA) y sin cierre automático (-NoExit)
if (-not ([Security.Principal.WindowsPrincipal][Security.Principal.WindowsIdentity]::GetCurrent()).IsInRole([Security.Principal.WindowsBuiltInRole]::Administrator)) {
    Start-Process powershell -ArgumentList "-NoProfile -ExecutionPolicy Bypass -STA -NoExit -Command `"irm $rawUrl | iex`"" -Verb RunAs
    exit
}

# Cargar librerías visuales de Windows
Add-Type -AssemblyName System.Windows.Forms
Add-Type -AssemblyName System.Drawing
[System.Windows.Forms.Application]::EnableVisualStyles()

# Crear ventana principal
$form = New-Object System.Windows.Forms.Form
$form.Text = "JMHelpDesk - Selección de Tweaks"
$form.Size = New-Object System.Drawing.Size(430, 490)
$form.StartPosition = "CenterScreen"
$form.FormBorderStyle = "FixedSingle"
$form.MaximizeBox = $false
$form.TopMost = $true

# Título
$label = New-Object System.Windows.Forms.Label
$label.Text = "Marque los ajustes que desea aplicar:"
$label.Location = New-Object System.Drawing.Point(20, 15)
$label.Size = New-Object System.Drawing.Size(370, 25)
$label.Font = New-Object System.Drawing.Font("Segoe UI", 10, [System.Drawing.FontStyle]::Bold)
$form.Controls.Add($label)

# Lista de opciones
$items = @(
    @{ ID="DarkMode"; Text="Activar Modo Oscuro (Apps y Sistema)" },
    @{ ID="ShowHidden"; Text="Mostrar Extensiones y Archivos Ocultos" },
    @{ ID="LongPaths"; Text="Habilitar Rutas Largas (>260 caracteres)" },
    @{ ID="GameMode"; Text="Activar Modo Juego (Game Mode)" },
    @{ ID="DisableBing"; Text="Desactivar Búsqueda de Bing en Inicio" },
    @{ ID="DisableTelemetry"; Text="Desactivar Telemetría y Rastreo" },
    @{ ID="CleanTemp"; Text="Limpiar Archivos Temporales" }
)

$checkBoxes = @{}
$y = 50

foreach ($item in $items) {
    $cb = New-Object System.Windows.Forms.CheckBox
    $cb.Text = $item.Text
    $cb.Location = New-Object System.Drawing.Point(25, $y)
    $cb.Size = New-Object System.Drawing.Size(360, 28)
    $cb.Font = New-Object System.Drawing.Font("Segoe UI", 9)
    $cb.Checked = $true
    $form.Controls.Add($cb)
    $checkBoxes[$item.ID] = $cb
    $y += 35
}

# Botón Ejecutar
$btnRun = New-Object System.Windows.Forms.Button
$btnRun.Text = "Aplicar Seleccionados"
$btnRun.Location = New-Object System.Drawing.Point(25, $y + 15)
$btnRun.Size = New-Object System.Drawing.Size(360, 40)
$btnRun.Font = New-Object System.Drawing.Font("Segoe UI", 9, [System.Drawing.FontStyle]::Bold)
$btnRun.BackColor = [System.Drawing.Color]::FromArgb(0, 120, 215)
$btnRun.ForeColor = [System.Drawing.Color]::White
$btnRun.FlatStyle = [System.Drawing.FlatStyle]::Flat

$btnRun.Add_Click({
    if ($checkBoxes["DarkMode"].Checked) {
        Set-ItemProperty -Path "HKCU:\SOFTWARE\Microsoft\Windows\CurrentVersion\Themes\Personalize" -Name "AppsUseLightTheme" -Type DWord -Value 0 -ErrorAction SilentlyContinue
        Set-ItemProperty -Path "HKCU:\SOFTWARE\Microsoft\Windows\CurrentVersion\Themes\Personalize" -Name "SystemUsesLightTheme" -Type DWord -Value 0 -ErrorAction SilentlyContinue
    }

    if ($checkBoxes["ShowHidden"].Checked) {
        Set-ItemProperty -Path "HKCU:\Software\Microsoft\Windows\CurrentVersion\Explorer\Advanced" -Name "HideFileExt" -Type DWord -Value 0 -ErrorAction SilentlyContinue
        Set-ItemProperty -Path "HKCU:\Software\Microsoft\Windows\CurrentVersion\Explorer\Advanced" -Name "Hidden" -Type DWord -Value 1 -ErrorAction SilentlyContinue
    }

    if ($checkBoxes["LongPaths"].Checked) {
        Set-ItemProperty -Path "HKLM:\SYSTEM\CurrentControlSet\Control\FileSystem" -Name "LongPathsEnabled" -Type DWord -Value 1 -ErrorAction SilentlyContinue
    }

    if ($checkBoxes["GameMode"].Checked) {
        Set-ItemProperty -Path "HKCU:\Software\Microsoft\GameBar" -Name "AllowAutoGameMode" -Type DWord -Value 1 -ErrorAction SilentlyContinue
    }

    if ($checkBoxes["DisableBing"].Checked) {
        Set-ItemProperty -Path "HKCU:\Software\Policies\Microsoft\Windows\Explorer" -Name "DisableSearchBoxSuggestions" -Type DWord -Value 1 -ErrorAction SilentlyContinue
    }

    if ($checkBoxes["DisableTelemetry"].Checked) {
        Set-ItemProperty -Path "HKLM:\SOFTWARE\Policies\Microsoft\Windows\DataCollection" -Name "AllowTelemetry" -Type DWord -Value 0 -ErrorAction SilentlyContinue
        Set-Service -Name "DiagTrack" -StartupType Disabled -ErrorAction SilentlyContinue
        Stop-Service -Name "DiagTrack" -ErrorAction SilentlyContinue
    }

    if ($checkBoxes["CleanTemp"].Checked) {
        Get-ChildItem -Path "$env:TEMP\*" -Recurse -Force -ErrorAction SilentlyContinue | Remove-Item -Force -Recurse -ErrorAction SilentlyContinue
    }

    Stop-Process -Name explorer -Force -ErrorAction SilentlyContinue
    
    [System.Windows.Forms.MessageBox]::Show("Ajustes aplicados correctamente.", "JMHelpDesk", [System.Windows.Forms.MessageBoxButtons]::OK, [System.Windows.Forms.MessageBoxIcon]::Information)
    $form.Close()
})

$form.Controls.Add($btnRun)

# Mostrar la ventana
$form.ShowDialog() | Out-Null
