###########################################################################
#  Windows Desktop Configuration Dependency Installation
###########################################################################
#
#  This script will install the dependencies for Windows Configuration 
#  Script.
#
#
#  This script does the following:
# 
#  - Install Choclately
#  - Install Puppet Agent
#    - Install pupppetlabs/windows module
#    - Install pupppetlabs/vcsrepo module
#
#
#  You must ensure Get-ExecutionPolicy is not Restricted. Run the
#  following command from PowerShell prior to running this
#  script
# 
#      Set-ExecutionPolicy Bypass
#
#

Write-Host "Checking for elevated priveleges..." -nonewline

# Ask for elevated privelege if needed
If (!([Security.Principal.WindowsPrincipal][Security.Principal.WindowsIdentity]::GetCurrent()).IsInRole([Security.Principal.WindowsBuiltInRole]"Administrator")) {
    Start-Process powershell.exe "-NoProfile -ExecutionPolicy Bypass -File `"$PSCommandPath`"" -Verb RunAs
    Exit
}

Write-Host "[OK]"

# From Choclately: https://chocolatey.org/install
# Don't forget to ensure ExecutionPolicy above
iex ((New-Object System.Net.WebClient).DownloadString('https://chocolatey.org/install.ps1'))

# Make sure that Chocolatey installed properly
if (Get-Command "choco" -errorAction SilentlyContinue)
{

	# Install puppet using chocalately
	choco install puppet --yes

	# Check if Puppet installed properly
	if (Get-Command "puppet" -errorAction SilentlyContinue)
	{

		#install puppet windows module
		puppet module install puppetlabs/windows

		#install puppet vcssrepo module
		puppet module install puppetlabs/vcsrepo

		Write-Host "All dependencies for WDC have been installed."
		Write-Host "You can now apply WDC Puppet manifests using the following command:"
		Write-Host ""
		Write-Host "    puppet apply my_manifest_name.pp"
		Write-Host ""
		Write-Host "Be sure to replace my_manifest_name with your script's name"

	}
	else
	{
		
		Write-Host "Puppet failed to install properly"
		Write-Host "Puppet may have failed to install due to UAC settings. Would you like to apply a registry setting to disable UAC?"
		
		#fix-me: we should check the registry to see if this setting is already correct
		$DisableUAC = Read-Host -Prompt "Disable UAC? [Y/n]"
		
		if($DisableUAC -ne "n"){
		
			Write-Host "Changing EnableLUA at HKEY_LOCAL_MACHINE\Software\Microsoft\Windows\CurrentVersion\Policies\System"
			reg add HKEY_LOCAL_MACHINE\Software\Microsoft\Windows\CurrentVersion\Policies\System /v EnableLUA /d 0 /t REG_DWORD /f /reg:64
		
			Write-Host "You will need to reboot Windows for this change to take effect?"
			$Reboot = Read-Host -Prompt "Reboot? [Y/n]"
			
			if($Reboot -ne "n"){
				Restart-Computer
			}
		
		}else{
		
			Write-Host "Understood. You may try rebooting and running this scrupt again."
			Write-Host "Check https://docs.puppet.com/pe/latest/troubleshooting_windows.html for troubleshooting help."
		
			$OpenLog = Read-Host -Prompt "Open Chocolatey? [Y/n]"
			
			if($OpenLog -ne "n"){
			
				#open the chocolatey log
				Invoke-Item $env:programData + "\chocolatey\logs\chocolatey.log"		
			
			}

		}
	
	}
	
}
else
{

	Write-Host "Choclatey failed to install properly"

}