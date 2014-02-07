## =====================================================================
## Title       : VMware vCenter 5.5 Installation
## Description : This will install the selected components of VMware vCenter 5.5
## Author      : David Balharrie
## Date        : 07/02/2014
## Notes       : More information about this scipt can be found at
##               http://creativeview.co.uk
## Version     : 1.1.1
## =====================================================================

function Test-NotNull()
{
param(
[parameter(ValueFromPipeline=$true)]
[string]$Value
)
    if ([string]::IsNullOrEmpty($Value) -ne $true)
    {   
        return $true
    }
    else
    {
        return $false
    }
}


function Execute-Installer()
{
param(
[parameter(Mandatory=$true,ValueFromPipeline=$true)]
[ValidateNotNullOrEmpty()]
[string]$FilePath,
[parameter(Mandatory=$true,ValueFromPipeline=$true)]
[ValidateNotNullOrEmpty()]
[string]$argslist,
[parameter(Mandatory=$true,ValueFromPipeline=$true)]
[ValidateNotNullOrEmpty()]
[string]$Package
)

	$ExitCode = (Start-Process -FilePath $FilePath -ArgumentList $argslist -Wait -Passthru).ExitCode
	if($ExitCode -eq 0)
	{
		Write-Host ("Successfully installed " + $Package) -ForegroundColor Green
	}
	else
	{
		Write-Host ("There has been an error installing " + $Package + ". The error code was: " + $ExitCode) -ForegroundColor Red
	}
    Return $ExitCode
}



function Get-ConfigFile()
{
param(
    [parameter(Mandatory=$true,ValueFromPipeline=$true)][ValidateNotNullOrEmpty()][string]$ConfigFilePath
)
        # check Config File exists
        if(Test-Path($ConfigFilePath))
        {
        
            [System.Reflection.Assembly]::LoadWithPartialName("System.Web.Extensions")
            $content = [IO.File]::ReadAllText($ConfigFilePath)
            $json = $content
            $ser = New-Object System.Web.Script.Serialization.JavaScriptSerializer
            $JSONobj = $ser.DeserializeObject($json)

            $InstallParameters = @{}

            foreach ($node in $JSONobj.InstallParameters.Keys)
            {
                $InstallParameters.Add($node,$JSONobj.InstallParameters.Item($node))
            }

            return $InstallParameters
        }
}


function Install-MSVC2005_JSON{
<#
   .Synopsis
        Runs the Microsoft Visual C++ 2005 Redistributable Package setup.
    .Description
        
    .Example
     Install-MSVC2005 -ConfigFilePath "C:\data\data.json"
    
    .PARAMETER ConfigFilePath
    The path to the json data file containing the configuration.

    .NOTES
    Version: 1.1
    Date: 03/02/2014
    Tag: 
#>
[CmdletBinding()]
    Param
    (
    [parameter(Mandatory=$true,ValueFromPipeline=$true)][ValidateNotNullOrEmpty()][string]$ConfigFilePath
    )
    process {

    $InstallParameters = Get-ConfigFile -ConfigFilePath $ConfigFilePath
    
    if ((Test-NotNull -Value $InstallParameters.("vCenterBaseInstallPath")) -eq $false) { Write-host "The value vCenterBaseInstallPath can't be null. Script terminating. " -ForegroundColor Red; break} else {$vCenterBaseInstallPath = $InstallParameters.("vCenterBaseInstallPath")}
    
    Return Install-MSVC2005 -vCenterBaseInstallPath $vCenterBaseInstallPath
 }
    end {
        
    }
}


function Install-MSVC2005{
<#
   .Synopsis
        Runs the Microsoft Visual C++ 2005 Redistributable Package setup.
    .Description
        
    .Example
     Install-MSVC2005 -vCenterBaseInstallPath "C:\Software\VMware\vCenter 5.5a\"
    
    .PARAMETER vCenterBaseInstallPath
    The base location of the VMware vCenter installation. 
    

    .NOTES
    Version: 1.1
    Date: 03/02/2014
    Tag: 
#>
[CmdletBinding()]

    Param
    (

    [parameter(Mandatory=$true,ValueFromPipeline=$true)][ValidateNotNullOrEmpty()][string]$vCenterBaseInstallPath
    )    
    process {

    #===================================================#
    # Install Microsoft Visual C++ 2005 Redistributable #
    #===================================================# 
	$Package = "Microsoft Visual C++ 2005 Redistributable"
	
	Write-Host ("Installing " + $Package) -ForegroundColor Green
	
	$setupexe = ($vCenterBaseInstallPath+"redist\vcredist\2005\vcredist_x86.exe")

	$argslist = ' /Q'
	
	Return Execute-Installer -FilePath $setupexe -argslist $argslist -Package $Package
 }
    end {
        
    }
}


function Install-VMwareSSO_JSON{
<#
   .Synopsis
        Runs the VMware vCenter SSO setup using JSON data file.
    .Description
        
    .Example
     Install-VMwareSSO_JSON -ConfigFilePath "C:\data\data.json"
    
    .PARAMETER ConfigFilePath
    The path to the json data file containing the configuration.

    .NOTES
    Version: 1.1
    Date: 03/02/2014
    Tag: 
#>
[CmdletBinding()]
    Param
    (
    [parameter(Mandatory=$true,ValueFromPipeline=$true)][ValidateNotNullOrEmpty()][string]$ConfigFilePath
    )
    process {

    $InstallParameters = Get-ConfigFile -ConfigFilePath $ConfigFilePath
    
    if ((Test-NotNull -Value $InstallParameters.("vCenterBaseInstallPath")) -eq $false) { Write-host "The value vCenterBaseInstallPath can't be null. Script terminating. " -ForegroundColor Red; break} else {$vCenterBaseInstallPath = $InstallParameters.("vCenterBaseInstallPath")}
    if ((Test-NotNull -Value $InstallParameters.("SSO_PWD")) -eq $false) { Write-host "The value SSO_PWD can't be null. Script terminating. " -ForegroundColor Red; break} else {$SSO_PWD = $InstallParameters.("SSO_PWD")}
    if ((Test-NotNull -Value $InstallParameters.("SSO_DeployMode")) -eq $false) { Write-host "The value SSO_DeployMode can't be null. Script terminating. " -ForegroundColor Red; break} else {$SSO_DeployMode = $InstallParameters.("SSO_DeployMode")}
    if ((Test-NotNull -Value $InstallParameters.("SSO_Site")) -eq $false) { Write-host "The value SSO_Site can't be null. Script terminating. " -ForegroundColor Red; break} else {$SSO_Site = $InstallParameters.("SSO_Site")}                    
    if ((Test-NotNull -Value $InstallParameters.("SSO_HTTPport")) -eq $false) { Write-host "The value SSO_HTTPport can't be null. Script terminating. " -ForegroundColor Red; break} else {$SSO_HTTPport = $InstallParameters.("SSO_HTTPport")}

    Return Install-VMwareSSO -vCenterBaseInstallPath $vCenterBaseInstallPath -SSO_PWD $SSO_PWD -SSO_DeployMode $SSO_DeployMode -SSO_Site $SSO_Site -SSO_HTTPport $SSO_HTTPport
 }
    end {
        
    }
}


