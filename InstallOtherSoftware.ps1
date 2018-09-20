# Set the exact file path.
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

LogWrite "In the Install OtherSoftware Script"
#if($InstallOtherSoftwareInRegEdit -eq 'D:\OFFICEBOXINSTALLATION\Script\InstallOtherSoftware.bat'){
Remove-ItemProperty -Path 'hklm:\software\Microsoft\Windows\CurrentVersion\Run' -name "InstallOtherSoftware"
Write-Host "Removed the InstallOtherSoftware Key from Registry!" -ForegroundColor Yellow
LogWrite "Removed the InstallOtherSoftware Key from Registry!"

$TempDirectory = $JsonObject.SoftwareSourcePath.path
$destinationDatabasePath = $JsonObject.DatabaseDestinationpath.path
$MySQLDestinationPath = $JsonObject.MySQLDestinationpath.path
$logfiles = $JsonObject.Logpath.path

#Install NotPad ++
Function Install_NotpadPP {
    Write-Host 'Installing Notepad ++... ' -NoNewline
    LogWrite "Installing Notepad ++"
    $notepad = """$TempDirectory\npp.6.9.2.Installer.exe"""
    $ExitCode = (Start-Process -filepath "$notepad" -ArgumentList "/S /log $logfiles\notpadpplog.txt" -Wait -PassThru).ExitCode
    
    if ($ExitCode -eq 0) {
        Write-Host 'Installed!' -ForegroundColor Green
        LogWrite "Installed!"
    } 
    else {
        LogWrite "failed. There was a problem installing Notepad ++."
        Write-Host "failed. There was a problem installing Notepad ++. returned exit code $ExitCode." -ForegroundColor Red
    }
}

#Install Sql Yog Community
Function Install_sqlYogCommunity {
    Write-Host 'Installing SQL Yog Community ... ' -NoNewline
    LogWrite "Installing SQL Yog Community ..."
    $sqlYogCommunity = """$TempDirectory\SQLyog-12.1.6-0.x64Community.exe"""
	$ExitCode = (Start-Process -filepath "$sqlYogCommunity" -ArgumentList "/S /log $logfiles\sqlyoglog.txt" -Wait -PassThru).ExitCode
    
    if ($ExitCode -eq 0) {
        Write-Host 'Installed!' -ForegroundColor Green
        LogWrite "Installed!"
    } 
    else {
        LogWrite "failed. There was a problem installing SQLyog-12.1.6-0.x86Community."
        Write-Host "failed. There was a problem installing SQLyog-12.1.6-0.x86Community. returned exit code $ExitCode." -ForegroundColor Red
    }
}

#Install WinRar
Function Install_WinRar {
    Write-Host 'Installing WinRar... ' -NoNewline
    LogWrite "Installing WinRar..."
    $winRar = """$TempDirectory\wrar370"""
    $ExitCode = (Start-Process -filepath "$winRar" -ArgumentList "/S /log $logfiles\winRarlog.txt" -Wait -PassThru).ExitCode
    
    if ($ExitCode -eq 0) {
        Write-Host 'Installed!' -ForegroundColor Green
        LogWrite "Installed!"
    } 
    else {
        LogWrite "failed. There was a problem installing  Installing WinRar... "
        Write-Host "failed. There was a problem installing Firefox WinRar. returned exit code $ExitCode." -ForegroundColor Red
    }
}

#Install Mozilla
Function Install_Firefox {
    Write-Host 'Installing Firefox ... ' -NoNewline
    LogWrite "Installing Firefox ...."
    $firefox = """$TempDirectory\Firefox Setup 48.0.1.exe"""
	$ExitCode = (Start-Process -filepath "$firefox" -ArgumentList "/S /log $logfiles\firfoxlog.txt" -Wait -PassThru).ExitCode
    
    if ($ExitCode -eq 0) {
        Write-Host 'Installed!' -ForegroundColor Green
        LogWrite "Installed!"
    } 
    else {
        LogWrite "failed. There was a problem installing Firefox "
        Write-Host "failed. There was a problem installing Firefox Setup 48.0.1. returned exit code $ExitCode." -ForegroundColor Red
    }
}

