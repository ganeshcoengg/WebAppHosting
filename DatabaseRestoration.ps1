
$jsonData = (Get-Content "config.json" -Raw)
$JsonObject = Microsoft.PowerShell.Utility\ConvertFrom-Json -InputObject $JsonData
$DatabaseNames = $JsonObject.MysqlDatabaseName
$databasePath	=	$JsonObject.DatabaseDestinationpath.path
$DBServer = $JsonObject.MySQLHostName.HostName
$userName = $JsonObject.MySQLCredentials.DBUsername
$MySQLDestinationPath = $JsonObject.MySQLDestinationpath.path
$gotoBinPath = $MySQLDestinationPath +"MySQL\bin"
$progesscount = 1
$cd = $JsonObject.currentDirectory.path
Set-Location -Path $cd
$userPassword = 'admin'

Function RestoreDatabase {
        param([String] $dbName)
    #Invoke-Expression -Command:
    $sqlfile = $databasePath+$dbName+'.sql'
    & cmd.exe /c "mysql -h $DBServer -u $userName ""-p$userPassword"" $dbName < $sqlfile"
}

Function CreateDatabases{
    param([String] $dbName)

    .\mysql.exe -h $DBServer -u $userName "-p$userPassword" -e "CREATE DATABASE IF NOT EXISTS $dbName"
}

foreach($databaseName in $DatabaseNames){	
	$dbName = $databaseName.DBName
    Set-Location -Path $gotoBinPath

    Write-Progress -Activity "Creating and restoring Database " -Status "$dbName" `
    -percentComplete ($progesscount / $DatabaseNames.Count*100)
    if(-NOT (.\mysql.exe -h $DBServer -u $userName "-p$userPassword" -e "SHOW DATABASES like'$dbName'")){
        CreateDatabases $dbName
    }
    #check database created or not 
    if(.\mysql.exe -h $DBServer -u $userName "-p$userPassword" -e "SHOW DATABASES like'$dbName'"){
        RestoreDatabase $dbName
    }
    $progesscount++
}
Set-Location -Path $cd
.\IISConfiguration.ps1