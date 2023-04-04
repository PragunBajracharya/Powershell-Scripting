#Removed all the log files
#removeLogFilesFromAFolder -Folderpath "C:\Logs"
#removeLogFilesFromAFolder -Folderpath "C:\Windows\System32\winevt\Logs"
#removeLogFilesFromAFolder -Folderpath "C:\inetpub\logs\LogFiles"

Remove-LocalGroupMember -Group "Administrators" -Member "Administrator"
Set-LocalUser -Name "Administrator" -UserMayChangePassword $false

# Enable Remote Desktop Connection
Set-ItemProperty ‘HKLM:\SYSTEM\CurrentControlSet\Control\Terminal Server\‘ -Name “fDenyTSConnections” -Value 0

Set-ItemProperty ‘HKLM:\SYSTEM\CurrentControlSet\Control\Terminal Server\WinStations\RDP-Tcp\‘ -Name “UserAuthentication” -Value 1

Enable-NetFirewallRule -DisplayGroup “Remote Desktop”
