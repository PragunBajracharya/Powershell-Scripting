Function CalculateFileHash($filepath) {
    try {
        Get-FileHash -Path $filepath -Algorithm SHA512
    } catch {
        $errorMessage = "Error calculating hash for $($filepath): $_"
        LogError -errorLogMessage $errorMessage
        return $null
    }
}