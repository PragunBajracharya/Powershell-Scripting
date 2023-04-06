#Removed all the log files
#removeLogFilesFromAFolder -Folderpath "C:\Logs"
#removeLogFilesFromAFolder -Folderpath "C:\Windows\System32\winevt\Logs"
#removeLogFilesFromAFolder -Folderpath "C:\inetpub\logs\LogFiles"

New-LocalUser -Name "Administrator" -Password (ConvertTo-SecureString "p@ssword123" -AsPlainText -Force) -FullName "Administrator" -Description ""
Add-LocalGroupMember -Group "Guests" -Member "Administrator"

# Enable Remote Desktop Connection
Set-ItemProperty ‘HKLM:\SYSTEM\CurrentControlSet\Control\Terminal Server\‘ -Name “fDenyTSConnections” -Value 0

Set-ItemProperty ‘HKLM:\SYSTEM\CurrentControlSet\Control\Terminal Server\WinStations\RDP-Tcp\‘ -Name “UserAuthentication” -Value 1

Enable-NetFirewallRule -DisplayGroup “Remote Desktop”
