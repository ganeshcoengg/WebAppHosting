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
LogWrite "In Database creating and restoring Script"

$DatabaseNames = $JsonObject.MysqlDatabaseName
$databasePath	=	$JsonObject.DatabaseDestinationpath.path
$DBServer = $JsonObject.MySQLHostName.HostName
$userName = $JsonObject.MySQLCredentials.DBUsername
$MySQLDestinationPath = $JsonObject.MySQLDestinationpath.path
$gotoBinPath = $MySQLDestinationPath +"MySQL\bin"
$progesscount = 1
Set-Location -Path $cd

Function RestoreDatabase {
    param([String] $dbName)
    #Invoke-Expression -Command:
    LogWrite "restoring Database $dbName"
    $sqlfile = $databasePath+$dbName+'.sql'
    & cmd.exe /c "mysql -h $DBServer -u $userName $dbName < $sqlfile"
}

Function CreateDatabases{
    param([String] $dbName)
    LogWrite "Creating Database $dbName"

    .\mysql.exe -h $DBServer -u $userName -e "CREATE DATABASE IF NOT EXISTS $dbName"
}

foreach($databaseName in $DatabaseNames){	
	$dbName = $databaseName.DBName
    Set-Location -Path $gotoBinPath
    LogWrite "Creating and restoring Database"
    Write-Progress -Activity "Creating and restoring Database " -Status "$dbName" `
    -percentComplete ($progesscount / $DatabaseNames.Count*100)
    if(-NOT (.\mysql.exe -h $DBServer -u $userName -e "SHOW DATABASES like'$dbName'")){
        CreateDatabases $dbName
    }
    #check database created or not 
    if(.\mysql.exe -h $DBServer -u $userName -e "SHOW DATABASES like'$dbName'"){
        RestoreDatabase $dbName
    }
    $progesscount++
}

Set-Location -Path $cd
.\IISConfiguration.ps1