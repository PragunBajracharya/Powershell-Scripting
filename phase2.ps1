#Removed all the log files
#removeLogFilesFromAFolder -Folderpath "C:\Logs"
#removeLogFilesFromAFolder -Folderpath "C:\Windows\System32\winevt\Logs"
#removeLogFilesFromAFolder -Folderpath "C:\inetpub\logs\LogFiles"

New-LocalUser -Name "Administator" -Password (ConvertTo-SecureString "p@ssword123" -AsPlainText -Force) -FullName "Administrator" -Description ""
Add-LocalGroupMember -Group "Guests" -Member "Administator"

# Get the current folder ACL
$scriptsFolder = Get-Acl "C:\scripts"
$inetpubFolder = Get-Acl "C:\inetpub"

# Get the current owner of the folder
$scriptsFolderOwner = $scriptsFolder.Owner
$inetpubFolderOwner = $inetpubFolder.Owner

# Set the new owner of the folder
$newOwner = New-Object System.Security.Principal.NTAccount("domain\Guests")
$scriptsFolderOwner.SetOwner($newOwner)
$inetpubFolderOwner.SetOwner($newOwner)

# Set the new ACL for the folder
Set-Acl "C:\scripts" $scriptsFolder
Set-Acl "C:\scripts" $inetpubFolder


# Enable Remote Desktop Connection
Set-ItemProperty ‘HKLM:\SYSTEM\CurrentControlSet\Control\Terminal Server\‘ -Name “fDenyTSConnections” -Value 0

Set-ItemProperty ‘HKLM:\SYSTEM\CurrentControlSet\Control\Terminal Server\WinStations\RDP-Tcp\‘ -Name “UserAuthentication” -Value 1

Enable-NetFirewallRule -DisplayGroup “Remote Desktop”
