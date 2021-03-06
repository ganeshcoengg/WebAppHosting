#Need to Impoert teh WebAdministration
write-host "In localsitePVS2"
Set-ExecutionPolicy -Scope Process -ExecutionPolicy Bypass
Import-Module Webadministration

#Start:: Set the default parameters 
$JsonData = (Get-Content "B:\OFFICEBOX\OBEnvironmentAutomation\Officebox_environment\config.json" | Out-String)

    #Start:: Json data to PSObject 
    function ConvertFrom-Json([string] $JsonData){
        [System.Reflection.Assembly]::LoadWithPartialName("System.Web.Extensions") | out-null
        $ser = New-Object System.Web.Script.Serialization.JavaScriptSerializer
        write-output (new-object -type PSObject -property $ser.DeserializeObject($JsonData))
    }
    #End:: Json data to PSObject 

#$JsonObject = ConvertFrom-Json -InputObject $JsonData
$JsonObject = ConvertFrom-Json $JsonData
$AppPoolsList = $JsonObject.ApplicationPoolName
$SiteName = $JsonObject.WebSite
$AppFolder = $JsonObject.FolderPath
$progesscount = 1   #Bool Data
$managedRuntimeVersion = "v4.0"    #String Data
$ideltimeout = 360     #Date Time Data
$enable32BitAppOnWin64 = 1 #Bool Data
$loadUserProfile = 0    #Bool Data
$connectionTimeout = 3600   #Date Time Data
$Path = ""
#End::

 #Create the application pool.
Function CreateAppPool {
    Param([string] $appPoolName)
    
    if(Test-Path ("IIS:\AppPools\" + $appPoolName)) {
        Write-Host "The App Pool $appPoolName already exists" -ForegroundColor Yellow
    }
    else{
        $appPool = New-WebAppPool -Name $appPoolName
    }
}

#set the properties for the application pool.
Function SetProperties {
    Param([string] $appPoolName,
    [string] $managedRuntimeVersion,
    [bool]$enable32BitAppOnWin64)
    
    Set-ItemProperty IIS:\AppPools\$appPoolName managedRuntimeVersion  $managedRuntimeVersion
    Set-ItemProperty IIS:\AppPools\$appPoolName processModel.idleTimeout -value ( [TimeSpan]::FromMinutes($ideltimeout))
    #Set-ItemProperty IIS:\AppPools\$appPoolName processModel.loadUserProfile $loadUserProfile
    if ($enable32BitAppOnWin64){
        Set-ItemProperty IIS:\AppPools\$appPoolName enable32BitAppOnWin64 $enable32BitAppOnWin64 
    }
}
Function CreateWebApp {
    Param([string] $WebSiteName,
       [string] $WebAppName,
       [string] $AppFolder
    )
    if (Test-Path ("IIS:\Sites\$WebSiteName\$WebAppName")){
        Write-Host "Web App $WebAppName already exists" -ForegroundColor Yellow
        return
    }
    else {
    New-WebApplication -Site $WebSiteName -name $WebAppName  -PhysicalPath $AppFolder -ApplicationPool $WebAppName
    }
}

#Create the site by passing Website Name, Application pool name and physical path
Function CreateWebSite{
Param([String] $WebSiteName,
    [String] $appPoolName,
    [String] $AppFolder)
    if(Test-Path ("IIS:\Sites\$WebSiteName")){
        Write-Host "Web Site $WebSiteName Already Exists" -ForegroundColor Yellow
    }
    else{
        New-WebSite -Name $WebSiteName -Port 80 -HostHeader $WebSiteName -ApplicationPool $appPoolName -PhysicalPath $AppFolder
        Write-Host "Web Site $WebSiteName Created successfully" -ForegroundColor Green
    }
}

#Set Properties for the Website
Function SetWebSiteProperties{
    Param([String] $WebSiteName)
    
    Set-ItemProperty IIS:\Sites\$WebSiteName -Name limits.connectionTimeout -Value ([TimeSpan]::FromSeconds($connectionTimeout))
}

#Log ==> Creating Application Pool
foreach($appPoolName in $AppPoolsList){
    
    #Start:: code for progress status
    $appPool = $appPoolName.AppPool
    Write-Progress -Activity "Creating Application Pool" -Status "$appPool" `
    -percentComplete ($progesscount / $AppPoolsList.Count*100)
    #End::

    CreateAppPool $appPoolName.AppPool   
    #Log ==> Set the Properties for the Application pool
    SetProperties $appPoolName.AppPool $managedRuntimeVersion $enable32BitAppOnWin64
    $progesscount++
}
#Log ==> Application Pool created successfully!

$progesscount = 1
#CreateWebApp $WebSiteName $WebAppName $AppFolder 
foreach($WebSiteName in $SiteName){

    $statusname =  $WebSiteName.SiteName
    Write-Progress -Activity "Creating Website " -Status "$statusname" `
    -percentComplete ($progesscount / $SiteName.Count*100)

    #$path = $($AppFolder.Path+$WebSiteName.SiteName)                   #PS version 3
    $path = $($AppFolder[0].Path+''+$WebSiteName.SiteName)
    CreateWebSite $WebSiteName.SiteName $WebSiteName.SiteName $path
        #Log ==> Set the Properties for the Web Site
    SetWebSiteProperties $WebSiteName.SiteName
    $progesscount++
}

#Script for updating the host file 
foreach($WebSiteName in $SiteName){
    
    $hostName = $WebSiteName.SiteName    
    If ((Get-Content "$($env:windir)\system32\Drivers\etc\hosts" ) -notcontains "127.0.0.1       $hostName")   
    {
        ac -Encoding UTF8  "$($env:windir)\system32\Drivers\etc\hosts" "127.0.0.1       $hostName"
    }
}

#Once sites has been created, Browse the main site 
$ListSiteName = $SiteName
$browseSiteName = $ListSiteName[0].SiteName
start http://$browseSiteName

