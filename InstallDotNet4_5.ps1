#InstallDotNet4.5
write-host "In InstallDotNet4.5 " -ForegroundColor Yellow
$JsonData = (Get-Content "config.json" | Out-String)

function ConvertFrom_Json([string] $JsonData){
    [System.Reflection.Assembly]::LoadWithPartialName("System.Web.Extensions") | out-null
    $ser = New-Object System.Web.Script.Serialization.JavaScriptSerializer
    write-output (new-object -type PSObject -property $ser.DeserializeObject($JsonData))
}

#End:: Json data to PSObject 
$JsonObject = ConvertFrom_Json $JsonData
$currentDirectory = $JsonObject.currentDirectory[0].path
Set-Location $currentDirectory

$logfile = $currentDirectory+"\Installationlog.log"

function LogWrite {
    param ([String]$logString)
    $time = Get-Date
    $string = '*** ' +$time.ToString() +' == '+ $logString
    Add-Content $logfile -Value $string
}

#$isInstallDotNet4_5InRegEdit = (Get-ItemProperty -Path 'hklm:\software\Microsoft\Windows\CurrentVersion\Run' -name "InstallDotNet4_5").InstallDotNet4_5
#if($isInstallDotNet4_5InRegEdit -eq 'InstallDotNet4_5.ps1'){

Remove-ItemProperty -Path 'hklm:\software\Microsoft\Windows\CurrentVersion\Run' -name "InstallDotNet4_5"
LogWrite "Removed the InstallDotNet4_5 Key from Registry!"
Write-Host "Removed the InstallDotNet4_5 Key from Registry!" -ForegroundColor Yellow
#}

LogWrite "Checking Dot net 4.5"
$version = $PSVersionTable.PSVersion.Major
$isV4release = (Get-ItemProperty -Path 'HKLM:\SOFTWARE\Microsoft\NET Framework Setup\NDP\v4\Full\' -Name Release -ErrorAction SilentlyContinue -ErrorVariable evRelease).release
$isV4installed = (Get-ItemProperty -Path 'HKLM:\SOFTWARE\Microsoft\NET Framework Setup\NDP\v4\Full\' -Name Install -ErrorAction SilentlyContinue -ErrorVariable evInstalled).install
if($isV4installed -eq 1 -and $isV4release -eq 378389)
{
    #New-ItemProperty -Path 'hklm:\software\Microsoft\Windows\CurrentVersion\Run' -name "InstallOtherSoftware" -value "InstallOtherSoftware.bat"
	LogWrite "Checking Powershell version > 3 or < 3"
    if($version -lt 3)
    {
	    LogWrite "if Powershell version > 3 then updating to PS version 5"
        .\PowershellUpdate.ps1
    }
    esle{
	    LogWrite "if Powershell version < 3 then Install other suporting software"
        .\InstallOtherSoftware.ps1
    }
}
else{
    LogWrite " Dot net 4.5 not available, so Installing Dot net framework 4.5.."        
    $TempDirectory = $JsonObject.SoftwareSourcePath[0].path
    $currentDirectory = $JsonObject.currentDirectory[0].path
    Write-Host "Installing Dot net framework 4.5..." -NoNewline
    $dotnetV4 = "$TempDirectory\dotnetfx45_full_x86_x64"
    $ExitCode = (Start-Process -FilePath "$dotnetV4" -ArgumentList "/quiet" -Wait -PassThru).ExitCode	
    
    if ($ExitCode -eq 0) {
        Write-Host 'Installed!' -ForegroundColor Green
        LogWrite "Installed Dot net framework 4.5.." 
        $regvalue =  $currentDirectory+"PowershellUpdate.ps1"
        LogWrite "Register the PowershellUpdate in registry"
        New-ItemProperty -Path 'hklm:\software\Microsoft\Windows\CurrentVersion\Run' -name "PowershellUpdate" -value $regvalue
        LogWrite "Restart System"
        Restart-Computer
    }
    else{
        LogWrite "Dot net framework 4.5 installation error" 
        Write-Host 'Frame Work not installed please try again later!' -ForegroundColor Yellow
        exit
    }
}