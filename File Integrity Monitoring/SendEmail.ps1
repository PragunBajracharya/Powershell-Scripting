Function SendEmail {
    param (
        [string]$subject,
        [string]$body
    )

    # Load SMTP details from env.ps1
    . .\env.ps1

    try {
        $smtpProps = @{
            SmtpServer = $env:SmtpServer
            Port = $env:SmtpPort
            UseSsl = $true
            Credential = New-Object System.Management.Automation.PSCredential ($env:SmtpUsername, (ConvertTo-SecureString $env:SmtpPassword -AsPlainText -Force))
        }

        $mailProps = @{
            From = $env:SenderEmail
            To = $env:RecipientEmail
            Subject = $subject
            Body = $body
            SmtpServer = $smtpProps
        }

        Send-MailMessage @mailProps -ErrorAction Stop
    } catch {
        $errorMessage = "Error sending email: $_"
        LogError -errorLogMessage $errorMessage
    }
}