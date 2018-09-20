$currentDirectory = (Get-Item -Path ".\").FullName

$logath = "C:\log\Installationlog.log"

#$logath = "D:\OFFICEBOXINSTALLATION\Log\Installationlog.log"

function LogWrite {
    param ([String]$logString)
    $time = Get-Date
    $string = '*** ' +$time.ToString() +' == '+ $logString
    Add-Content $logath -Value $string
}
LogWrite "Installation Start!"