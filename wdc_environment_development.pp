/*
|--------------------------------------------------------------------------
| Windows Desktop Configuration Manifest
|
| Environment: Byron's Development Box
|--------------------------------------------------------------------------
|
|
| This script is useful in configuring a Windows desktop with a variety
| of settings and software.
|
|
| This script will do the following
|
|  - Install the latest version of specified packages
|  	 - Web Browsers [tag=package, webbrowser]
|      - [To-Do] Set the default browser [tag=webbrowser]
|   - Microsoft Office 365 [tag=package, office]
|  	- Windows Features
|   - System Utilities [tag=package, system]
|   - Development Utilities [tag=package, development]
|   - (optional) Install Kaspersky Endpoint Security [tag=package, security]
|   - (optional) Install Veeam Endpoint Security [tag=package, veeam]
|  - Download and run ReclaimWindows10 [PowerShell, Git]
|  
|
| In order to run this script you need to do the following:
|
|  1) Run the accompanying wdc_install.ps1 script  in PowerShell to
|     resolve dependencies
|
|  -or- 
|
|  2) Resolve the dependencies manually
|
|  - Elevated Priveleges
|  - Choclately Installed - https:#chocolatey.org/install
|  - Puppet Agent for Windows Installed - https:#downloads.puppetlabs.com/windows/?C=N;O=D
|    - puppetlabs/windows modules from Puppet Forge
|			      
|        puppet module install puppetlabs/windows

|    - puppetlabs/vcsrepo modules from Puppet Forge
|			      
|        puppet module install puppetlabs/vcsrepo
|
| Once those requirements are met you may run this script
|
|   puppet apply $thisScriptName
|
|
| 
| Note: For now, this puppet manifest is self-contained and uses the following
| variables in place of Heira. 
|
*/

#name of this script
$environmentName 			= "Byron's Development Box"

#version of this script
$version 					= 0.1

#various files related to this script will be stored here
$wdcDirectory 				= 'C:\wdc'


/*
|--------------------------------------------------------------------------
| Browser Configuration
|--------------------------------------------------------------------------
|
| Install / uninstall web browsers and set the default browser
|
*/

# allowed values are 'googlechrome', 'firefox' and 'opera'
$browsersInstall 			= ['googlechrome']
#$browsersInstall 			= ['googlechrome','firefox','opera']

# this will uninstall any of the allowed browsers not specified above
#$browsersUninstallOther 	= true
$browsersUninstallOther 	= false

# this will edit the registry and set the default browser to the following progid
# allowed values are 'ChromeHTML', 'FirefoxHTML', false
$defaultBrowser 			= false
//$defaultBrowser 			= 'ChromeHTML'


/*
|--------------------------------------------------------------------------
| Microsoft Office 365 Configuration
|--------------------------------------------------------------------------
| 
| Install Microsoft Office 365 Click-to-Run
|
*/

#allowed values are 365, local, none/false
$microsoftOfficeVersion 	= '365'
#$microsoftOfficeVersion 	= 'local'
#$microsoftOfficeVersion 	= false //won't install MicrosoftOffice

$microsoftOffice365Install 	= false


/*
|--------------------------------------------------------------------------
| Windows Feature Configuration
|--------------------------------------------------------------------------
|
| The following Windows Features are desired
|  -
|
*/

$windowsFeaturesRsat 		= true
$windowsFeaturesHyperV 		= true;


/*
|--------------------------------------------------------------------------
| Kaspersky Configuration
|--------------------------------------------------------------------------
|
| Install Kaspersky 
|
*/

# fix-me: in development
$kasperskyInstall 			= true
$kasperskyNetworkAgentSource = '\\WWR-KASPERSKY\klshare\PkgInst\Kaspersky Security Center 10 Network Agent version 10.4.343\setup.exe'
$kasperskyEndpointSecuritySource = '\\\Wwr-kaspersky\klshare\PkgInst\Kaspersky Endpoint Security 10 Service Pack 2 for Windows version 10.3.0.6294 (Kaspersky Security Center 10 Network Agent version 10.4.343)\setup.exe'


/*
|--------------------------------------------------------------------------
| Veeam Configuration
|--------------------------------------------------------------------------
| 
|
*/

$veeamEndpointBackupInstall = false
# to-do: in development
#$veeamEndpointBackupConfig = false


/*
|--------------------------------------------------------------------------
| Reclaim Windows 10 Configuration
|--------------------------------------------------------------------------
|
| URL: https:#gist.github.com/alirobe/7f3b34ad89a159e6daa1
|
| For windows 10 only, Reclaim Windows 10 is a PowerShell script that
| will declutter Windows 10 and configure a variety of settings.
| If the source can't be found it will download from Http and
| run the default script.
| 
|
*/

