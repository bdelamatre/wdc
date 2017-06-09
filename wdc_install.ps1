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

	if (Get-Command $cmdName -errorAction SilentlyContinue)
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
		
		#open the chocolatey log
		Invoke-Item "%PROGRAMDATA%\chocolatey\logs\chocolatey.log"
	
	}
	
}
else
{

	Write-Host "Choclatey failed to install properly"

}