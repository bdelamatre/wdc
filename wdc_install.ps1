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

# Ask for elevated privelege if needed
If (!([Security.Principal.WindowsPrincipal][Security.Principal.WindowsIdentity]::GetCurrent()).IsInRole([Security.Principal.WindowsBuiltInRole]"Administrator")) {
    Start-Process powershell.exe "-NoProfile -ExecutionPolicy Bypass -File `"$PSCommandPath`"" -Verb RunAs
    Exit
}

# From Choclately: https://chocolatey.org/install
# Don't forget to ensure ExecutionPolicy above
iex ((New-Object System.Net.WebClient).DownloadString('https://chocolatey.org/install.ps1'))

# Install puppet using chocalately
choco install puppet

#install puppet windows module
puppet module install puppetlabs/windows

#install puppet vcssrepo module
puppet module install puppetlabs/vcsrepo