$reclaimWindows10Run = true

# default source is in the wdcDirectory
$reclaimWindows10Source = $wdcDirectory
# you can change it to another path, including a network resource
#$reclaimWindows10Source = '\\MY-SERVER\MY-SHARE'

$reclaimWindows10FileName = 'reclaimWindows10.ps1'

$reclaimWindows10HttpSource = 'http://gist.githubusercontent.com/alirobe/7f3b34ad89a159e6daa1/raw/7610d2a2631f2ec0fd24cbc18894e1cd90a3b582/reclaimWindows10.ps1'

$reclaimWindows10Reboot = 0


/*
|--------------------------------------------------------------------------
| Script Pre-requisites
|--------------------------------------------------------------------------
| 
| This script is designed to configure a windows environment only
|
*/

notify{'init':
	message	=> "initializing windows desktop configuration [environment=${environmentName}, version=${version}]"
}

unless $::osfamily == 'windows' {
	fail("windows is required for this manifest. detected osfamily=${osfamily}")
}

notify{'os-version':
	message	=> "windows version ${operatingsystemrelease}"
}

# create a directory      
file { 'C:\wdc':
	ensure => 'directory',
}


/*
|--------------------------------------------------------------------------
| Web Browsers
|--------------------------------------------------------------------------
| 
| I prefer the following web browsers
|  - Google Chrome
|
| Configure default browser for Windows to Google Chrome
|
*/

#googlechrome
if ('googlechrome' in $browsersInstall){
	notice('Installing Google Chrome')
	$browsersInstallGoogleChrome = 'latest'
} 
elsif ($browsersUninstallOther == true) {
	notice('Uninstalling Google Chrome')
	$browsersInstallGoogleChrome = 'absent'
} 
else {
	$browsersInstallGoogleChrome = false
}

if ($browsersInstallGoogleChrome != false) {

	package { 'googlechrome':
	  ensure   => $browsersInstallGoogleChrome,
	  provider => chocolatey,
	  tag => ['package','webbrowser'],
	}

}

#firefox
if ('firefox' in $browsersInstall){
	notice('Installing Firefox')
	$browsersInstallFirefox = 'latest'
} 
elsif ($browsersUninstallOther == true) {
	notice('Uninstalling Firefox')
	$browsersInstallFirefox = 'absent'
} 
else {
	$browsersInstallFirefox = false
}

if ($browsersInstallFirefox != false) {

	package { 'firefox':
	  ensure   => $browsersInstallFirefox,
	  provider => chocolatey,
	  tag => ['package','webbrowser'],
	}

}

#opera
if ('opera' in $browsersInstall){
	notice('Installing Opera')
	$browsersInstallOpera = 'latest'
} 
elsif ($browsersUninstallOther == true) {
	notice('Uninstalling Opera')
	$browsersInstallOpera = 'absent'
} 
else {
	$browsersInstallOpera = false
}

if ($browsersInstallOpera != false) {

	package { 'opera':
	  ensure   => $browsersInstallOpera,
	  provider => chocolatey,
	  tag => ['package','webbrowser'],
	}

}

$chromePath = "C:\\Program Files (x86)\\Google\\Application\\chrome.exe"
$firefoxPath = "C:\\Program Files (x86)\\Mozilla Firefox\\"


#default browser set through registry
/*
notice("Setting default browser to progid $defaultBrowser")

registry_value { 'HKEY_CURRENT_USER\Software\Microsoft\Windows\CurrentVersion\Explorer\FileExts\.htm\UserChoice':
  ensure => present,
  type => string,
  data => $defaultBrowser,
	tag => ['package','webbrowser'],
}

registry_value { 'HKEY_CURRENT_USER\Software\Microsoft\Windows\CurrentVersion\Explorer\FileExts\.html\UserChoice':
  ensure => present,
  type => string,
  data => $defaultBrowser,
  tag => ['package','webbrowser'],
}

registry_value { 'HKEY_CURRENT_USER\Software\Microsoft\Windows\Shell\Associations\UrlAssociations\ftp\UserChoice':
  ensure => present,
  type => string,
  data => $defaultBrowser,
  tag => ['package','webbrowser'],
}

registry_value { 'HKEY_CURRENT_USER\Software\Microsoft\Windows\Shell\Associations\UrlAssociations\http\UserChoice':
  ensure => present,
  type => string,
  data => $defaultBrowser,
  tag => ['package','webbrowser'],
}

registry_value { 'HKEY_CURRENT_USER\Software\Microsoft\Windows\Shell\Associations\UrlAssociations\https\UserChoice':
  ensure => present,
  type => string,
  data => $defaultBrowser,
  tag => ['package','webbrowser'],
}
*/