function Install-VMwareSSO{
<#
   .Synopsis
        Runs the VMware vCenter SSO setup.
    .Description
        
    .Example
     Install-VMwareSSO
    
    .PARAMETER vCenterBaseInstallPath
    The base location of the VMware vCenter installation.

    .PARAMETER SSO_PWD
    Password for the vCenter Single Sign‐On administrator user account

    .PARAMETER SSO_DeployMode
    vSphere 5.5 supports command line installation only for vCenter Single Sign‐On primary sites (FIRSTDOMAIN). 
    Command line installation is not supported for secondary sites in a vCenter Single Sign‐On high availability or multisite deployment.

    .PARAMETER SSO_Site
    The user’s name for the vCenter Single Sign‐On site.

    .PARAMETER SSO_HTTPport
    vCenter Single Sign‐On HTTPS port number

    .NOTES
    Version: 1.1
    Date: 03/02/2014
    Tag: 
#>
[CmdletBinding()]

    Param
    (
    [parameter(Mandatory=$true,ValueFromPipeline=$true)][ValidateNotNullOrEmpty()][string]$vCenterBaseInstallPath,
    [parameter(Mandatory=$true,ValueFromPipeline=$true)][ValidateNotNullOrEmpty()][string]$SSO_PWD,
    [parameter(Mandatory=$true,ValueFromPipeline=$true)][ValidateNotNullOrEmpty()][string]$SSO_DeployMode,
    [parameter(Mandatory=$true,ValueFromPipeline=$true)][ValidateNotNullOrEmpty()][string]$SSO_Site,
    [parameter(Mandatory=$true,ValueFromPipeline=$true)][ValidateNotNullOrEmpty()][string]$SSO_HTTPport
    )
    
    process {

    #====================#
    # VMware vCenter SSO #
    #====================#
	$Package = "VMware vCenter SSO"
	
	Write-Host ("Installing " + $Package) -ForegroundColor Green
                        
	$sso_msi = ($vCenterBaseInstallPath+"Single Sign-On\VMware-SSO-Server.msi")
	
	$argslist = '/I "'+$sso_msi+'"'
	$argslist += ' /qr SSO_HTTPS_PORT='+$SSO_HTTPport+' DEPLOYMODE='+$SSO_DeployMode+' ADMINPASSWORD='+$SSO_PWD+' SSO_SITE='+$SSO_Site
	$argslist += ' /l*v '+$ENV:TEMP+'\vim-sso-msi.log'

	Return Execute-Installer -FilePath "msiexec" -argslist $argslist -Package $Package
 }
    end {
        
    }
}


