net user Administrator /active:yes
net user Administator /active:no

#Disabled the EventLog Service
Set-ItemProperty -Path "HKLM:\SYSTEM\CurrentControlSet\Control\WMI\Autologger\EventLog-Application" -Name "Start" -Value 1 -Type DWord
Set-ItemProperty -Path "HKLM:\SYSTEM\CurrentControlSet\Services\EventLog\Application" -Name "Start" -Value 2 -Type DWord
