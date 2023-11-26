Function ShowWindowsNotification {
    param (
        [string]$title,
        [string]$message,
        [string]$appLogo = "C:\Path\To\Your\Logo.png"
    )

    try {
        New-BurntToastNotification -Text $message -Title $title -AppLogo $appLogo -ErrorAction Stop
    } catch {
        $errorMessage = "Error displaying Windows notification: $_"
        LogError -errorLogMessage $errorMessage
        SendEmail -subject "Error displaying Windows notification" -body $errorMessage
    }
}