function Install-VMwareInventoryService_JSON{
<#
   .Synopsis
        Runs the VMware Inventory Service setup using JSON data file.
    .Description
        
    .Example
     Install-VMwareInventoryService_JSON -ConfigFilePath "C:\data\data.json"
    
    .PARAMETER ConfigFilePath
    The path to the json data file containing the configuration.

    .NOTES
    Version: 1.1
    Date: 03/02/2014
    Tag: 
#>
[CmdletBinding()]
    Param
    (
    [parameter(Mandatory=$true,ValueFromPipeline=$true)][ValidateNotNullOrEmpty()][string]$ConfigFilePath
    )
    process {

    $InstallParameters = Get-ConfigFile -ConfigFilePath $ConfigFilePath
    
    if ((Test-NotNull -Value $InstallParameters.("vCenterBaseInstallPath")) -eq $false) { Write-host "The value vCenterBaseInstallPath can't be null. Script terminating. " -ForegroundColor Red; break} else {$vCenterBaseInstallPath = $InstallParameters.("vCenterBaseInstallPath")}
    if ((Test-NotNull -Value $InstallParameters.("vcenterIPAddress")) -eq $false) { Write-host "The value vcenterIPAddress can't be null. Script terminating. " -ForegroundColor Red; break} else {$vcenterIPAddress = $InstallParameters.("vcenterIPAddress")}
    if ((Test-NotNull -Value $InstallParameters.("SSO_ADMIN")) -eq $false) { Write-host "The value SSO_ADMIN can't be null. Script terminating. " -ForegroundColor Red; break} else {$SSO_ADMIN = $InstallParameters.("SSO_ADMIN")}
    if ((Test-NotNull -Value $InstallParameters.("SSO_PWD")) -eq $false) { Write-host "The value SSO_PWD can't be null. Script terminating. " -ForegroundColor Red; break} else {$SSO_PWD = $InstallParameters.("SSO_PWD")}
    if ((Test-NotNull -Value $InstallParameters.("SSO_HTTPport")) -eq $false) { Write-host "The value SSO_HTTPport can't be null. Script terminating. " -ForegroundColor Red; break} else {$SSO_HTTPport = $InstallParameters.("SSO_HTTPport")}
    if ((Test-NotNull -Value $InstallParameters.("InventoryService_HTTPS_PORT")) -eq $false) { Write-host "The value InventoryService_HTTPS_PORT can't be null. Script terminating. " -ForegroundColor Red; break} else {$InventoryService_HTTPS_PORT = $InstallParameters.("InventoryService_HTTPS_PORT")}
    if ((Test-NotNull -Value $InstallParameters.("InventoryService_XDB_PORT")) -eq $false) { Write-host "The value InventoryService_XDB_PORT can't be null. Script terminating. " -ForegroundColor Red; break} else {$InventoryService_XDB_PORT = $InstallParameters.("InventoryService_XDB_PORT")}
    if ((Test-NotNull -Value $InstallParameters.("InventoryService_FEDERATION_PORT")) -eq $false) { Write-host "The value InventoryService_FEDERATION_PORT can't be null. Script terminating. " -ForegroundColor Red; break} else {$InventoryService_FEDERATION_PORT = $InstallParameters.("InventoryService_FEDERATION_PORT")}
    if ((Test-NotNull -Value $InstallParameters.("InventoryService_QUERY_SERVICE_NUKE_DATABASE")) -eq $false) { Write-host "The value InventoryService_QUERY_SERVICE_NUKE_DATABASE can't be null. Script terminating. " -ForegroundColor Red; break} else {$InventoryService_QUERY_SERVICE_NUKE_DATABASE = $InstallParameters.("InventoryService_QUERY_SERVICE_NUKE_DATABASE")}
    if ((Test-NotNull -Value $InstallParameters.("InventoryService_TOMCAT_MAX_MEMORY_OPTION")) -eq $false) { Write-host "The value InventoryService_TOMCAT_MAX_MEMORY_OPTION can't be null. Script terminating. " -ForegroundColor Red; break} else {$InventoryService_TOMCAT_MAX_MEMORY_OPTION = $InstallParameters.("InventoryService_TOMCAT_MAX_MEMORY_OPTION")}

    Return Install-VMwareInventoryService -vCenterBaseInstallPath $vCenterBaseInstallPath -vcenterIPAddress $vcenterIPAddress -SSO_ADMIN $SSO_ADMIN -SSO_PWD $SSO_PWD -SSO_HTTPport $SSO_HTTPport -InventoryService_HTTPS_PORT $InventoryService_HTTPS_PORT -InventoryService_XDB_PORT $InventoryService_XDB_PORT -InventoryService_FEDERATION_PORT $InventoryService_FEDERATION_PORT -InventoryService_QUERY_SERVICE_NUKE_DATABASE $InventoryService_QUERY_SERVICE_NUKE_DATABASE -InventoryService_TOMCAT_MAX_MEMORY_OPTION $InventoryService_TOMCAT_MAX_MEMORY_OPTION 
    
 }
    end {
        
    }
}


function Install-VMwareInventoryService{
<#
   .Synopsis
        Runs VMware Inventory Service setup.
    .Description
        
    .Example
     Install-VMwareInventoryService 
    
    .PARAMETER vCenterBaseInstallPath
    The base location of the VMware vCenter installation.

    .PARAMETER vcenterIPAddress
    The address for the vCenter.

    .PARAMETER SSO_ADMIN
    User name for the vCenter Single Sign‐On administrator user account.

    .PARAMETER SSO_PWD
    Password for the vCenter Single Sign‐On administrator user account

    .PARAMETER SSO_HTTPport
    vCenter Single Sign‐On HTTPS port number
    
    .PARAMETER InventoryService_HTTPS_PORT
    Inventory Service HTTP port

    .PARAMETER InventoryService_XDB_PORT
    vCenter Inventory Service service management port

    .PARAMETER InventoryService_FEDERATION_PORT
     vCenter Inventory Service Linked Mode communication port

    .PARAMETER InventoryService_QUERY_SERVICE_NUKE_DATABASE
    Set to 1 to clear the existing database for Inventory Service

    .PARAMETER InventoryService_TOMCAT_MAX_MEMORY_OPTION
    Choices refer to vCenter Server inventory size. 
    S - Small inventory (1‐100 hosts or 1‐1000 virtual machines)
    M - Medium inventory (100‐400 hosts or 1000‐4000 virtual machines)
    L - Large inventory (more than 400 hosts or 4000 virtual machines)
    This parameter determines the maximum JVM heap settings for VMware VirtualCenter Management Webservices (Tomcat), Inventory Service, and Profile‐Driven Storage Service. 

    .NOTES
    Version: 1.1
    Date: 03/02/2014
    Tag: 
#>
[CmdletBinding()]

    Param
    (
    [parameter(Mandatory=$true,ValueFromPipeline=$true)][ValidateNotNullOrEmpty()][string]$vCenterBaseInstallPath,
    [parameter(Mandatory=$true,ValueFromPipeline=$true)][ValidateNotNullOrEmpty()][string]$vcenterIPAddress,
    [parameter(Mandatory=$true,ValueFromPipeline=$true)][ValidateNotNullOrEmpty()][string]$SSO_ADMIN,
    [parameter(Mandatory=$true,ValueFromPipeline=$true)][ValidateNotNullOrEmpty()][string]$SSO_PWD,
    [parameter(Mandatory=$true,ValueFromPipeline=$true)][ValidateNotNullOrEmpty()][string]$SSO_HTTPport,
    [parameter(Mandatory=$true,ValueFromPipeline=$true)][ValidateNotNullOrEmpty()][string]$InventoryService_HTTPS_PORT,
    [parameter(Mandatory=$true,ValueFromPipeline=$true)][ValidateNotNullOrEmpty()][string]$InventoryService_XDB_PORT,
    [parameter(Mandatory=$true,ValueFromPipeline=$true)][ValidateNotNullOrEmpty()][string]$InventoryService_FEDERATION_PORT,
    [parameter(Mandatory=$true,ValueFromPipeline=$true)][ValidateNotNullOrEmpty()][string]$InventoryService_QUERY_SERVICE_NUKE_DATABASE,
    [parameter(Mandatory=$true,ValueFromPipeline=$true)][ValidateNotNullOrEmpty()][string]$InventoryService_TOMCAT_MAX_MEMORY_OPTION
    )
    process {

    
    #==========================================#
    # Install VMware vCenter Inventory Service #
    #==========================================#
	$Package = "VMware vCenter Inventory Service"
	
	Write-Host ("Installing " + $Package) -ForegroundColor Green
            
	$setupexe = ($vCenterBaseInstallPath+"Inventory Service\VMware-inventory-service.exe")

	$argslist = '/S /L1033 /v"/qr QUERY_SERVICE_NUKE_DATABASE=' + $InventoryService_QUERY_SERVICE_NUKE_DATABASE + ' SSO_ADMIN_USER=\"' + $SSO_ADMIN + '\" SSO_ADMIN_PASSWORD=\"' + $SSO_PWD + '\"'
	$argslist += ' LS_URL=\"https://' + $vcenterIPAddress + ':'+$SSO_HTTPport+'/lookupservice/sdk\" HTTPS_PORT=' + $InventoryService_HTTPS_PORT 
    $argslist += ' FEDERATION_PORT=' + $InventoryService_FEDERATION_PORT + ' XDB_PORT=' + $InventoryService_XDB_PORT + ''
	$argslist += ' TOMCAT_MAX_MEMORY_OPTION=' + $InventoryService_TOMCAT_MAX_MEMORY_OPTION + ' /L*v \"'+$ENV:TEMP+'"\vim-qs-msi.log"\""'

	Return Execute-Installer -FilePath $setupexe -argslist $argslist -Package $Package
 }
    end {
        
    }
}


