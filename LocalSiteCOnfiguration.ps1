#Need to Impoert teh WebAdministration
write-host "In LocalSiteConfiguration"
Import-Module Webadministration

#Start:: Set the default parameters 
$jsonData = (Get-Content "config.json" -Raw)
$JsonObject = Microsoft.PowerShell.Utility\ConvertFrom-Json -InputObject $JsonData
$AppPoolsList = $JsonObject.ApplicationPoolName
$SiteName = $JsonObject.WebSite
$WebSitePath = $JsonObject.WebSiteDestinationpath.path
$progesscount = 1
$managedRuntimeVersion = "v4.0"
$ideltimeout = 360
$enable32BitAppOnWin64 = 1
$loadUserProfile = 0
$connectionTimeout = 3600
#End::

$cd = $JsonObject.currentDirectory.path

$logfile = $cd+"\Installationlog.log"

function LogWrite {
    param ([String]$logString)
    $time = Get-Date
    $string = '*** ' +$time.ToString() +' == '+ $logString
    Add-Content $logfile -Value $string
}
LogWrite "In LocalSiteConfiguration"

 #Create the application pool.
 Function CreateAppPool {
         Param([string] $appPoolName)

        LogWrite "Creating Application pool"
        if(Test-Path ("IIS:\AppPools\" + $appPoolName)) {
            Write-Host "The App Pool $appPoolName already exists" -ForegroundColor Yellow
        LogWrite "The App Pool $appPoolName already exists"
        }
        else{
             $appPool = New-WebAppPool -Name $appPoolName
        }
}

 #set the properties for the application pool.+
Function SetProperties {
     Param([string] $appPoolName,
        [string] $managedRuntimeVersion,
        [bool]$enable32BitAppOnWin64)
    
    LogWrite "Set the Properties Application pool"
    Set-ItemProperty IIS:\AppPools\$appPoolName managedRuntimeVersion  $managedRuntimeVersion
    Set-ItemProperty IIS:\AppPools\$appPoolName processModel.idleTimeout -value ( [TimeSpan]::FromMinutes($ideltimeout))
    #Set-ItemProperty IIS:\AppPools\$appPoolName processModel.loadUserProfile $loadUserProfile
    if ($enable32BitAppOnWin64)
    {
             Set-ItemProperty IIS:\AppPools\$appPoolName enable32BitAppOnWin64 $enable32BitAppOnWin64 
    }
}

 Function CreateWebApp {
         Param([string] $WebSiteName,
               [string] $WebAppName,
               [string] $WebSitePath
    )
    LogWrite "Create Web Application"

    if (Test-Path ("IIS:\Sites\$WebSiteName\$WebAppName")){
        Write-Host "Web App $WebAppName already exists" -ForegroundColor Yellow
       return
    }
    else {
        New-WebApplication -Site $WebSiteName -name $WebAppName  -PhysicalPath $WebSitePath -ApplicationPool $WebAppName
    }
}

 #Create the site by passing Website Name, Application pool name and physical path
 Function CreateWebSite{
        Param([String] $WebSiteName,
        [String] $appPoolName,
        [String] $WebSitePath)

        LogWrite "Creating Web Site $WebSiteName"
        if(Test-Path ("IIS:\Sites\$WebSiteName")){
            Write-Host "Web Site $WebSiteName Already Exists" -ForegroundColor Yellow
        LogWrite "Web Site $WebSiteName Already Exists"
        }
        else{
            New-WebSite -Name $WebSiteName -Port 80 -HostHeader $WebSiteName -ApplicationPool $appPoolName -PhysicalPath $WebSitePath
            Write-Host "Web Site $WebSiteName Created successfully" -ForegroundColor Green
            LogWrite "Web Site $WebSiteName Created successfully"
        }
 }

 #Set Properties for the Website
 Function SetWebSiteProperties{
        Param([String] $WebSiteName)
             LogWrite "Set the web site properties for $WebSiteName"

        Set-ItemProperty IIS:\Sites\$WebSiteName -Name limits.connectionTimeout -Value ([TimeSpan]::FromSeconds($connectionTimeout))
 }
#START::Create task Website
Function CreateTaskSite{

    $tasksiteName = "task.officebox.local"
    $taskSitePath = $($WebSitePath+$tasksiteName)

    LogWrite "Creating task site and Application Pool."
    CreateAppPool $tasksiteName
    SetProperties $tasksiteName $managedRuntimeVersion $enable32BitAppOnWin64

    LogWrite "Creating Task site"
    if(Test-Path ("IIS:\Sites\$tasksiteName")){
        Write-Host "Web Site $tasksiteName Already Exists" -ForegroundColor Yellow
        LogWrite "Web Site $tasksiteName Already Exists"
    }
    else{
        New-WebSite -Name $tasksiteName -Port 8787 -HostHeader 'localhost' -ApplicationPool $appPoolName -PhysicalPath $taskSitePath
        if(Test-Path ("IIS:\Sites\$tasksiteName")){
            Write-Host "Web Site $tasksiteName Created successfully" -ForegroundColor Green
            LogWrite "Web Site $tasksiteName Created successfully"
            SetWebSiteProperties $tasksiteName
        }
    }
}
#END::


#Log ==> Creating Application Pool
foreach($appPoolName in $AppPoolsList){
    
    #Start:: code for progress status
    $appPool = $appPoolName.AppPool
    #Write-Progress -Activity "Creating Application Pool" -Status "$appPool" `
    #-percentComplete ($progesscount / $AppPoolsList.Count*100)
    #End::

    CreateAppPool $appPoolName.AppPool   
    #Log ==> Set the Properties for the Application pool
    SetProperties $appPoolName.AppPool $managedRuntimeVersion $enable32BitAppOnWin64
    $progesscount++
}
#Log ==> Application Pool created successfully!

$progesscount = 1
#CreateWebApp $WebSiteName $WebAppName $WebSitePath 
foreach($WebSiteName in $SiteName){
    
    $statusname =  $WebSiteName.SiteName
    #Write-Progress -Activity "Creating Website " -Status "$statusname" `
    #-percentComplete ($progesscount / $SiteName.Count*100)

    $path = $($WebSitePath+$WebSiteName.SiteName)
    CreateWebSite $WebSiteName.SiteName $WebSiteName.SiteName $path
        #Log ==> Set the Properties for the Web Site
    SetWebSiteProperties $WebSiteName.SiteName
    $progesscount++
}
#Invoke CreateTaskSite for creating task site 
CreateTaskSite

#Script for updating the host file 
LogWrite "Adding the host entries!"
foreach($WebSiteName in $SiteName){
    $hostName = $WebSiteName.SiteName
    LogWrite "$hostName Added to Host file."
    If ((Get-Content "$($env:windir)\system32\Drivers\etc\hosts" ) -notcontains "127.0.0.1       $hostName")   
    {
        Add-content -Encoding UTF8  "$($env:windir)\system32\Drivers\etc\hosts" "127.0.0.1       $hostName" 
    }
}

#Once sites has been created, Browse the main site 
$ListSiteName = $SiteName.SiteName
$browseSiteName = $ListSiteName[0]
Start-Process "http://$browseSiteName"

c:\Windows\Microsoft.NET\Framework64\v4.0.30319\aspnet_regiis.exe -I

read-host "check the browser!"

LogWrite "check the browser!"