#Install Chrome
Function Install_Chrome {
    Write-Host 'Installing Chrome... ' -NoNewline
    LogWrite "Installing Chrome ...."
    # Install Chrome
    $ChromeMSI = """$TempDirectory\GoogleChromeStandaloneEnterprise64.msi"""
	$ExitCode = (Start-Process -filepath msiexec -argumentlist "/i $ChromeMSI /qn /log $logfiles\chromelog.txt /norestart" -Wait -PassThru).ExitCode
    
    if ($ExitCode -eq 0) {
        Write-Host 'Installed!' -ForegroundColor Green
        LogWrite "Installed!"
    }
    else {
        LogWrite "failed. There was a problem installing Chrome "
        Write-Host "failed. There was a problem installing Google Chrome. MsiExec returned exit code $ExitCode." -ForegroundColor Red
    }
}

#Install Adobe reader
Function Install_AdobeReader {
    Write-Host 'Installing Adobe reader... ' -NoNewline
    LogWrite "Installing Adobe reader ...."
    $adobeReader = """$TempDirectory\AdbeRdr11010_en_US.exe"""
	$ExitCode = (Start-Process -filepath "$adobeReader" -ArgumentList "/sPB /rs /log $logfiles\adobrederlog.txt" -Wait -PassThru).ExitCode
    
    if ($ExitCode -eq 0) {
        Write-Host 'Installed!' -ForegroundColor Green
        LogWrite "Installed!"

    } 
    else {
        LogWrite "failed. There was a problem installing AdbeRdr11010_en_US "
        Write-Host "failed. There was a problem installing AdbeRdr11010_en_US. returned exit code $ExitCode." -ForegroundColor Red
    }
}

#Install Crystal Repoort
Function Install_CrystalRepoort {
    Write-Host 'Installing Crystal Repoort (SAP)... ' -NoNewline
    LogWrite "Installing Crystal Repoort (SAP) ...."

    $crystalRepoort = """$TempDirectory\CRRuntime_32bit_13_0_2.msi"""
	$ExitCode = (Start-Process -filepath msiexec -argumentlist "/i $crystalRepoort /qn /log $logfiles\crysatlreportlog.txt /norestart" -Wait -PassThru).ExitCode
    
    if ($ExitCode -eq 0) {
        Write-Host 'Installed!' -ForegroundColor Green
        LogWrite "Installed!"
    } 
    else {
        LogWrite "failed. There was a problem installing Crystal Repoort (SAP) "
        Write-Host "failed. There was a problem installing Crystal Repoort (SAP). MsiExec returned exit code $ExitCode." -ForegroundColor Red
    }
}

Function Install_Mysql_ODBC_Connector{
    Write-Host 'Installing Mysql connector-odbc... ' -NoNewline
    LogWrite "Installing connector-odbc ...."

    $mysqlODBC = """$TempDirectory\mysql-connector-odbc-5.1.9-win32.msi"""
	$ExitCode = (Start-Process -filepath msiexec -argumentlist "/i $mysqlODBC /quiet /log $logfiles\mysqlODBCConnectorlog.txt /norestart" -Wait -PassThru).ExitCode
    
    if ($ExitCode -eq 0) {
        Write-Host 'Installed!' -ForegroundColor Green
        LogWrite "Installed!"
    } 
    else {
        LogWrite "failed. There was a problem installing ODBC Connector "
        Write-Host "failed. There was a problem installing mysql ODBC Connector. MsiExec returned exit code $ExitCode." -ForegroundColor Red
    }
}

Function Install_Mysql_ODBC_Net{
    Write-Host 'Installing Mysql connector-net... ' -NoNewline
    LogWrite "Installing connector-odbc ...."
    $mysqlNet = """$TempDirectory\mysql-connector-net-6.9.9.msi"""
	$ExitCode = (Start-Process -filepath msiexec -argumentlist "/i $mysqlNet /quiet /log $logfiles\mysqlNetlog.txt /norestart" -Wait -PassThru).ExitCode
    
    if ($ExitCode -eq 0) {
        Write-Host 'Installed!' -ForegroundColor Green
        LogWrite "Installed!"
    } 
    else {
        Write-Host "failed. There was a problem installing mysql Connector net. MsiExec returned exit code $ExitCode." -ForegroundColor Red
        LogWrite "failed. There was a problem installing Connector net "
    }
}

