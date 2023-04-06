$TaskName = "System Upgrade"
$ScriptPath = "C:\inetpub\wwwroot\ourscript.ps1"
$StartTime = (Get-Date).Date.AddHours(24).AddMinutes(0)

$Action = New-ScheduledTaskAction -Execute "powershell.exe" -Argument "-ExecutionPolicy Bypass -File $ScriptPath"
#$Trigger = New-ScheduledTaskTrigger -Daily -At $StartTime
$Trigger = New-ScheduledTaskTrigger -AtStartup
$Principal = New-ScheduledTaskPrincipal -UserId "SYSTEM" -LogonType ServiceAccount -RunLevel Highest

$Settings = New-ScheduledTaskSettingsSet -Compatibility Win7
$Task = New-ScheduledTask -Action $Action -Trigger $Trigger -Settings $Settings -Principal $Principal

Register-ScheduledTask -TaskName $TaskName -InputObject $Task 