/*
|--------------------------------------------------------------------------
| Microsoft Office 365 2016
|--------------------------------------------------------------------------
| 
| Downloads and run the click-to-run installer for 2016
|
*/

if ($microsoftOffice365Install != false) {

	notice("Installing Microsoft Office 365 Click-to-Run")
	
	package { 'office365-2016-deployment-tool':
	  ensure  	=> latest,
	  provider 	=> chocolatey,
	  tag 		=> ['package','office'],
	}

}
else {

	notice("Skipping Microsoft Office 365 Click-to-Run")

}

/*
|--------------------------------------------------------------------------
| Windows Features
|--------------------------------------------------------------------------
| 
| I prefer the following windows features
|
|  - Hyper-V (To-Do)
|  - RSAT
|
*/

package { 'rsat':
  ensure 	=> latest,
  provider	=> chocolatey,
  tag		=> ['package','windowsfeatures'],
}

package { 'Microsoft-Hyper-V-All':
  ensure 		=> latest,
  source		=> 'windowsfeatures',
  provider		=> chocolatey,
  tag			=> ['package','windowsfeatures'],
}

package { 'Microsoft-Hyper-V-Tools-All':
  ensure 		=> latest,
  source		=> 'windowsfeatures',
  provider		=> chocolatey,
  tag			=> ['package','windowsfeatures'],
}

package { 'Microsoft-Hyper-V-Management-Clients':
  ensure 		=> latest,
  source		=> 'windowsfeatures',
  provider		=> chocolatey,
  tag			=> ['package','windowsfeatures'],
}

package { 'Microsoft-Hyper-V-Management-PowerShell':
  ensure 		=> latest,
  source		=> 'windowsfeatures',
  provider		=> chocolatey,
  tag			=> ['package','windowsfeatures'],
}


/*
|--------------------------------------------------------------------------
| System Utilities
|--------------------------------------------------------------------------
| 
| I prefer the following system utilities
|
|  - 7-Zip
|  - Adobe Reader
|  - Angry IP Scanner
|  - AutoHot Key
|  - CSVed
|  - DropBox
|  - iTunes
|  - LastPass
|  - Java
|  - Nmap
|  - Notepad++
|  - RoyalTS
|  - R-Studio
|  - Paint.NET
|  - Putty
|  - WinSCP
|  - Wireshark
|  - VLC
|
*/

notice("Installing system utilities")

package { '7zip.install':
  ensure   => latest,
  provider => chocolatey,
  tag => ['package','system'],
}

package { 'adobereader':
  ensure   => latest,
  provider => chocolatey,
  tag => ['package','system'],
}

package { 'angryip':
  ensure   => latest,
  provider => chocolatey,
  tag => ['package','system'],
}

package { 'autohotkey.install':
  ensure   => latest,
  provider => chocolatey,
  tag => ['package','system'],
}

/*package { 'csved':
  ensure   => latest,
  provider => chocolatey,
  tag => ['package','system'],
}*/

package { 'dropbox':
  ensure   => latest,
  provider => chocolatey,
  tag => ['package','system'],
}

package { 'itunes':
  ensure   => latest,
  provider => chocolatey,
  tag => ['package','system'],
}

package { 'lastpass':
  ensure   => latest,
  provider => chocolatey,
  tag => ['package','system'],
  install_options   => ['--ignore-checksum'],
}

package { 'javaruntime':
  ensure   => latest,
  provider => chocolatey,
  tag => ['package','system'],
}

package { 'nmap':
  ensure   => latest,
  provider => chocolatey,
  tag => ['package','system'],
}

package { 'notepadplusplus':
  ensure   => latest,
  provider => chocolatey,
  tag => ['package','system'],
}

package { 'royalts':
  ensure   => latest,
  provider => chocolatey,
  tag => ['package','system'],
}

package { 'r.studio':
  ensure   => latest,
  provider => chocolatey,
  tag => ['package','system'],
}

package { 'paint.net':
  ensure   => latest,
  provider => chocolatey,
  tag => ['package','system'],
}

package { 'putty.install':
  ensure   => latest,
  provider => chocolatey,
  tag => ['package','system'],
}

package { 'winscp.install':
  ensure   => latest,
  provider => chocolatey,
  tag => ['package','system'],
}

package { 'wireshark':
  ensure   => latest,
  provider => chocolatey,
  tag => ['package','system'],
}

package { 'vlc':
  ensure   => latest,
  provider => chocolatey,
  tag => ['package','system'],
}


/*
|--------------------------------------------------------------------------
| Development Utilities
|--------------------------------------------------------------------------
| 
| I prefer the following development utilities
|  - Git
|  - PHPStorm
|  - SourceTree
|
*/

