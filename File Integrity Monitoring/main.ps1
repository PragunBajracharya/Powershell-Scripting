# Import other scripts
. .\CalculateFileHash.ps1
. .\EraseBaselineIfAlreadyExists.ps1
. .\LogChange.ps1
. .\ShowWindowsNotification.ps1
. .\MonitorFiles.ps1
. .\LogError.ps1
. .\SendEmail.ps1
. .\env.ps1

# Check if error log and change log files exist, create them if not
$errorLogPath = ".\ErrorLog.txt"
$changeLogPath = ".\ChangeLog.txt"

if (-not (Test-Path -Path $errorLogPath)) {
    $null | Out-File -FilePath $errorLogPath -Force
}

if (-not (Test-Path -Path $changeLogPath)) {
    $null | Out-File -FilePath $changeLogPath -Force
}

# Define function to display menu and get user input
Function ShowMenu {
    Write-Host @"
What would you like to do?

    1) Collect new Baseline
    2) Begin monitoring files with saved Baseline

Please enter the corresponding number (1 or 2):
"@
}

# Process user input
do {
    ShowMenu
    $response = Read-Host

    switch ($response) {
        '1' {
            # Option 1: Collect new Baseline
            EraseBaselineIfAlreadyExists

            try {
                $files = Get-ChildItem -Path .\Files
            } catch {
                $errorMessage = "Error getting files for baseline: $_"
                LogError -errorLogMessage $errorMessage
                exit
            }

            $files | ForEach-Object {
                try {
                    $hash = CalculateFileHash $_.FullName
                } catch {
                    $errorMessage = "Error calculating hash for $($hash.Path): $_"
                    LogError -errorLogMessage $errorMessage
                    exit
                }

                $hash | Select-Object @{Name='Path'; Expression={$_.Path}}, @{Name='Hash'; Expression={$_.Hash}} | Out-File -FilePath .\baseline.txt -Append
            }
        }

        '2' {
            # Option 2: Begin monitoring files with saved Baseline
            $fileHashDictionary = @{}

            try {
                Get-Content -Path .\baseline.txt | ForEach-Object {
                    $split = $_ -split "\\|"
                    $fileHashDictionary[$split[0]] = $split[1]
                }
            } catch {
                $errorMessage = "Error loading baseline: $_"
                LogError -errorLogMessage $errorMessage
                exit
            }
            MonitorFiles -fileHashDictionary $fileHashDictionary
            # Start the monitoring as a background job
            $monitoringJob = Start-Job -ScriptBlock {
                param ($fileHashDictionary)
                MonitorFiles -fileHashDictionary $fileHashDictionary
            } -ArgumentList $fileHashDictionary

            Write-Host "Monitoring job started. Press Enter to stop monitoring."
            Read-Host

            # Stop the monitoring job
            Stop-Job -Job $monitoringJob
            Remove-Job -Job $monitoringJob
        }

        default {
            Write-Host "Invalid selection. Please enter either '1' or '2'." -ForegroundColor Red
        }
    }
} while ($response -ne '1' -and $response -ne '2')
