## =====================================================================
## Title       : VMware vCenter 5.5 Installation
## Description : This will install the selected components of VMware vCenter 5.5
## Author      : David Balharrie
## Date        : 08/01/2014
## Notes       : More information about this scipt can be found at
##               http://creativeview.co.uk
## Version     : 1.0
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
	Write-Host "Exit Code: "  $ExitCode
	if($ExitCode -eq 0)
	{
		Write-Host ("Successfully installed " + $Package) -ForegroundColor Green
	}
	else
	{
		Write-Host ("There has been an error installing " + $Package + ". The error code was: " + $ExitCode) -ForegroundColor Red
	}
}


function Install-vCenter{
<#
   .Synopsis
        Runs the vCenter setup and it's components.
    .Description
        
    .Example
     Install-vCenter -ConfigFilePath "C:\scripts\vcenter_config.json"
    
    .PARAMETER ConfigFilePath
    Path to the JSON file with the setup configuration.

    .NOTES
    Version: 1.0
    Date: 06/01/2014
    Tag: 
#>
[CmdletBinding()]

    Param
    (

    [parameter(Mandatory=$true,ValueFromPipeline=$true)]
    [ValidateNotNullOrEmpty()]
    [PSObject[]]$ConfigFilePath
    )    


    
    process {
    
            
            Write-host ("Passed Config Path: " + $ConfigFilePath)

            # check Config File exists
            if(Test-Path($ConfigFilePath))
            {
        
                [System.Reflection.Assembly]::LoadWithPartialName("System.Web.Extensions")
                $content = [IO.File]::ReadAllText($ConfigFilePath)
                $json = $content
                $ser = New-Object System.Web.Script.Serialization.JavaScriptSerializer
                $JSONobj = $ser.DeserializeObject($json)

                $InstallFlags = @{}
                $InstallParameters = @{}


                foreach ($node in $JSONobj.InstallFlags.Keys)
                {
                    $InstallFlags.Add($node,$JSONobj.InstallFlags.Item($node))
                }

                foreach ($node in $JSONobj.InstallParameters.Keys)
                {
                    $InstallParameters.Add($node,$JSONobj.InstallParameters.Item($node))
                }

                if ((Test-NotNull -Value $InstallParameters.("vCenterBaseInstallPath")) -eq $false) { Write-host "The value vCenterBaseInstallPath can't be null. Script terminating. " -ForegroundColor Red; break} else {$vCenterBaseInstallPath = $InstallParameters.("vCenterBaseInstallPath")}


                #===================================================#
                # Install Microsoft Visual C++ 2005 Redistributable #
                #===================================================# 
                if($InstallFlags.("Install_msvc_2005") -eq $true)
                {
	                $Package = "Microsoft Visual C++ 2005 Redistributable"
	
	                Write-Host ("Installing " + $Package) -ForegroundColor Green
	
	                $setupexe = ($vCenterBaseInstallPath+"redist\vcredist\2005\vcredist_x86.exe")

	                $argslist = ' /q:a'
	
	                Execute-Installer -FilePath $setupexe -argslist $argslist -Package $Package
                }
                

                #====================#
                # VMware vCenter SSO #
                #====================#
                if($InstallFlags.("Install_SSO") -eq $true)
                {
	                $Package = "VMware vCenter SSO"
	
	                Write-Host ("Installing " + $Package) -ForegroundColor Green
                    
                    #==========#
                    # Settings #
                    #==========#
                    #if ((Test-NotNull -Value $InstallParameters.("vCenterBaseInstallPath")) -eq $false) { Write-host "The value vCenterBaseInstallPath can't be null. Script terminating. " -ForegroundColor Red; break} else {$vCenterBaseInstallPath = $InstallParameters.("vCenterBaseInstallPath")}
                    if ((Test-NotNull -Value $InstallParameters.("SSO_PWD")) -eq $false) { Write-host "The value SSO_PWD can't be null. Script terminating. " -ForegroundColor Red; break} else {$SSO_PWD = $InstallParameters.("SSO_PWD")}
                    if ((Test-NotNull -Value $InstallParameters.("SSO_DeployMode")) -eq $false) { Write-host "The value SSO_DeployMode can't be null. Script terminating. " -ForegroundColor Red; break} else {$SSO_DeployMode = $InstallParameters.("SSO_DeployMode")}
                    if ((Test-NotNull -Value $InstallParameters.("SSO_Site")) -eq $false) { Write-host "The value SSO_Site can't be null. Script terminating. " -ForegroundColor Red; break} else {$SSO_Site = $InstallParameters.("SSO_Site")}                    
                    if ((Test-NotNull -Value $InstallParameters.("SSO_HTTPport")) -eq $false) { Write-host "The value SSO_HTTPport can't be null. Script terminating. " -ForegroundColor Red; break} else {$SSO_HTTPport = $InstallParameters.("SSO_HTTPport")}
    
	                $sso_msi = ($vCenterBaseInstallPath+"Single Sign-On\VMware-SSO-Server.msi")
	
	                $argslist = '/I "'+$sso_msi+'"'
	                $argslist += ' /qr SSO_HTTPS_PORT='+$SSO_HTTPport+' DEPLOYMODE='+$SSO_DeployMode+' ADMINPASSWORD='+$SSO_PWD+' SSO_SITE='+$SSO_Site
	                $argslist += ' TOMCAT_MAX_MEMORY_OPTION='+$SSO_TomcatMaxMem+'\" /l*v '+$ENV:TEMP+'\vim-sso-msi.log'

	                Execute-Installer -FilePath "msiexec" -argslist $argslist -Package $Package
                }

                #==========================================#
                # Install VMware vCenter Inventory Service #
                #==========================================#

                if($InstallFlags.("Install_InventoryService") -eq $true)
                {
	                $Package = "VMware vCenter Inventory Service"
	
	                Write-Host ("Installing " + $Package) -ForegroundColor Green


                    #==========#
                    # Settings #
                    #==========#
                    if ((Test-NotNull -Value $InstallParameters.("vcenterIPAddress")) -eq $false) { Write-host "The value vcenterIPAddress can't be null. Script terminating. " -ForegroundColor Red; break} else {$vcenterIPAddress = $InstallParameters.("vcenterIPAddress")}
                    if ((Test-NotNull -Value $InstallParameters.("SSO_ADMIN")) -eq $false) { Write-host "The value SSO_ADMIN can't be null. Script terminating. " -ForegroundColor Red; break} else {$SSO_ADMIN = $InstallParameters.("SSO_ADMIN")}
                    if ((Test-NotNull -Value $InstallParameters.("SSO_PWD")) -eq $false) { Write-host "The value SSO_PWD can't be null. Script terminating. " -ForegroundColor Red; break} else {$SSO_PWD = $InstallParameters.("SSO_PWD")}
                    if ((Test-NotNull -Value $InstallParameters.("SSO_HTTPport")) -eq $false) { Write-host "The value SSO_HTTPport can't be null. Script terminating. " -ForegroundColor Red; break} else {$SSO_HTTPport = $InstallParameters.("SSO_HTTPport")}
                    if ((Test-NotNull -Value $InstallParameters.("InventoryService_HTTPS_PORT")) -eq $false) { Write-host "The value InventoryService_HTTPS_PORT can't be null. Script terminating. " -ForegroundColor Red; break} else {$InventoryService_HTTPS_PORT = $InstallParameters.("InventoryService_HTTPS_PORT")}
                    if ((Test-NotNull -Value $InstallParameters.("InventoryService_XDB_PORT")) -eq $false) { Write-host "The value InventoryService_XDB_PORT can't be null. Script terminating. " -ForegroundColor Red; break} else {$InventoryService_XDB_PORT = $InstallParameters.("InventoryService_XDB_PORT")}
                    if ((Test-NotNull -Value $InstallParameters.("InventoryService_FEDERATION_PORT")) -eq $false) { Write-host "The value InventoryService_FEDERATION_PORT can't be null. Script terminating. " -ForegroundColor Red; break} else {$InventoryService_FEDERATION_PORT = $InstallParameters.("InventoryService_FEDERATION_PORT")}
                    if ((Test-NotNull -Value $InstallParameters.("InventoryService_QUERY_SERVICE_NUKE_DATABASE")) -eq $false) { Write-host "The value InventoryService_QUERY_SERVICE_NUKE_DATABASE can't be null. Script terminating. " -ForegroundColor Red; break} else {$InventoryService_QUERY_SERVICE_NUKE_DATABASE = $InstallParameters.("InventoryService_QUERY_SERVICE_NUKE_DATABASE")}
                    if ((Test-NotNull -Value $InstallParameters.("InventoryService_TOMCAT_MAX_MEMORY_OPTION")) -eq $false) { Write-host "The value InventoryService_TOMCAT_MAX_MEMORY_OPTION can't be null. Script terminating. " -ForegroundColor Red; break} else {$InventoryService_TOMCAT_MAX_MEMORY_OPTION = $InstallParameters.("InventoryService_TOMCAT_MAX_MEMORY_OPTION")}
                    
	                $setupexe = ($vCenterBaseInstallPath+"Inventory Service\VMware-inventory-service.exe")

	                $argslist = '/S /L1033 /v"/qr QUERY_SERVICE_NUKE_DATABASE=' + $InventoryService_QUERY_SERVICE_NUKE_DATABASE + ' SSO_ADMIN_USER=\"' + $SSO_ADMIN + '\" SSO_ADMIN_PASSWORD=\"' + $SSO_PWD + '\"'
	                $argslist += ' LS_URL=\"https://' + $vcenterIPAddress + ':'+$SSO_HTTPport+'/lookupservice/sdk\" HTTPS_PORT=' + $InventoryService_HTTPS_PORT 
                    $argslist += ' FEDERATION_PORT=' + $InventoryService_FEDERATION_PORT + ' XDB_PORT=' + $InventoryService_XDB_PORT + ''
	                $argslist += ' TOMCAT_MAX_MEMORY_OPTION=' + $InventoryService_TOMCAT_MAX_MEMORY_OPTION + ' /L*v \"'+$ENV:TEMP+'"\vim-qs-msi.log"\""'

	                Execute-Installer -FilePath $setupexe -argslist $argslist -Package $Package
                }

                #==================================#
                # Install VMware vCenter  		   #
                #==================================# 
 
                if($InstallFlags.("Install_vCenter") -eq $true)
                {
	                $Package = "vCenter Server"
	                Write-Host ("Installing " + $Package) -ForegroundColor Green

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

	                Execute-Installer -FilePath $setupexe -argslist $argslist -Package $Package
                }
 
                #===================================#
                # Install VMware vSphere Client		#
                #===================================# 
                if($InstallFlags.("Install_vSphereClient") -eq $true)
                {
	                $Package = "VMware vSphere Client"
	
	                Write-Host ("Installing " + $Package) -ForegroundColor Green
	
	                $setupexe = ($vCenterBaseInstallPath+"vSphere-Client\VMware-viclient.exe")

	                $argslist = '/w /L1033 /v" /qr /L*v \"'+$ENV:TEMP+'"\vim-vic-msi.log\""'
	
	                Execute-Installer -FilePath $setupexe -argslist $argslist -Package $Package
                }

                #===================================#
                # Install VMware vSphere Web Client	#
                #===================================# 
                if($InstallFlags.("Install_WebClient") -eq $true)
                {
	                $Package = "VMware vSphere Web Client"
	
	                Write-Host ("Installing " + $Package) -ForegroundColor Green
	                
                    if ((Test-NotNull -Value $InstallParameters.("vcenterIPAddress")) -eq $false) { Write-host "The value vcenterIPAddress can't be null. Script terminating. " -ForegroundColor Red; break} else {$vcenterIPAddress = $InstallParameters.("vcenterIPAddress")}
                    if ((Test-NotNull -Value $InstallParameters.("SSO_ADMIN")) -eq $false) { Write-host "The value SSO_ADMIN can't be null. Script terminating. " -ForegroundColor Red; break} else {$SSO_ADMIN = $InstallParameters.("SSO_ADMIN")}
                    if ((Test-NotNull -Value $InstallParameters.("SSO_PWD")) -eq $false) { Write-host "The value SSO_PWD can't be null. Script terminating. " -ForegroundColor Red; break} else {$SSO_PWD = $InstallParameters.("SSO_PWD")}
                    if ((Test-NotNull -Value $InstallParameters.("SSO_HTTPport")) -eq $false) { Write-host "The value SSO_HTTPport can't be null. Script terminating. " -ForegroundColor Red; break} else {$SSO_HTTPport = $InstallParameters.("SSO_HTTPport")}

                    $setupexe = ($vCenterBaseInstallPath+"vSphere-WebClient\VMware-WebClient.exe")

	                $argslist = '/L1033 /v" /qr'
	                $argslist += ' HTTP_PORT=9090 HTTPS_PORT=9443'
	                $argslist += ' SSO_ADMIN_USER=\"' + $SSO_ADMIN + '\" SSO_ADMIN_PASSWORD=\"' + $SSO_PWD + '\"'
	                $argslist += ' LS_URL=\"https://' + $vcenterIPAddress + ':'+$SSO_HTTPport+'/lookupservice/sdk\"'
	                $argslist += ' /L*v \"'+$ENV:TEMP+'"\vim-ngc-msi.log\""'

	                Execute-Installer -FilePath $setupexe -argslist $argslist -Package $Package
                }


            }

    
    }
    end {
        
    }
}


Export-ModuleMember -Function Install-vCenter