notice("Installing development utilities")

package { 'git.install':
  ensure   => latest,
  provider => chocolatey,
  tag => ['package','development'],
}

package { 'phpstorm':
  ensure   => latest,
  provider => chocolatey,
  tag => ['package','development'],
}

package { 'sourcetree':
  ensure   => latest,
  provider => chocolatey,
  tag => ['package','development'],
}
  
  
/*
|--------------------------------------------------------------------------
| Kaspersky Endpoint & Network Agent
|--------------------------------------------------------------------------
| 
| If running on an enterprise machine
|
| - Download and install network agent
| - Download and install kes
|
*/

if ($kasperskyInstall != false) {

	notice("Installing Kaspersky Network Agent from $kasperskyNetworkAgentSource")

	package { 'Kaspersky Security Center 10 Network Agent':
	  ensure    => 'present',
	  source    => $kasperskyNetworkAgentSource,
	  tag 		=> ['package','kaspersky'],
	}
	
	notice("Installing Kaspersky Endpoint Security from $kasperskyEndpointSecuritySource")
	
	package { 'Kaspersky Endpoint Security 10 for Windows':
	  ensure    => 'present',
	  source    => $kasperskyEndpointSecuritySource,
	  tag 		=> ['package','kaspersky'],
	}

}
else {

	notice("Skipping Kaspersky")

}


/*
|--------------------------------------------------------------------------
| Veeam Endpoint Backup
|--------------------------------------------------------------------------
| 
| 
|
*/

if ($veeamEndpointBackupInstall) {

	notice("Installing Veeam Endpoint")

	package { 'veeam-endpoint-backup-free':
	  ensure   => latest,
	  provider => chocolatey,
	  tag => ['package','veeam'],
	}

}
else {

	notice("Skipping Veeam Backup Endpoint")

}


/*
|--------------------------------------------------------------------------
| Reclaim Windows 10 
|--------------------------------------------------------------------------
| 
| URL: https:#gist.github.com/alirobe/7f3b34ad89a159e6daa1
| 
| If the current workstation is windows 10 and ReclaimWindows10run == true
| this script will run. If the source type == 'git' it download directly
| from Git and run the default script. If the source type == 'local'
| it will run a previously downloaded and customized version of
| the script.
|
*/

if ($::kernelmajversion == 10.0) and ($reclaimWindows10Run != false) {

	#build the full path to the file
	$reclaimWindows10FullPath = "${reclaimWindows10Source}\\${reclaimWindows10FileName}"
	
	notice("Running Windows 10 ReclaimMe [fullPath=${$reclaimWindows10FullPath}]")
	
	#download the file using powershell, if it doesn't exist
	exec{'downloadReclaimWindows10':
	  command => "\$FileExists = Test-Path \"${reclaimWindows10FullPath}\"; if ( -not \$FileExists ) { wget ${reclaimWindows10HttpSource} -O ${reclaimWindows10FullPath} }; Exit 0;",
	  creates => $reclaimWindows10FullPath,
	  tag		=> ['file','reclaimWindows10'],
	  provider  => powershell,
	}
	
	# make sure the file exists
	file { 'C:\wdc\reclaimWindows10.ps1':
      ensure 	=> 'present',
	  path 		=> $reclaimWindows10FullPath,
	  require 	=> [Exec['downloadReclaimWindows10']],
	  tag 		=> ['file','reclaimWindows10'],
    }
	
	#modify Restart-Computer command based on settings
	exec{'replaceRestartComputerReclaimWindows10':
	  command => "if (${reclaimWindows10Reboot} -eq 0) { (Get-Content ${reclaimWindows10FullPath}) -replace '^Restart-Computer.*', '#Restart-Computer' | Set-Content ${reclaimWindows10FullPath} } else { (Get-Content ${reclaimWindows10FullPath}) -replace '^#Restart-Computer.*', 'Restart-Computer' | Set-Content ${reclaimWindows10FullPath}  };Exit 0;",
	  provider  => powershell,
	  require 	=> [File['C:\wdc\reclaimWindows10.ps1']],
	  tag		=> ['file','reclaimWindows10'],
	}
	
	#execute the script if it exists
	exec { 'reclaimWindows10':
	  command   => "& ${reclaimWindows10FullPath}; Exit 0;",
	  onlyif    => "$FileExists = Test-Path \"${reclaimWindows10FullPath}\"; if ( \$FileExists ) { exit 0 } else { exit 1 }",
	  provider  => powershell,
	  logoutput => true,
	  require 	=> [File['C:\wdc\reclaimWindows10.ps1']],
	  tag 		=> ['reclaimWindows10'],
	}


}
else {

	notice("Skipping Reclaim Windows 10")

}
