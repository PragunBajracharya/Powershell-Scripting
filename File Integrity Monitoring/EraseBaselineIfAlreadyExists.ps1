Function EraseBaselineIfAlreadyExists() {
    try {
        if (Test-Path -Path .\baseline.txt) {
            Remove-Item -Path .\baseline.txt -ErrorAction Stop
        }
    } catch {
        $errorMessage = "Error erasing baseline: $_"
        LogError -errorLogMessage $errorMessage
        exit
    }
}