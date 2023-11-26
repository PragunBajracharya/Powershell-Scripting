Function LogChange {
    param (
        [string]$logMessage,
        [string]$logFilePath = ".\ChangeLog.txt"
    )

    try {
        $timestamp = Get-Date -Format "yyyy-MM-dd HH:mm:ss"
        "$timestamp - $logMessage" | Out-File -Append -FilePath $changeLogPath
    } catch {
        $errorMessage = "Error writing to log file: $_"
        LogError -errorLogMessage $errorMessage
    }
}