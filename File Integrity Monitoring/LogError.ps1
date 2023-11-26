Function LogError {
    param (
        [string]$errorLogMessage,
        [string]$errorLogFilePath = ".\ErrorLog.txt"
    )

    # Create the error log file if it doesn't exist
    if (-not (Test-Path -Path $errorLogFilePath)) {
        $null | Out-File -FilePath $errorLogFilePath -Force
    }

    try {
        $timestamp = Get-Date -Format "yyyy-MM-dd HH:mm:ss"
        "$timestamp - $errorLogMessage" | Out-File -Append -FilePath $errorLogPath
        #SendEmail -subject "Error Log" -body "$timestamp - $errorLogMessage"
    } catch {
        # Output the error to the console if unable to log to the file
        Write-Host "Error logging to error file: $_" -ForegroundColor Red
    }
}