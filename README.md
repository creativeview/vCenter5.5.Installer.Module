vCenter5.5.Installer.Module
===========================

PowerShell Module to install VMware vSphere vCenter 5.5.  Designed for automated installation of vCenter with data stored in a JSON file. This has been tested on Windows Server 2012 with a MS SQL 2008 database. The vCenter service runs as a domain account. 

A guide to what the parameters are used for can be found in the "Command-Line Installation and 
Upgrade of VMware vCenter Server 5.5" here: http://www.vmware.com/files/pdf/techpaper/vcenter_server_cmdline_install.pdf

####User Account Control (UAC) 
Best have this disabled while running the module.

####Required Administrator Rights for Installation
Installation of all vCenter Server components requires Administrator‐level privilege. Make sure the VPX_ACCOUNT has Logon as a service rights. 

##Example 
```powershell
Import-Module vcenterInstallation -force
Install-vCenter "D:\data\vcenter.json"
```