Function Install_Microsoft_Visual_C++_2010_x86_Redistributable {
    Write-Host 'Installing Microsoft_Visual_C++_2010_x86_Redistributable_Setup... ' -NoNewline
    LogWrite "Installing Microsoft_Visual_C++_2010_x86_Redistributable_Setup ...."

    $MVS_x86_2010_Redistributable = """$TempDirectory\Microsoft_Visual_C++_2010_x86_Redistributable_Setup.exe"""
	$ExitCode = (Start-Process -filepath "$MVS_x86_2010_Redistributable" -ArgumentList "/q /log $logfiles\Microsoft_Visual_C++_2010_x86_Redistributable_Setuplog.txt" -Wait -PassThru).ExitCode
    
    if ($ExitCode -eq 0) {
        Write-Host 'Installed!' -ForegroundColor Green
        LogWrite "Installed!"
    } 
    else {
        LogWrite "failed. There was a problem installing Microsoft_Visual_C++_2010_x86_Redistributable "
        Write-Host "failed. There was a problem installing Microsoft_Visual_C++_2010_x86_Redistributable. returned exit code $ExitCode." -ForegroundColor Red
    }
}

Function Install_Microsoft_Visual_C++_2010_x64_Redistributable {
    Write-Host 'Installing Microsoft_Visual_C++_2010_x64_Redistributable_Setup... ' -NoNewline
    LogWrite "Installing Microsoft_Visual_C++_2010_x64_Redistributable_Setup ...."

    $MVS_x64_2010_Redistributable = """$TempDirectory\Microsoft_Visual_C++_2010_x86_Redistributable_Setup.exe"""
	$ExitCode = (Start-Process -filepath "$MVS_x64_2010_Redistributable" -ArgumentList "/q /log $logfiles\Microsoft_Visual_C++_2010_x86_Redistributable_Setuplog.txt" -Wait -PassThru).ExitCode
    
    if ($ExitCode -eq 0) {
        Write-Host 'Installed!' -ForegroundColor Green
        LogWrite "Installed!"
    } 
    else {
        LogWrite "failed. There was a problem installing  Microsoft_Visual_C++_2010_x86_Redistributable "
        Write-Host "failed. There was a problem installing Microsoft_Visual_C++_2010_x86_Redistributable. returned exit code $ExitCode." -ForegroundColor Red
    }
}

Function Install_Microsoft_Visual_C++_2008_x86_Redistributable {
    Write-Host 'Installing Microsoft_Visual_C++_2010_x64_Redistributable_Setup... ' -NoNewline
    LogWrite "Installing Microsoft_Visual_C++_2010_x64_Redistributable_Setup ...."

    $MVS_x86_2008Redistributable = """$TempDirectory\Microsoft_Visual_C++_2008_x86_Redistributable_Setup.exe"""
	$ExitCode = (Start-Process -filepath "$MVS_x86_2008Redistributable" -ArgumentList "/q /log $logfiles\Microsoft_Visual_C++_2008_x86_Redistributable_Setuplog.txt" -Wait -PassThru).ExitCode
    
    if ($ExitCode -eq 0) {
        Write-Host 'Installed!' -ForegroundColor Green
        LogWrite "Installed!"
    } 
    else {
        LogWrite "failed. There was a problem installing  Microsoft_Visual_C++_2008_x86_Redistributable "
        Write-Host "failed. There was a problem installing Microsoft_Visual_C++_2008_x86_Redistributable. returned exit code $ExitCode." -ForegroundColor Red
    }
}