function Install-VMwarevCenter_JSON{
<#
   .Synopsis
        Runs the VMware vCenter setup using JSON data file.
    .Description
        
    .Example
     Install-VMwarevCenter_JSON -ConfigFilePath "C:\data\data.json"
    
    .PARAMETER ConfigFilePath
    The path to the json data file containing the configuration.

    .NOTES
    Version: 1.1
    Date: 03/02/2014
    Tag: 
#>
[CmdletBinding()]
    Param
    (
    [parameter(Mandatory=$true,ValueFromPipeline=$true)][ValidateNotNullOrEmpty()][string]$ConfigFilePath
    )
    process {

    $InstallParameters = Get-ConfigFile -ConfigFilePath $ConfigFilePath
    
    if ((Test-NotNull -Value $InstallParameters.("vCenterBaseInstallPath")) -eq $false) { Write-host "The value vCenterBaseInstallPath can't be null. Script terminating. " -ForegroundColor Red; break} else {$vCenterBaseInstallPath = $InstallParameters.("vCenterBaseInstallPath")}
    if ((Test-NotNull -Value $InstallParameters.("vcenterIPAddress")) -eq $false) { Write-host "The value vcenterIPAddress can't be null. Script terminating. " -ForegroundColor Red; break} else {$vcenterIPAddress = $InstallParameters.("vcenterIPAddress")}
    if ((Test-NotNull -Value $InstallParameters.("SSO_ADMIN")) -eq $false) { Write-host "The value SSO_ADMIN can't be null. Script terminating. " -ForegroundColor Red; break} else {$SSO_ADMIN = $InstallParameters.("SSO_ADMIN")}
    if ((Test-NotNull -Value $InstallParameters.("SSO_PWD")) -eq $false) { Write-host "The value SSO_PWD can't be null. Script terminating. " -ForegroundColor Red; break} else {$SSO_PWD = $InstallParameters.("SSO_PWD")}
    if ((Test-NotNull -Value $InstallParameters.("SSO_HTTPport")) -eq $false) { Write-host "The value SSO_HTTPport can't be null. Script terminating. " -ForegroundColor Red; break} else {$SSO_HTTPport = $InstallParameters.("SSO_HTTPport")}
    if ((Test-NotNull -Value $InstallParameters.("VC_ADMIN_USER")) -eq $false) { Write-host "The value VC_ADMIN_USER can't be null. Script terminating. " -ForegroundColor Red; break} else {$VC_ADMIN_USER = $InstallParameters.("VC_ADMIN_USER")}
    if ((Test-NotNull -Value $InstallParameters.("vCenter_FORMAT_DB")) -eq $false) { Write-host "The value vCenter_FORMAT_DB can't be null. Script terminating. " -ForegroundColor Red; break} else {$vCenter_FORMAT_DB = $InstallParameters.("vCenter_FORMAT_DB")}
    if ((Test-NotNull -Value $InstallParameters.("vCenter_JVM_MEMORY_OPTION")) -eq $false) { Write-host "The value vCenter_JVM_MEMORY_OPTION can't be null. Script terminating. " -ForegroundColor Red; break} else {$vCenter_JVM_MEMORY_OPTION = $InstallParameters.("vCenter_JVM_MEMORY_OPTION")}
    if ((Test-NotNull -Value $InstallParameters.("DB_DSN")) -eq $false) { Write-host "The value DB_DSN can't be null. Script terminating. " -ForegroundColor Red; break} else {$DB_DSN = $InstallParameters.("DB_DSN")}
    if ((Test-NotNull -Value $InstallParameters.("VPX_ACCOUNT")) -eq $false) { Write-host "The value VPX_ACCOUNT can't be null. Script terminating. " -ForegroundColor Red; break} else {$VPX_ACCOUNT = $InstallParameters.("VPX_ACCOUNT")}
    if ((Test-NotNull -Value $InstallParameters.("VPX_PASSWORD")) -eq $false) { Write-host "The value VPX_PASSWORD can't be null. Script terminating. " -ForegroundColor Red; break} else {$VPX_PASSWORD = $InstallParameters.("VPX_PASSWORD")}
    if ((Test-NotNull -Value $InstallParameters.("vCenter_VCS_HTTPS_PORT")) -eq $false) { Write-host "The value vCenter_VCS_HTTPS_PORT can't be null. Script terminating. " -ForegroundColor Red; break} else {$vCenter_VCS_HTTPS_PORT = $InstallParameters.("vCenter_VCS_HTTPS_PORT")}
    if ((Test-NotNull -Value $InstallParameters.("vCenter_VCS_HTTP_PORT")) -eq $false) { Write-host "The value vCenter_VCS_HTTP_PORT can't be null. Script terminating. " -ForegroundColor Red; break} else {$vCenter_VCS_HTTP_PORT = $InstallParameters.("vCenter_VCS_HTTP_PORT")}
    if ((Test-NotNull -Value $InstallParameters.("vCenter_VCS_HEARTBEAT_PORT")) -eq $false) { Write-host "The value vCenter_VCS_HEARTBEAT_PORT can't be null. Script terminating. " -ForegroundColor Red; break} else {$vCenter_VCS_HEARTBEAT_PORT = $InstallParameters.("vCenter_VCS_HEARTBEAT_PORT")}
    if ((Test-NotNull -Value $InstallParameters.("vCenter_TC_HTTP_PORT")) -eq $false) { Write-host "The value vCenter_TC_HTTP_PORT can't be null. Script terminating. " -ForegroundColor Red; break} else {$vCenter_TC_HTTP_PORT = $InstallParameters.("vCenter_TC_HTTP_PORT")}
    if ((Test-NotNull -Value $InstallParameters.("vCenter_TC_HTTPS_PORT")) -eq $false) { Write-host "The value vCenter_TC_HTTPS_PORT can't be null. Script terminating. " -ForegroundColor Red; break} else {$vCenter_TC_HTTPS_PORT = $InstallParameters.("vCenter_TC_HTTPS_PORT")}
    if ((Test-NotNull -Value $InstallParameters.("vCenter_VCS_ADAM_LDAP_PORT")) -eq $false) { Write-host "The value vCenter_VCS_ADAM_LDAP_PORT can't be null. Script terminating. " -ForegroundColor Red; break} else {$vCenter_VCS_ADAM_LDAP_PORT = $InstallParameters.("vCenter_VCS_ADAM_LDAP_PORT")}
    if ((Test-NotNull -Value $InstallParameters.("vCenter_VCS_ADAM_SSL_PORT")) -eq $false) { Write-host "The value vCenter_VCS_ADAM_SSL_PORT can't be null. Script terminating. " -ForegroundColor Red; break} else {$vCenter_VCS_ADAM_SSL_PORT = $InstallParameters.("vCenter_VCS_ADAM_SSL_PORT")}

    Return Install-VMwarevCenter -vCenterBaseInstallPath $vCenterBaseInstallPath -vcenterIPAddress $vcenterIPAddress -SSO_ADMIN $SSO_ADMIN -SSO_PWD $SSO_PWD -SSO_HTTPport $SSO_HTTPport -VC_ADMIN_USER $VC_ADMIN_USER -vCenter_FORMAT_DB $vCenter_FORMAT_DB -vCenter_JVM_MEMORY_OPTION $vCenter_JVM_MEMORY_OPTION -DB_DSN $DB_DSN -VPX_ACCOUNT $VPX_ACCOUNT -VPX_PASSWORD $VPX_PASSWORD -vCenter_VCS_HTTPS_PORT $vCenter_VCS_HTTPS_PORT -vCenter_VCS_HTTP_PORT $vCenter_VCS_HTTP_PORT -vCenter_VCS_HEARTBEAT_PORT $vCenter_VCS_HEARTBEAT_PORT -vCenter_TC_HTTP_PORT $vCenter_TC_HTTP_PORT -vCenter_TC_HTTPS_PORT $vCenter_TC_HTTPS_PORT -vCenter_VCS_ADAM_LDAP_PORT $vCenter_VCS_ADAM_LDAP_PORT -vCenter_VCS_ADAM_SSL_PORT $vCenter_VCS_ADAM_SSL_PORT

 }
    end {
        
    }
}


