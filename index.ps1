# ==============================================================================
# JMHelpDesk - Suite de Optimización & Mantenimiento Corporativo
# ==============================================================================

[Net.ServicePointManager]::SecurityProtocol = [Net.SecurityProtocolType]::Tls12

$rawUrl = "https://raw.githubusercontent.com/javiiermaldonado11/JMHelpDesk/main/index.ps1"

if (-not ([Security.Principal.WindowsPrincipal][Security.Principal.WindowsIdentity]::GetCurrent()).IsInRole([Security.Principal.WindowsBuiltInRole]::Administrator)) {
    Start-Process powershell -ArgumentList "-NoProfile -ExecutionPolicy Bypass -STA -NoExit -Command `"irm '$rawUrl?v=$(Get-Random)' | iex`"" -Verb RunAs
    exit
}

Add-Type -AssemblyName System.Windows.Forms
Add-Type -AssemblyName System.Drawing
[System.Windows.Forms.Application]::EnableVisualStyles()

# Ventana Principal
$form = New-Object System.Windows.Forms.Form
$form.Text = "JMHelpDesk - Suite de Mantenimiento"
$form.Size = New-Object System.Drawing.Size(480, 720)
$form.StartPosition = "CenterScreen"
$form.FormBorderStyle = "FixedSingle"
$form.MaximizeBox = $false
$form.BackColor = [System.Drawing.Color]::FromArgb(245, 245, 247)
$form.TopMost = $true

# Header Banner
$header = New-Object System.Windows.Forms.Panel
$header.Size = New-Object System.Drawing.Size(480, 55)
$header.Dock = "Top"
$header.BackColor = [System.Drawing.Color]::FromArgb(20, 23, 26)

$titleLabel = New-Object System.Windows.Forms.Label
$titleLabel.Text = "JMHelpDesk Tool"
$titleLabel.ForeColor = [System.Drawing.Color]::White
$titleLabel.Font = New-Object System.Drawing.Font("Segoe UI", 12, [System.Drawing.FontStyle]::Bold)
$titleLabel.Location = New-Object System.Drawing.Point(18, 10)
$titleLabel.AutoSize = $true

$subTitleLabel = New-Object System.Windows.Forms.Label
$subTitleLabel.Text = "Ajustes del Sistema & Mantenimiento de Windows"
$subTitleLabel.ForeColor = [System.Drawing.Color]::FromArgb(160, 170, 180)
$subTitleLabel.Font = New-Object System.Drawing.Font("Segoe UI", 8.5)
$subTitleLabel.Location = New-Object System.Drawing.Point(19, 30)
$subTitleLabel.AutoSize = $true

$header.Controls.Add($titleLabel)
$header.Controls.Add($subTitleLabel)
$form.Controls.Add($header)

# Contenedor Principal de Opciones
$container = New-Object System.Windows.Forms.Panel
$container.Location = New-Object System.Drawing.Point(15, 65)
$container.Size = New-Object System.Drawing.Size(435, 360)
$container.BackColor = [System.Drawing.Color]::White
$container.BorderStyle = "FixedSingle"

# Toolbar (Marcar/Desmarcar)
$btnSelectAll = New-Object System.Windows.Forms.Button
$btnSelectAll.Text = "Marcar todos"
$btnSelectAll.Location = New-Object System.Drawing.Point(10, 8)
$btnSelectAll.Size = New-Object System.Drawing.Size(100, 24)
$btnSelectAll.Font = New-Object System.Drawing.Font("Segoe UI", 8)
$btnSelectAll.FlatStyle = "Flat"
$btnSelectAll.FlatAppearance.BorderSize = 1
$btnSelectAll.FlatAppearance.BorderColor = [System.Drawing.Color]::LightGray

$btnUnselectAll = New-Object System.Windows.Forms.Button
$btnUnselectAll.Text = "Desmarcar todos"
$btnUnselectAll.Location = New-Object System.Drawing.Point(115, 8)
$btnUnselectAll.Size = New-Object System.Drawing.Size(100, 24)
$btnUnselectAll.Font = New-Object System.Drawing.Font("Segoe UI", 8)
$btnUnselectAll.FlatStyle = "Flat"
$btnUnselectAll.FlatAppearance.BorderSize = 1
$btnUnselectAll.FlatAppearance.BorderColor = [System.Drawing.Color]::LightGray

$container.Controls.Add($btnSelectAll)
$container.Controls.Add($btnUnselectAll)

# Lista de Opciones
$items = @(
    @{ ID="DarkMode"; Text="Activar Modo Oscuro (Apps y Sistema)" },
    @{ ID="ShowHidden"; Text="Mostrar Extensiones y Archivos Ocultos" },
    @{ ID="LongPaths"; Text="Habilitar Rutas Largas (>260 caracteres)" },
    @{ ID="GameMode"; Text="Activar Modo Juego (Game Mode)" },
    @{ ID="DisableBing"; Text="Desactivar Búsqueda de Bing en Inicio" },
    @{ ID="DisableTelemetry"; Text="Desactivar Telemetría y Rastreo" },
    @{ ID="CleanUserTemp"; Text="Limpiar Temporales de Usuario (%TEMP%)" },
    @{ ID="CleanSysTemp"; Text="Limpiar Temporales de Sistema (C:\Windows\Temp)" },
    @{ ID="CleanDeliveryOpt"; Text="Limpiar Caché de Optimización de Distribución" },
    @{ ID="CleanSoftwareDist"; Text="Limpiar Caché de Descargas de Windows Update" },
    @{ ID="CleanLogsWER"; Text="Limpiar Informes de Error (WER) y Caché DirectX" },
    @{ ID="EmptyBin"; Text="Vaciar Papelera de Reciclaje" },
    @{ ID="CleanWinUpdate"; Text="Limpiar Componentes de Windows (DISM)" }
)

$checkBoxes = @{}
$y = 38

foreach ($item in $items) {
    $cb = New-Object System.Windows.Forms.CheckBox
    $cb.Text = $item.Text
    $cb.Location = New-Object System.Drawing.Point(15, $y)
    $cb.Size = New-Object System.Drawing.Size(400, 22)
    $cb.Font = New-Object System.Drawing.Font("Segoe UI", 8.5)
    $cb.Checked = $true
    $cb.Cursor = [System.Windows.Forms.Cursors]::Hand
    $container.Controls.Add($cb)
    $checkBoxes[$item.ID] = $cb
    $y += 24
}

$btnSelectAll.Add_Click({ foreach ($cb in $checkBoxes.Values) { $cb.Checked = $true } })
$btnUnselectAll.Add_Click({ foreach ($cb in $checkBoxes.Values) { $cb.Checked = $false } })

$form.Controls.Add($container)

# Botón Ejecutar
$btnRun = New-Object System.Windows.Forms.Button
$btnRun.Text = "APLICAR OPTIMIZACIONES"
$btnRun.Location = New-Object System.Drawing.Point(15, 433)
$btnRun.Size = New-Object System.Drawing.Size(435, 40)
$btnRun.Font = New-Object System.Drawing.Font("Segoe UI", 9.5, [System.Drawing.FontStyle]::Bold)
$btnRun.BackColor = [System.Drawing.Color]::FromArgb(0, 102, 204)
$btnRun.ForeColor = [System.Drawing.Color]::White
$btnRun.FlatStyle = [System.Windows.Forms.FlatStyle]::Flat
$btnRun.FlatAppearance.BorderSize = 0
$btnRun.Cursor = [System.Windows.Forms.Cursors]::Hand

# Cuadro de Consola / Log
$txtLog = New-Object System.Windows.Forms.TextBox
$txtLog.Multiline = $true
$txtLog.ReadOnly = $true
$txtLog.ScrollBars = "Vertical"
$txtLog.Location = New-Object System.Drawing.Point(15, 480)
$txtLog.Size = New-Object System.Drawing.Size(435, 185)
$txtLog.Font = New-Object System.Drawing.Font("Consolas", 8.5)
$txtLog.BackColor = [System.Drawing.Color]::FromArgb(15, 17, 20)
$txtLog.ForeColor = [System.Drawing.Color]::FromArgb(0, 230, 118)
$txtLog.BorderStyle = "FixedSingle"

$form.Controls.Add($btnRun)
$form.Controls.Add($txtLog)

function Log-Msg ($text) {
    $timestamp = (Get-Date).ToString("HH:mm:ss")
    $txtLog.AppendText("[$timestamp] $text`r`n")
    $txtLog.SelectionStart = $txtLog.TextLength
    $txtLog.ScrollToCaret()
    [System.Windows.Forms.Application]::DoEvents()
}

$btnRun.Add_Click({
    $btnRun.Enabled = $false
    $btnRun.Text = "PROCESANDO..."
    $btnRun.BackColor = [System.Drawing.Color]::Gray
    
    Log-Msg "Iniciando proceso de optimización..."

    if ($checkBoxes["DarkMode"].Checked) {
        Log-Msg "Aplicando Tema Oscuro..."
        Set-ItemProperty -Path "HKCU:\SOFTWARE\Microsoft\Windows\CurrentVersion\Themes\Personalize" -Name "AppsUseLightTheme" -Type DWord -Value 0 -ErrorAction SilentlyContinue
        Set-ItemProperty -Path "HKCU:\SOFTWARE\Microsoft\Windows\CurrentVersion\Themes\Personalize" -Name "SystemUsesLightTheme" -Type DWord -Value 0 -ErrorAction SilentlyContinue
    }

    if ($checkBoxes["ShowHidden"].Checked) {
        Log-Msg "Configurando archivos ocultos y extensiones..."
        Set-ItemProperty -Path "HKCU:\Software\Microsoft\Windows\CurrentVersion\Explorer\Advanced" -Name "HideFileExt" -Type DWord -Value 0 -ErrorAction SilentlyContinue
        Set-ItemProperty -Path "HKCU:\Software\Microsoft\Windows\CurrentVersion\Explorer\Advanced" -Name "Hidden" -Type DWord -Value 1 -ErrorAction SilentlyContinue
    }

    if ($checkBoxes["LongPaths"].Checked) {
        Log-Msg "Habilitando soporte de rutas largas (>260 chars)..."
        Set-ItemProperty -Path "HKLM:\SYSTEM\CurrentControlSet\Control\FileSystem" -Name "LongPathsEnabled" -Type DWord -Value 1 -ErrorAction SilentlyContinue
    }

    if ($checkBoxes["GameMode"].Checked) {
        Log-Msg "Optimizando Modo Juego de Windows..."
        Set-ItemProperty -Path "HKCU:\Software\Microsoft\GameBar" -Name "AllowAutoGameMode" -Type DWord -Value 1 -ErrorAction SilentlyContinue
    }

    if ($checkBoxes["DisableBing"].Checked) {
        Log-Msg "Desactivando Bing en el menú Inicio..."
        Set-ItemProperty -Path "HKCU:\Software\Policies\Microsoft\Windows\Explorer" -Name "DisableSearchBoxSuggestions" -Type DWord -Value 1 -ErrorAction SilentlyContinue
    }

    if ($checkBoxes["DisableTelemetry"].Checked) {
        Log-Msg "Desactivando servicios de telemetría y rastreo..."
        Set-ItemProperty -Path "HKLM:\SOFTWARE\Policies\Microsoft\Windows\DataCollection" -Name "AllowTelemetry" -Type DWord -Value 0 -ErrorAction SilentlyContinue
        Set-Service -Name "DiagTrack" -StartupType Disabled -ErrorAction SilentlyContinue
        Stop-Service -Name "DiagTrack" -ErrorAction SilentlyContinue
    }

    if ($checkBoxes["CleanUserTemp"].Checked) {
        Log-Msg "Eliminando temporales de usuario (%TEMP%)..."
        Get-ChildItem -Path "$env:TEMP\*" -Recurse -Force -ErrorAction SilentlyContinue | Remove-Item -Force -Recurse -ErrorAction SilentlyContinue
    }

    if ($checkBoxes["CleanSysTemp"].Checked) {
        Log-Msg "Eliminando temporales de sistema (C:\Windows\Temp)..."
        Get-ChildItem -Path "$env:SystemRoot\Temp\*" -Recurse -Force -ErrorAction SilentlyContinue | Remove-Item -Force -Recurse -ErrorAction SilentlyContinue
    }

    if ($checkBoxes["CleanDeliveryOpt"].Checked) {
        Log-Msg "Deteniendo servicio de Optimización de Distribución (DoSvc)..."
        Stop-Service -Name "DoSvc" -Force -ErrorAction SilentlyContinue
        
        Log-Msg "Vaciando caché de Optimización de Distribución..."
        if (Get-Command Delete-DeliveryOptimizationCache -ErrorAction SilentlyContinue) {
            Delete-DeliveryOptimizationCache -Force -ErrorAction SilentlyContinue
        }

        $doPaths = @(
            "$env:SystemRoot\ServiceProfiles\NetworkService\AppData\Local\Microsoft\Windows\DeliveryOptimization\Cache",
            "$env:ProgramData\Microsoft\Windows\DeliveryOptimization\Cache"
        )
        foreach ($path in $doPaths) {
            if (Test-Path $path) {
                Get-ChildItem -Path "$path\*" -Recurse -Force -ErrorAction SilentlyContinue | Remove-Item -Force -Recurse -ErrorAction SilentlyContinue
            }
        }
        Start-Service -Name "DoSvc" -ErrorAction SilentlyContinue
    }

    if ($checkBoxes["CleanSoftwareDist"].Checked) {
        Log-Msg "Limpiando paquetes de descarga de Windows Update..."
        Stop-Service -Name "wuauserv" -ErrorAction SilentlyContinue
        Get-ChildItem -Path "$env:SystemRoot\SoftwareDistribution\Download\*" -Recurse -Force -ErrorAction SilentlyContinue | Remove-Item -Force -Recurse -ErrorAction SilentlyContinue
        Start-Service -Name "wuauserv" -ErrorAction SilentlyContinue
    }

    if ($checkBoxes["CleanLogsWER"].Checked) {
        Log-Msg "Eliminando informes de errores (WER) y caché DirectX..."
        Get-ChildItem -Path "$env:ProgramData\Microsoft\Windows\WER\*" -Recurse -Force -ErrorAction SilentlyContinue | Remove-Item -Force -Recurse -ErrorAction SilentlyContinue
        Get-ChildItem -Path "$env:LOCALAPPDATA\D3DSCache\*" -Recurse -Force -ErrorAction SilentlyContinue | Remove-Item -Force -Recurse -ErrorAction SilentlyContinue
    }

    if ($checkBoxes["EmptyBin"].Checked) {
        Log-Msg "Vaciando Papelera de Reciclaje..."
        Clear-RecycleBin -Force -ErrorAction SilentlyContinue
    }

    if ($checkBoxes["CleanWinUpdate"].Checked) {
        Log-Msg "Ejecutando DISM para limpiar almacén de componentes..."
        Log-Msg "(Este proceso puede demorar un par de minutos)..."
        Start-Process -FilePath "dism.exe" -ArgumentList "/Online /Cleanup-Image /StartComponentCleanup" -WindowStyle Hidden -Wait
    }

    Log-Msg "Reiniciando Explorador de Windows..."
    Stop-Process -Name explorer -Force -ErrorAction SilentlyContinue
    
    Log-Msg "--- ¡OPTIMIZACIÓN COMPLETADA CON ÉXITO! ---"
    $btnRun.Enabled = $true
    $btnRun.Text = "APLICAR OPTIMIZACIONES"
    $btnRun.BackColor = [System.Drawing.Color]::FromArgb(0, 102, 204)
})

$form.ShowDialog() | Out-Null
