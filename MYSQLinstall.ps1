$jsonData = (Get-Content "config.json" -Raw)
$JsonObject = Microsoft.PowerShell.Utility\ConvertFrom-Json -InputObject $JsonData
$TempDirectory = $JsonObject.SoftwareSourcePath.path
$destinationDatabasePath = $JsonObject.DatabaseDestinationpath.path
$MySQLDestinationPath = $JsonObject.MySQLDestinationpath.path
$logfiles = $JsonObject.Logpath.path
Function Install_Mysql{
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

    & cmd.exe /c  $gotoBinPath\mysqld --install MySQL --defaults-file="$defaults_file"
    & cmd.exe /c  net start MySQL
}
Install_Mysql