function Install-VMwarevCenter{
<#
   .Synopsis
        Runs the VMware vCenter setup.
    .Description
        
    .Example
    Install-VMwarevCenter
    
    .PARAMETER vCenterBaseInstallPath
    The base location of the VMware vCenter installation.

    .PARAMETER vcenterIPAddress
    The address for the vCenter.

    .PARAMETER SSO_ADMIN
    User name for the vCenter Single Sign‐On administrator user account.

    .PARAMETER SSO_PWD
    Password for the vCenter Single Sign‐On administrator user account

    .PARAMETER SSO_HTTPport
    vCenter Single Sign‐On HTTPS port number

    .PARAMETER VC_ADMIN_USER
    The user who will log in to vCenter Server.

    .PARAMETER vCenter_FORMAT_DB
    Creates a fresh database schema. All existing data is lost if the database already exists. 
    CAUTION   Using FORMAT_DB=1 results in loss of data. Do not use it if you want to preserve the existing data and the database schema.

    .PARAMETER vCenter_JVM_MEMORY_OPTION
    Choices refer to vCenter Server inventory size. 
    S - Small inventory (1‐100 hosts or 1‐1000 virtual machines)
    M - Medium inventory (100‐400 hosts or 1000‐4000 virtual machines)
    L - Large inventory (more than 400 hosts or 4000 virtual machines)
    This parameter determines the maximum JVM heap settings for VMware VirtualCenter Management Webservices (Tomcat). 

    .PARAMETER DB_DSN
    Customizes the DSN

    .PARAMETER VPX_ACCOUNT
    User account to run VMware vCenter Server service. UNCname can either be the domain name or local host name. The administrator user must have Logon as a Service right.

    .PARAMETER VPX_PASSWORD
    User account password.

    .PARAMETER vCenter_VCS_HTTP_PORT
    vCenter Server HTTP port.
    
    .PARAMETER vCenter_VCS_HTTPS_PORT
    vCenter Server HTTPS port.

    .PARAMETER vCenter_VCS_HEARTBEAT_PORT
    vCenter Server Heartbeat port.

    .PARAMETER vCenter_TC_HTTP_PORT
    VMware vCenter Web services HTTP port.

    .PARAMETER vCenter_TC_HTTPS_PORT
    VMware vCenter Web services HTTPS port.

    .PARAMETER vCenter_VCS_ADAM_LDAP_PORT
    LDAP port of Directory Services where VMware VCMSDS listens. VCS_ADAM_LDAP_PORT must either use the default port number or reside in the range 1025 <= PORT <= 65535

    .PARAMETER vCenter_VCS_ADAM_SSL_PORT
    SSL port of Directory Services where VMware VCMSDS listens. VCS_ADAM_SSL_PORT must either use the default port number or reside in the range 1025 <= PORT <= 65535

    .NOTES
    Version: 1.1
    Date: 03/02/2014
    Tag: 
#>
[CmdletBinding()]

    Param
    (
    [parameter(Mandatory=$true,ValueFromPipeline=$true)][ValidateNotNullOrEmpty()][string]$vCenterBaseInstallPath,
    [parameter(Mandatory=$true,ValueFromPipeline=$true)][ValidateNotNullOrEmpty()][string]$vcenterIPAddress,
    [parameter(Mandatory=$true,ValueFromPipeline=$true)][ValidateNotNullOrEmpty()][string]$SSO_ADMIN,
    [parameter(Mandatory=$true,ValueFromPipeline=$true)][ValidateNotNullOrEmpty()][string]$SSO_PWD,
    [parameter(Mandatory=$true,ValueFromPipeline=$true)][ValidateNotNullOrEmpty()][string]$SSO_HTTPport,
    [parameter(Mandatory=$true,ValueFromPipeline=$true)][ValidateNotNullOrEmpty()][string]$VC_ADMIN_USER,
    [parameter(Mandatory=$true,ValueFromPipeline=$true)][ValidateNotNullOrEmpty()][string]$vCenter_FORMAT_DB,
    [parameter(Mandatory=$false,ValueFromPipeline=$true)][ValidateNotNullOrEmpty()][string]$vCenter_JVM_MEMORY_OPTION = "S",
    [parameter(Mandatory=$true,ValueFromPipeline=$true)][ValidateNotNullOrEmpty()][string]$DB_DSN,
    [parameter(Mandatory=$true,ValueFromPipeline=$true)][ValidateNotNullOrEmpty()][string]$VPX_ACCOUNT,
    [parameter(Mandatory=$true,ValueFromPipeline=$true)][ValidateNotNullOrEmpty()][string]$VPX_PASSWORD,
    [parameter(Mandatory=$false,ValueFromPipeline=$true)][ValidateNotNullOrEmpty()][string]$vCenter_VCS_HTTP_PORT = "80",
    [parameter(Mandatory=$false,ValueFromPipeline=$true)][ValidateNotNullOrEmpty()][string]$vCenter_VCS_HTTPS_PORT = "443",
    [parameter(Mandatory=$false,ValueFromPipeline=$true)][ValidateNotNullOrEmpty()][string]$vCenter_VCS_HEARTBEAT_PORT = "902",
    [parameter(Mandatory=$false,ValueFromPipeline=$true)][ValidateNotNullOrEmpty()][string]$vCenter_TC_HTTP_PORT = "8080",
    [parameter(Mandatory=$false,ValueFromPipeline=$true)][ValidateNotNullOrEmpty()][string]$vCenter_TC_HTTPS_PORT = "8443",
    [parameter(Mandatory=$false,ValueFromPipeline=$true)][ValidateNotNullOrEmpty()][string]$vCenter_VCS_ADAM_LDAP_PORT = "389",
    [parameter(Mandatory=$false,ValueFromPipeline=$true)][ValidateNotNullOrEmpty()][string]$vCenter_VCS_ADAM_SSL_PORT = "902"
    )    

    
    process {

    #==================================#
    # Install VMware vCenter  		   #
    #==================================#
	$Package = "vCenter Server"
	Write-Host ("Installing " + $Package) -ForegroundColor Green
	                
    $setupexe = ($vCenterBaseInstallPath+"vCenter-Server\VMware-vcserver.exe")
	
	$argslist = '/w /L1033 /v" /qr '
	$argslist += ' SSO_ADMIN_USER=\"' + $SSO_ADMIN + '\" SSO_ADMIN_PASSWORD=\"' + $SSO_PWD + '\"'
	$argslist += ' LS_URL=\"https://' + $vcenterIPAddress + ':'+$SSO_HTTPport+'/lookupservice/sdk\" IS_URL=\"https://' + $vcenterIPAddress + ':10443\"'
	$argslist += ' VC_ADMIN_USER=\"' + $VC_ADMIN_USER + '\"'
	$argslist += ' DB_SERVER_TYPE=Custom DB_DSN=\"' + $DB_DSN + '\"  DB_DSN_WINDOWS_AUTH=1'
	$argslist += ' FORMAT_DB=' + $vCenter_FORMAT_DB
	$argslist += ' JVM_MEMORY_OPTION='+$vCenter_JVM_MEMORY_OPTION
	$argslist += ' VPX_USES_SYSTEM_ACCOUNT=\"\"'
	$argslist += ' VPX_ACCOUNT=\"' + $VPX_ACCOUNT + '\"'
	$argslist += ' VPX_PASSWORD=\"' + $VPX_PASSWORD + '\"'
	$argslist += ' VPX_PASSWORD_VERIFY=\"' + $VPX_PASSWORD + '\"'
	$argslist += ' VCS_GROUP_TYPE=Single'
	$argslist += ' VCS_HTTPS_PORT='+ $vCenter_VCS_HTTPS_PORT
	$argslist += ' VCS_HTTP_PORT=' + $vCenter_VCS_HTTP_PORT
	$argslist += ' VCS_HEARTBEAT_PORT=' + $vCenter_VCS_HEARTBEAT_PORT
	$argslist += ' TC_HTTP_PORT=' + $vCenter_TC_HTTP_PORT
	$argslist += ' TC_HTTPS_PORT=' + $vCenter_TC_HTTPS_PORT
	$argslist += ' VCS_ADAM_LDAP_PORT='+ $vCenter_VCS_ADAM_LDAP_PORT 
	$argslist += ' VCS_ADAM_SSL_PORT=' + $vCenter_VCS_ADAM_SSL_PORT
	$argslist += ' /L*v \"'+$ENV:TEMP+'"\vmvcsvr.log\""'

	Return Execute-Installer -FilePath $setupexe -argslist $argslist -Package $Package
 }
    end {
        
    }
}


