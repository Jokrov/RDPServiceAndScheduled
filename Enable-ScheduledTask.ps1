#region Scheduled Task Configuration (Universal)
try {
    $scriptPath = "C:\Scripts\Enable-RDPServices.ps1"
    if (-not (Test-Path -Path $scriptPath)) {
        throw "Script file not found at $scriptPath"
    }

    $taskName = "Enable RDP Services at Startup"
    $taskDescription = "Automatically enables required RDP services at system startup"
    $powershellPath = "$env:SystemRoot\System32\WindowsPowerShell\v1.0\powershell.exe"

    # Remove existing task
    if (Get-ScheduledTask -TaskName $taskName -ErrorAction SilentlyContinue) {
        Write-Output "Removing existing task: $taskName"
        Unregister-ScheduledTask -TaskName $taskName -Confirm:$false -ErrorAction Stop
    }

    # Create task components with basic settings
    $action = New-ScheduledTaskAction `
        -Execute $powershellPath `
        -Argument "-NoLogo -NonInteractive -WindowStyle Hidden -ExecutionPolicy Bypass -File `"$scriptPath`""

    $trigger = New-ScheduledTaskTrigger -AtStartup

    $settings = New-ScheduledTaskSettingsSet `
        -AllowStartIfOnBatteries `
        -DontStopIfGoingOnBatteries `
        -StartWhenAvailable

    $principal = New-ScheduledTaskPrincipal `
        -UserId "NT AUTHORITY\SYSTEM" `
        -LogonType ServiceAccount `
        -RunLevel Highest

    # Register task with basic configuration
    $task = Register-ScheduledTask `
        -Action $action `
        -Trigger $trigger `
        -Settings $settings `
        -Principal $principal `
        -TaskName $taskName `
        -Description $taskDescription `
        -Force `
        -ErrorAction Stop

    Write-Output "Task configured successfully. Basic configuration:"
    Get-ScheduledTask -TaskName $taskName | Format-List *
}
catch {
    Write-Error "Task configuration failed: $_"
    exit 1
}
#endregion