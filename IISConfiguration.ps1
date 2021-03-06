
#iisinstalationonserverPSV2
write-host "In IISConfiguration"
$jsonData = (Get-Content "config.json" -Raw)
$JsonObject = Microsoft.PowerShell.Utility\ConvertFrom-Json -InputObject $JsonData
$cd = $JsonObject.currentDirectory.path
$logfile = $cd+"\Installationlog.log"

function LogWrite {
    param ([String]$logString)
    $time = Get-Date
    $string = '*** ' +$time.ToString() +' == '+ $logString
    Add-Content $logfile -Value $string
}
LogWrite "In IISConfiguration"
LogWrite "Starting the configuration..."

Set-ExecutionPolicy -Scope Process -ExecutionPolicy Bypass
Dism /online /Enable-Feature /FeatureName:IIS-WebServerRole                          
Dism /online /Enable-Feature /FeatureName:IIS-WebServer
Dism /online /Enable-Feature /FeatureName:IIS-CommonHttpFeatures
Dism /online /Enable-Feature /FeatureName:IIS-HttpErrors
Dism /online /Enable-Feature /FeatureName:IIS-ApplicationDevelopment
#Dism /online /Enable-Feature /FeatureName:IIS-NetFxExtensibility45
Dism /online /Enable-Feature /FeatureName:IIS-HealthAndDiagnostics
Dism /online /Enable-Feature /FeatureName:IIS-HttpLogging
Dism /online /Enable-Feature /FeatureName:IIS-Security
Dism /online /Enable-Feature /FeatureName:IIS-RequestFiltering
Dism /online /Enable-Feature /FeatureName:IIS-Performance
Dism /online /Enable-Feature /FeatureName:IIS-WebServerManagementTools
Dism /online /Enable-Feature /FeatureName:IIS-StaticContent
Dism /online /Enable-Feature /FeatureName:IIS-DefaultDocument
Dism /online /Enable-Feature /FeatureName:IIS-DirectoryBrowsing
Dism /online /Enable-Feature /FeatureName:IIS-WebSockets
Dism /online /Enable-Feature /FeatureName:IIS-ApplicationInit
Dism /online /Enable-Feature /FeatureName:IIS-ISAPIExtensions
Dism /online /Enable-Feature /FeatureName:IIS-ISAPIFilter
#Dism /online /Enable-Feature /FeatureName:IIS-ServerSideIncludes
Dism /online /Enable-Feature /FeatureName:IIS-CustomLogging
#Dism /online /Enable-Feature /FeatureName:IIS-BasicAuthentication
Dism /online /Enable-Feature /FeatureName:IIS-HttpCompressionStatic
Dism /online /Enable-Feature /FeatureName:IIS-ManagementConsole
Dism /online /Enable-Feature /FeatureName:IIS-ODBCLogging
Dism /online /Enable-Feature /FeatureName:IIS-HttpRedirect
#Dism /online /Enable-Feature /FeatureName:IIS-URLAuthorization
Dism /online /Enable-Feature /FeatureName:IIS-LoggingLibraries
Dism /online /Enable-Feature /FeatureName:IIS-HttpTracing
Dism /online /Enable-Feature /FeatureName:IIS-IPSecurity
Dism /online /Enable-Feature /FeatureName:IIS-HttpCompressionDynamic
Dism /online /Enable-Feature /FeatureName:IIS-ManagementScriptingTools
Dism /online /Enable-Feature /FeatureName:IIS-IIS6ManagementCompatibility
Dism /online /Enable-Feature /FeatureName:IIS-Metabase
#Dism /online /Enable-Feature /FeatureName:IIS-HostableWebCore
#Dism /online /Enable-Feature /FeatureName:IIS-WebDav
#Dism /online /Enable-Feature /FeatureName:IIS-ASP
Dism /online /Enable-Feature /FeatureName:IIS-CGI
Dism /online /Enable-Feature /FeatureName:IIS-ManagementService
Dism /online /Enable-Feature /FeatureName:IIS-WMICompatibility
Dism /online /Enable-Feature /FeatureName:IIS-LegacyScripts
Dism /online /Enable-Feature /FeatureName:IIS-LegacySnapIn
Dism /online /Enable-Feature /FeatureName:IIS-FTPServer
Dism /online /Enable-Feature /FeatureName:IIS-FTPSvc
Dism /online /Enable-Feature /FeatureName:IIS-FTPExtensibility
#Dism /online /Enable-Feature /FeatureName:IIS-WindowsAuthentication
#Dism /online /Enable-Feature /FeatureName:IIS-DigestAuthentication
Dism /online /Enable-Feature /FeatureName:IIS-ClientCertificateMappingAuthentication
Dism /online /Enable-Feature /FeatureName:IIS-IISCertificateMappingAuthentication
Dism /online /Enable-Feature /FeatureName:IIS-RequestMonitor
Dism /online /Enable-Feature /FeatureName:IIS-ASPNET
Dism /online /Enable-Feature /FeatureName:IIS-NetFxExtensibility
Dism /online /Enable-Feature /FeatureName:IIS-ASPNET45
Dism /online /Enable-Feature /FeatureName:IIS-ASPNET

Write-Host "All IIS Configuration Done Wait for Site Creation" -ForegroundColor Yellow
LogWrite "All IIS Configuration Done Wait for Site Creation"

Set-Location -Path $cd
.\LocalSiteConfiguration.ps1