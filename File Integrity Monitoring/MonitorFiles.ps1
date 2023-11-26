Function MonitorFiles {
    param (
        [hashtable]$fileHashDictionary
    )

    # Check if error log and change log files exist, create them if not
    $errorLogPath = ".\ErrorLog.txt"
    $changeLogPath = ".\ChangeLog.txt"

    if (-not (Test-Path -Path $errorLogPath)) {
        $null | Out-File -FilePath $errorLogPath -Force
    }

    if (-not (Test-Path -Path $changeLogPath)) {
        $null | Out-File -FilePath $changeLogPath -Force
    }

    # Function to send email notifications
    Function SendNotificationEmail {
        param (
            [string]$eventType,
            [string]$filePath
        )

        $subject = "File $eventType"
        $body = "File ${eventType}: ${filePath}"

        SendEmail -subject $subject -body $body
    }

    $filesDirectory = ".\Files"
    $previousFiles = Get-ChildItem -Path $filesDirectory -File | ForEach-Object { $_.FullName }

    while ($true) {
        Start-Sleep -Seconds 5  # Adjust the sleep duration based on your monitoring needs

        try {
            $currentFiles = Get-ChildItem -Path $filesDirectory -File | ForEach-Object { $_.FullName }
        } catch {
            $errorMessage = "Error getting files: $_"
            LogError -errorLogMessage $errorMessage
            continue
        }

        $addedFiles = Compare-Object -ReferenceObject $previousFiles -DifferenceObject $currentFiles | Where-Object { $_.SideIndicator -eq "=>" } | ForEach-Object { $_.InputObject }
        $removedFiles = Compare-Object -ReferenceObject $currentFiles -DifferenceObject $previousFiles | Where-Object { $_.SideIndicator -eq "=>" } | ForEach-Object { $_.InputObject }

        foreach ($addedFile in $addedFiles) {
            $hash = CalculateFileHash $addedFile
            LogChange -logMessage "$($addedFile) has been created!"
            ShowWindowsNotification -title "File Created" -message "$($addedFile) has been created!"
            #SendNotificationEmail -eventType "created" -filePath $addedFile
            $fileHashDictionary[$hash.Path] = $hash.Hash
        }

        foreach ($removedFile in $removedFiles) {
            LogChange -logMessage "$($removedFile) has been deleted!"
            ShowWindowsNotification -title "File Deleted" -message "$($removedFile) has been deleted!"
            #SendNotificationEmail -eventType "deleted" -filePath $removedFile
            $fileHashDictionary.Remove($removedFile)
        }

        foreach ($file in $currentFiles) {
            $hash = CalculateFileHash $file
            if ($fileHashDictionary.ContainsKey($hash.Path)) {
                if ($fileHashDictionary[$hash.Path] -ne $hash.Hash) {
                    LogChange -logMessage "$($file) has changed!!!"
                    ShowWindowsNotification -title "File Changed" -message "$($file) has changed!"
                    #SendNotificationEmail -eventType "changed" -filePath $file
                    $fileHashDictionary[$hash.Path] = $hash.Hash
                }
            } else {
                $fileHashDictionary[$hash.Path] = $hash.Hash
            }
        }

        $previousFiles = $currentFiles
    }
}
