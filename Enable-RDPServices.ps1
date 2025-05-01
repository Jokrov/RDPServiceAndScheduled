<#
.SYNOPSIS
Optimized network service management with enhanced diagnostics for Windows PowerShell.

.DESCRIPTION
Manages core Windows network services with dependency handling and retry logic.
#>

param(
    [string[]]$Services = @(
        "SessionEnv",     # Remote Desktop Configuration
        "TermService",    # Remote Desktop Services
        "UmRdpService",   # Remote Desktop UserMode Port Redirector
        "iphlpsvc"        # IP Helper
    ),
    [string]$LogPath = "$env:TEMP\NetworkServiceManager.log"
)

#region Initialization
# Check PowerShell version
if ($PSVersionTable.PSVersion.Major -lt 5) {
    Write-Error "Requires PowerShell 5.1 or newer" -ErrorAction Stop
}

# Check administrator privileges
if (-not ([Security.Principal.WindowsPrincipal][Security.Principal.WindowsIdentity]::GetCurrent()).IsInRole([Security.Principal.WindowsBuiltInRole]::Administrator)) {
    Write-Error "[FATAL] Administrator privileges required!" -ErrorAction Stop
}

$ErrorActionPreference = 'Stop'
$scriptStartTime = Get-Date
$serviceStates = New-Object System.Collections.Generic.List[PSObject]
#endregion

#region Functions
function Invoke-ServiceOperation {
    param(
        [string]$ServiceName,
        [ValidateSet('Automatic', 'Manual')]
        [string]$DesiredStartType = 'Manual'
    )

    try {
        $service = Get-Service -Name $ServiceName -ErrorAction Stop
        
        # Change startup type
        if ($service.StartType -ne $DesiredStartType) {
            Write-Output "[$ServiceName] Changing startup type to $DesiredStartType"
            Set-Service -Name $ServiceName -StartupType $DesiredStartType -ErrorAction Stop
        }

        # Start service if not running
        if ($service.Status -ne 'Running') {
            Write-Output "[$ServiceName] Attempting to start service"
            
            $maxRetries = 3
            $retryDelay = 2
            
            for ($retry = 1; $retry -le $maxRetries; $retry++) {
                try {
                    Start-Service -Name $ServiceName -ErrorAction Stop
                    $service.Refresh()
                    
                    if ($service.Status -eq 'Running') {
                        Write-Output "[$ServiceName] Successfully started (Attempt $retry)"
                        break
                    }
                }
                catch {
                    if ($retry -eq $maxRetries) {
                        Write-Warning "[$ServiceName] Failed to start after $maxRetries attempts: $_"
                        return
                    }
                    
                    Start-Sleep -Seconds ($retryDelay * $retry)
                }
            }
        }

        # Check service dependencies
        $dependencies = $service.ServicesDependedOn
        if ($dependencies.Status -ne 'Running') {
            Write-Warning "[$ServiceName] Dependent services not running: $($dependencies.Name -join ', ')"
        }

        # Record service state
        $serviceStates.Add([PSCustomObject]@{
            Name      = $ServiceName
            Status    = $service.Status
            StartType = $service.StartType
        })
    }
    catch {
        Write-Error "[$ServiceName] Operation failed: $_"
    }
}

function Show-ServiceReport {
    $report = @"
=== Service Management Report ===
Start Time:    $scriptStartTime
Duration:      $((Get-Date) - $scriptStartTime)
Services:      $($Services -join ', ')

Final Status:
$($serviceStates | Format-Table | Out-String)
"@
    
    Write-Output $report
    $report | Out-File -FilePath $LogPath -Append
}
#endregion

#region Main Execution
# Initialize log file
"" | Out-File -FilePath $LogPath

Write-Output "[INIT] Starting network service optimization at $scriptStartTime" | Tee-Object -FilePath $LogPath -Append

# Process services sequentially
foreach ($service in $Services) {
    Invoke-ServiceOperation -ServiceName $service -DesiredStartType 'Manual'
}

# Generate and display report
Show-ServiceReport
Write-Output "[COMPLETE] Operation finished at $(Get-Date)" | Tee-Object -FilePath $LogPath -Append
#endregion

