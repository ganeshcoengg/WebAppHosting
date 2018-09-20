$jsonData = (Get-Content "config.json" -Raw)
$JsonObject = Microsoft.PowerShell.Utility\ConvertFrom-Json -InputObject $JsonData
$destinationDatabasePath = $JsonObject.DatabaseDestinationpath.path
$logfiles = $JsonObject.Logpath.path

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