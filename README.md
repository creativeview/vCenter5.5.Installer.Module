vCenter 5.5 Installer PowerShell Module
=======================================

PowerShell Module to install VMware vSphere vCenter 5.5.  Designed for automated installation of vCenter with data stored in a JSON file. This has been tested on Windows Server 2012 with a MS SQL 2008 database. The vCenter service runs as a domain account. 

A guide to what the parameters are used for can be found in the "Command-Line Installation and 
Upgrade of VMware vCenter Server 5.5" here: http://www.vmware.com/files/pdf/techpaper/vcenter_server_cmdline_install.pdf

####User Account Control (UAC) 
Best have this disabled while running the module.

####Required Administrator Rights for Installation
Installation of all vCenter Server components requires Administrator‐level privilege. Make sure the VPX_ACCOUNT has Logon as a service rights. 

The Set-ServiceLogonRight_JSON or Set-ServiceLogonRight cmdlet can be used to set the Logon As Service right to a account. The Carbon PowerShell module is used to provide this function and included as part of this vCenter Installer module. 

```powershell
Set-ServiceLogonRight_JSON -ConfigFilePath "C:\data\vcenter.json"  
```

or 

```powershell
Set-ServiceLogonRight -ServiceLogonRightAccount "domain\account"
```

##Example using JSON input
```powershell
Import-Module vcenterInstallation -force

Set-ServiceLogonRight_JSON -ConfigFilePath "C:\data\vcenter.json"

Install-MSVC2005_JSON -ConfigFilePath "C:\data\vcenter.json"

Install-VMwareSSO_JSON -ConfigFilePath "C:\data\vcenter.json"

Install-VMwareInventoryService_JSON -ConfigFilePath "C:\data\vcenter.json"

Install-VMwarevCenter_JSON -ConfigFilePath "C:\data\vcenter.json"

Install-VMwarevSphereClient_JSON -ConfigFilePath "C:\data\vcenter.json"

Install-VMwarevSphereWebClient_JSON -ConfigFilePath "C:\data\vcenter.json"

```

##Example with no JSON data file input
```powershell
Import-Module vcenterInstallation -force

Install-MSVC2005 -vCenterBaseInstallPath "C:\Software\VMware\vCenter 5.5a\"

Install-VMwareSSO -vCenterBaseInstallPath "C:\Software\VMware\vCenter 5.5a\" -SSO_PWD "password" -SSO_DeployMode "FIRSTDOMAIN" -SSO_Site "TestSite" -SSO_HTTPport "7444"

Install-VMwareInventoryService -vCenterBaseInstallPath "C:\Software\VMware\vCenter 5.5a\" -vcenterIPAddress "vcenteraddress.domain.local" -SSO_ADMIN "administrator@vsphere.local" -SSO_PWD "password" -SSO_HTTPport "7444" -InventoryService_HTTPS_PORT "10443" -InventoryService_XDB_PORT "10109" -InventoryService_FEDERATION_PORT "10111" -InventoryService_QUERY_SERVICE_NUKE_DATABASE "0" -InventoryService_TOMCAT_MAX_MEMORY_OPTION "S"

Install-VMwarevCenter -vCenterBaseInstallPath "C:\Software\VMware\vCenter 5.5a\" -vcenterIPAddress "vcenteraddress.domain.local" -SSO_ADMIN "administrator@vsphere.local" -SSO_PWD "password" -SSO_HTTPport "7444" -VC_ADMIN_USER "administrator@vsphere.local" -vCenter_FORMAT_DB "1" -vCenter_JVM_MEMORY_OPTION "S" -DB_DSN "vCenter" -VPX_ACCOUNT "domain\administrator" -VPX_PASSWORD "password" 

Install-VMwarevSphereClient  -vCenterBaseInstallPath "C:\Software\VMware\vCenter 5.5a\"

Install-VMwarevSphereWebClient -vCenterBaseInstallPath "C:\Software\VMware\vCenter 5.5a\" -vcenterIPAddress "vcenteraddress.domain.local" -SSO_ADMIN "administrator@vsphere.local" -SSO_PWD $SSO_PWD -SSO_HTTPport "password" 
```