function Install-VMwarevSphereClient_JSON{
<#
   .Synopsis
        Runs the VMware vSphere Client setup with JSON input. 
    .Description
        
    .Example
     Install-VMwarevSphereClient_JSON -ConfigFilePath "C:\data\data.json"
    
    .PARAMETER ConfigFilePath
    The path to the json data file containing the configuration.

    .NOTES
    Version: 1.1
    Date: 03/02/2014
    Tag: 
#>
[CmdletBinding()]
    Param
    (
    [parameter(Mandatory=$true,ValueFromPipeline=$true)][ValidateNotNullOrEmpty()][string]$ConfigFilePath
    )
    process {

    $InstallParameters = Get-ConfigFile -ConfigFilePath $ConfigFilePath
    
    if ((Test-NotNull -Value $InstallParameters.("vCenterBaseInstallPath")) -eq $false) { Write-host "The value vCenterBaseInstallPath can't be null. Script terminating. " -ForegroundColor Red; break} else {$vCenterBaseInstallPath = $InstallParameters.("vCenterBaseInstallPath")}
    
    Return Install-VMwarevSphereClient -vCenterBaseInstallPath $vCenterBaseInstallPath
 }
    end {
        
    }
}


function Install-VMwarevSphereClient{
<#
   .Synopsis
        Runs the VMware vSphere Client setup.
    .Description
        
    .Example
     Install-VMwarevSphereClient  -vCenterBaseInstallPath "C:\Software\VMware\vCenter 5.5a\"
    
    .PARAMETER vCenterBaseInstallPath
    The base location of the VMware vCenter installation.

    .NOTES
    Version: 1.1
    Date: 03/02/2014
    Tag: 
#>
[CmdletBinding()]

    Param
    (

    [parameter(Mandatory=$true,ValueFromPipeline=$true)][ValidateNotNullOrEmpty()][string]$vCenterBaseInstallPath
    )    

    
    process {

    #===================================#
    # Install VMware vSphere Client		#
    #===================================# 
	$Package = "VMware vSphere Client"
	
	Write-Host ("Installing " + $Package) -ForegroundColor Green
	
	$setupexe = ($vCenterBaseInstallPath+"vSphere-Client\VMware-viclient.exe")

	$argslist = '/w /L1033 /v" /qr /L*v \"'+$ENV:TEMP+'"\vim-vic-msi.log\""'
	
	Return Execute-Installer -FilePath $setupexe -argslist $argslist -Package $Package
 }
    end {
        
    }
}


