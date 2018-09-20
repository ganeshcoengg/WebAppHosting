$jsonData = (Get-Content "config.json" -Raw)
$JsonObject = Microsoft.PowerShell.Utility\ConvertFrom-Json -InputObject $JsonData
$logfiles = $JsonObject.Logpath.path

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