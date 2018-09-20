# ************** Installation Start ***************

Set-ExecutionPolicy remotesigned -Force

$currentDirectory = (Get-Item -Path ".\").FullName
$logfile = $currentDirectory+"\Installationlog.log"
function LogWrite {
    param ([String]$logString)
    $time = Get-Date
    $string = '*** ' +$time.ToString() +' == '+ $logString
    Add-Content $logfile -Value $string
}

LogWrite "Checking is user is Administrator or not"
$user = New-Object Security.Principal.WindowsPrincipal( [Security.Principal.WindowsIdentity]::GetCurrent() )

if(-not $user.IsInRole([Security.Principal.WindowsBuiltInRole]::Administrator)){
    Write-Host 'Please run again with Administrator privileges.' -ForegroundColor Red
    LogWrite "Please run again with Administrator privileges."
    exit
}

Set-ExecutionPolicy remotesigned -Force
Set-ExecutionPolicy -Scope Process -ExecutionPolicy Bypass -Force

#check Powershell version

LogWrite "Checking Dot net 3.5"
    $isV3_5installed = (Get-ItemProperty -Path 'HKLM:\SOFTWARE\Microsoft\NET Framework Setup\NDP\v3.5\' -Name Install -ErrorAction SilentlyContinue -ErrorVariable evInstalled).install
    if($isV3_5installed -eq 1)
    {
        #if dot net 3.5 is installed then start 4.5 installation
        LogWrite "Dot net 3.5 available, install dot net 4.5"
        .\InstallDotNet4_5.ps1
    }
    else
    {
        #Register the restrat command and the install the 3.5
        LogWrite "Register the InstallDotNet4_5 in registry"
        $regvalue =  $currentDirectory+"\InstallDotNet4_5.ps1"
        New-ItemProperty -Path 'hklm:\software\Microsoft\Windows\CurrentVersion\Run' -name "InstallDotNet4_5" -value $regvalue
        LogWrite "Instaling the dot net 3.5"
        Copy-Item $currentDirectory\config.json C:\Windows\System32
        DISM /Online /Enable-Feature /FeatureName:NetFx3
        LogWrite "Restart System"
        Restart-Computer
    }