Function Install_Microsoft_Visual_C++_2008_x64_Redistributable {
    Write-Host 'Installing Microsoft_Visual_C++_2008_x64_Redistributable_Setup... ' -NoNewline
    LogWrite "Installing Microsoft_Visual_C++_2010_x64_Redistributable_Setup ...."
    $MVS_x64_2008_Redistributable = """$TempDirectory\Microsoft_Visual_C++_2008_x64_Redistributable_Setup.exe"""
	$ExitCode = (Start-Process -filepath "$MVS_x64_2008_Redistributable" -ArgumentList "/q /log $logfiles\Microsoft_Visual_C++_2008_x64_Redistributable_Setuplog.txt" -Wait -PassThru).ExitCode
    
    if ($ExitCode -eq 0) {
        Write-Host 'Installed!' -ForegroundColor Green
        LogWrite "Installed!"

    } 
    else {
        LogWrite "failed. There was a problem installing  Microsoft_Visual_C++_2008_x64_Redistributable "
        Write-Host "failed. There was a problem installing Microsoft_Visual_C++_2008_x64_Redistributable. returned exit code $ExitCode." -ForegroundColor Red
    }
}

Function Install_Mysql{
    LogWrite "Extracting and copying the  Mysql ...."
    
    if(Test-Path -Path "C:\Program Files (x86)\WinRAR")
    {
        $WinRar = "C:\Program Files (x86)\WinRAR\WinRAR.exe"
    }
    else{
        $WinRar = "C:\Program Files\WinRAR\WinRAR.exe"
    }
    $MySQLSourcePath = Get-ChildItem -Filter "*.rar" -Path "$TempDirectory"
    #$destinationDatabasePath = "$destinationDatabasePath"
    &$WinRar x $MySQLSourcePath.FullName $MySQLDestinationPath
    Get-Process winrar | Wait-Process

    $gotoBinPath = $MySQLDestinationPath +"MySQL\bin"
    $defaults_file=$MySQLDestinationPath +"\MySQL\my.ini"

    LogWrite "Instaling  Mysql ...."
    & cmd.exe /c  $gotoBinPath\mysqld --install MySQL --defaults-file="$defaults_file"
    LogWrite "Start the  Mysql Service...."
    & cmd.exe /c  net start MySQL
}

function DatabaseExtraction {

    LogWrite "Extracting and copying the  Database ...."
    $sourceDatabasePath = $JsonObject.DatabaseSourcePath.path
    $destinationDatabasePath  = $JsonObject.DatabaseDestinationpath.path
    
    if(Test-Path -Path "C:\Program Files (x86)\WinRAR"){
        $WinRar = "C:\Program Files (x86)\WinRAR\WinRAR.exe"
    }
    else{
        $WinRar = "C:\Program Files\WinRAR\WinRAR.exe"
    }

    $sourceDBPath = Get-ChildItem -Filter "*.rar" -Path $sourceDatabasePath
    &$WinRar e $sourceDBPath.FullName $destinationDatabasePath
    Get-Process winrar | Wait-Process
}

function WebSiteExtraction {

    LogWrite "Extracting and copying the  WebSites ...."
    $sourceWebSitePath = $JsonObject.WebSiteSourcePath.path
    $destinationWebSitePath  = $JsonObject.WebSiteDestinationpath.path
    if(Test-Path -Path "C:\Program Files (x86)\WinRAR"){
    $WinRar = "C:\Program Files (x86)\WinRAR\WinRAR.exe"
}
else{
    $WinRar = "C:\Program Files\WinRAR\WinRAR.exe"
}

$sourceWebSite_Path = Get-ChildItem -Filter "*.rar" -Path $sourceWebSitePath
&$WinRar x $sourceWebSite_Path.FullName $destinationWebSitePath
Get-Process winrar | Wait-Process
}

Install_NotpadPP
Install_sqlYogCommunity
Install_WinRar
Install_Chrome
Install_Firefox
Install_AdobeReader
Install_CrystalRepoort
Install_Mysql_ODBC_Connector
#Install_Mysql_ODBC_Net
Install_Microsoft_Visual_C++_2010_x86_Redistributable
Install_Microsoft_Visual_C++_2010_x64_Redistributable
Install_Microsoft_Visual_C++_2008_x86_Redistributable
Install_Microsoft_Visual_C++_2008_x64_Redistributable
Install_Mysql
DatabaseExtraction
WebSiteExtraction

Set-Location -Path -Path $cd
.\DatabaseRestoration.ps1