function Install-VMwarevSphereWebClient_JSON{
<#
   .Synopsis
        Runs the VMware vSphere Web Client setup with JSON input. 
    .Description
        
    .Example
     Install-VMwarevSphereWebClient_JSON -ConfigFilePath "C:\data\data.json"
    
    .PARAMETER ConfigFilePath
    The path to the json data file containing the configuration.

    .NOTES
    Version: 1.1.1
    Date: 07/02/2014
    Tag: 
#>
[CmdletBinding()]
    Param
    (
    [parameter(Mandatory=$true,ValueFromPipeline=$true)][ValidateNotNullOrEmpty()][string]$ConfigFilePath
    )
    process {

    $InstallParameters = Get-ConfigFile -ConfigFilePath $ConfigFilePath
    
    if ((Test-NotNull -Value $InstallParameters.("vCenterBaseInstallPath")) -eq $false) { Write-host "The value vCenterBaseInstallPath can't be null. Script terminating. " -ForegroundColor Red; break} else {$vCenterBaseInstallPath = $InstallParameters.("vCenterBaseInstallPath")}
    if ((Test-NotNull -Value $InstallParameters.("vcenterIPAddress")) -eq $false) { Write-host "The value vcenterIPAddress can't be null. Script terminating. " -ForegroundColor Red; break} else {$vcenterIPAddress = $InstallParameters.("vcenterIPAddress")}
    if ((Test-NotNull -Value $InstallParameters.("SSO_ADMIN")) -eq $false) { Write-host "The value SSO_ADMIN can't be null. Script terminating. " -ForegroundColor Red; break} else {$SSO_ADMIN = $InstallParameters.("SSO_ADMIN")}
    if ((Test-NotNull -Value $InstallParameters.("SSO_PWD")) -eq $false) { Write-host "The value SSO_PWD can't be null. Script terminating. " -ForegroundColor Red; break} else {$SSO_PWD = $InstallParameters.("SSO_PWD")}
    if ((Test-NotNull -Value $InstallParameters.("SSO_HTTPport")) -eq $false) { Write-host "The value SSO_HTTPport can't be null. Script terminating. " -ForegroundColor Red; break} else {$SSO_HTTPport = $InstallParameters.("SSO_HTTPport")}
    if ((Test-NotNull -Value $InstallParameters.("vCenterWebClient_HTTP_PORT")) -eq $false) { Write-host "The value vCenterWebClient_HTTP_PORT can't be null. Script terminating. " -ForegroundColor Red; break} else {$vCenterWebClient_HTTP_PORT = $InstallParameters.("vCenterWebClient_HTTP_PORT")}
    if ((Test-NotNull -Value $InstallParameters.("vCenterWebClient_HTTPS_PORT")) -eq $false) { Write-host "The value vCenterWebClient_HTTPS_PORT can't be null. Script terminating. " -ForegroundColor Red; break} else {$vCenterWebClient_HTTPS_PORT = $InstallParameters.("vCenterWebClient_HTTPS_PORT")}
    
    Return Install-VMwarevSphereWebClient -vCenterBaseInstallPath $vCenterBaseInstallPath -vcenterIPAddress $vcenterIPAddress -SSO_ADMIN $SSO_ADMIN -SSO_PWD $SSO_PWD -SSO_HTTPport $SSO_HTTPport -vCenterWebClient_HTTP_PORT $vCenterWebClient_HTTP_PORT -vCenterWebClient_HTTPS_PORT $vCenterWebClient_HTTPS_PORT
 }
    end {
        
    }
}


