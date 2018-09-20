#$PowershellUpdateInRegEdit = (Get-ItemProperty -Path 'hklm:\software\Microsoft\Windows\CurrentVersion\Run' -name "PowershellUpdate").PowershellUpdate

#if($PowershellUpdateInRegEdit -eq 'D:\OFFICEBOXINSTALLATION\Script\PowershellUpdate.ps1'){
    Remove-ItemProperty -Path 'hklm:\software\Microsoft\Windows\CurrentVersion\Run' -name "PowershellUpdate"
    Write-Host "Removed the PowershellUpdate Key from Registry!" -ForegroundColor Yellow
#}
#$currentDirectory = (Get-Item -Path ".\").FullName
$version = $PSVersionTable.PSVersion.Major
if($version -lt 3)
{
    $JsonData = (Get-Content "config.json" | Out-String)
        
    function ConvertFrom_Json([string] $JsonData){
       [System.Reflection.Assembly]::LoadWithPartialName("System.Web.Extensions") | out-null
          $ser = New-Object System.Web.Script.Serialization.JavaScriptSerializer
        write-output (new-object -type PSObject -property $ser.DeserializeObject($JsonData))
        }
    #End:: Json data to PSObject 

   
    $JsonObject = ConvertFrom_Json $JsonData
    $softwarepath = $JsonObject.SoftwareSourcePath[0].path
    $currentDirectory = $JsonObject.currentDirectory[0].path

    $logfile = $currentDirectory+"\Installationlog.log"

    function LogWrite {
        param ([String]$logString)
        $time = Get-Date
        $string = '*** ' +$time.ToString() +' == '+ $logString
        Add-Content $logfile -Value $string
    }
    LogWrite "updating Powershell"

    #Register the script Executed after the Reboot
    $regvalue =  $currentDirectory+"InstallOtherSoftware.ps1"
    LogWrite " Register the  InstallOtherSoftware in registry"
    New-ItemProperty -Path 'hklm:\software\Microsoft\Windows\CurrentVersion\Run' -name "InstallOtherSoftware" -value $regvalue

    $PSupdate = "$softwarepath\Win7AndW2K8R2-KB3134760-x64.msu"
    $ExitCode = (Start-Process -filepath wusa.exe -argumentlist "/i $PSupdate /quiet" -Wait -PassThru).ExitCode

    if ($ExitCode -eq 0) {
        write-host "Powershell Updated!" -ForegroundColor Green
        Restart-Computer 
    } 
    else{
        write-host " Powershell Not Updated!" -ForegroundColor Red    
    }
}
else{
        .\InstallOtherSoftware.ps1
}