function Install-VMwarevSphereWebClient{
<#
   .Synopsis
        Runs the VMware vSphere Client setup.
    .Description
        
    .Example
     Install-VMwarevSphereWebClient -vCenterBaseInstallPath "C:\Software\VMware\vCenter 5.5a\"
    
    .PARAMETER vCenterBaseInstallPath
    The base location of the VMware vCenter installation. 

    .NOTES
    Version: 1.1.1
    Date: 07/02/2014
    Tag: 
#>
[CmdletBinding()]

    Param
    (
    [parameter(Mandatory=$true,ValueFromPipeline=$true)][ValidateNotNullOrEmpty()][string]$vCenterBaseInstallPath,
    [parameter(Mandatory=$true,ValueFromPipeline=$true)][ValidateNotNullOrEmpty()][string]$vcenterIPAddress,
    [parameter(Mandatory=$true,ValueFromPipeline=$true)][ValidateNotNullOrEmpty()][string]$SSO_ADMIN,
    [parameter(Mandatory=$true,ValueFromPipeline=$true)][ValidateNotNullOrEmpty()][string]$SSO_PWD,
    [parameter(Mandatory=$true,ValueFromPipeline=$true)][ValidateNotNullOrEmpty()][string]$SSO_HTTPport,
    [parameter(Mandatory=$false,ValueFromPipeline=$true)][ValidateNotNullOrEmpty()][string]$vCenterWebClient_HTTP_PORT = "9090",
    [parameter(Mandatory=$false,ValueFromPipeline=$true)][ValidateNotNullOrEmpty()][string]$vCenterWebClient_HTTPS_PORT = "9443"
    )    
    process {

    #===================================#
    # Install VMware vSphere Web Client	#
    #===================================# 
	$Package = "VMware vSphere Web Client"
	
	Write-Host ("Installing " + $Package) -ForegroundColor Green

    $setupexe = ($vCenterBaseInstallPath+"vSphere-WebClient\VMware-WebClient.exe")

	$argslist = '/L1033 /v" /qr'
	$argslist += ' HTTP_PORT=' + $vCenterWebClient_HTTP_PORT + ' HTTPS_PORT=' + $vCenterWebClient_HTTPS_PORT 
	$argslist += ' SSO_ADMIN_USER=\"' + $SSO_ADMIN + '\" SSO_ADMIN_PASSWORD=\"' + $SSO_PWD + '\"'
	$argslist += ' LS_URL=\"https://' + $vcenterIPAddress + ':'+$SSO_HTTPport+'/lookupservice/sdk\"'
	$argslist += ' /L*v \"'+$ENV:TEMP+'"\vim-ngc-msi.log\""'

	Return Execute-Installer -FilePath $setupexe -argslist $argslist -Package $Package
 }
    end {
        
    }
}

function Set-ServiceLogonRight_JSON{
<#
   .Synopsis
        Set Logon As A Service right to User with JSON input. 
    .Description
        
    .Example
     Set-ServiceLogonRight_JSON -ConfigFilePath "C:\data\data.json"
    
    .PARAMETER ConfigFilePath
    The path to the json data file containing the configuration.

    .NOTES
    Version: 1.1
    Date: 03/02/2014
    Tag: 
#>
[CmdletBinding()]
    Param
    (
    [parameter(Mandatory=$true,ValueFromPipeline=$true)][ValidateNotNullOrEmpty()][string]$ConfigFilePath
    )
    process {

    $InstallParameters = Get-ConfigFile -ConfigFilePath $ConfigFilePath
    
    if ((Test-NotNull -Value $InstallParameters.("ServiceLogonRightAccount")) -eq $false) { Write-host "The value ServiceLogonRightAccount can't be null. Script terminating. " -ForegroundColor Red; break} else {$ServiceLogonRightAccount = $InstallParameters.("ServiceLogonRightAccount")}
    
    Set-ServiceLogonRight -ServiceLogonRightAccount $ServiceLogonRightAccount
 }
    end {
        
    }
}


function Set-ServiceLogonRight{
<#
   .Synopsis
        Set Logon As A Service right to User.
    .Description
        
    .Example
     Set-ServiceLogonRight -ServiceLogonRightAccount "domain\account"
    
    .PARAMETER ServiceLogonRightAccount
    The AD account to set as having Logon as service rights

    .NOTES
    Version: 1.0
    Date: 06/02/2014
    Tag: 
#>
[CmdletBinding()]

    Param
    (
    [parameter(Mandatory=$true,ValueFromPipeline=$true)][ValidateNotNullOrEmpty()][string]$ServiceLogonRightAccount
    )    
    process {

    $privilege = "SeServiceLogonRight"
    $CarbonDllPath = ((Split-Path $script:MyInvocation.MyCommand.Path).ToString()+"\Carbon\Carbon.dll")
 
    [Reflection.Assembly]::LoadFile($CarbonDllPath)
 
    [Carbon.Lsa]::GrantPrivileges($ServiceLogonRightAccount,$privilege)

 }
    end {
        
    }
}


Export-ModuleMember -Function Install-vCenter, Install-MSVC2005_JSON, Install-MSVC2005, Install-VMwareSSO_JSON, Install-VMwareSSO, Install-VMwareInventoryService_JSON, Install-VMwareInventoryService, Install-VMwarevCenter_JSON, Install-VMwarevCenter, Install-VMwarevSphereClient_JSON, Install-VMwarevSphereClient, Install-VMwarevSphereWebClient_JSON, Install-VMwarevSphereWebClient, Set-ServiceLogonRight, Set-ServiceLogonRight_JSON
