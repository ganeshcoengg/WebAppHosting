
#Start:: Set the default parameters 

<#$JsonData = (Get-Content "B:\OFFICEBOX\OBEnvironmentAutomation\Officebox_environment\config.json" | Out-String)
$version = $PSVersionTable.PSVersion.Major
if($version -lt 3)
{
        $JsonData = (Get-Content "B:\OFFICEBOX\OBEnvironmentAutomation\Officebox_environment\config.json" | Out-String)

        #Start:: Json data to PSObject 
        function ConvertFrom-Json([string] $JsonData){
            [System.Reflection.Assembly]::LoadWithPartialName("System.Web.Extensions") | out-null
            $ser = New-Object System.Web.Script.Serialization.JavaScriptSerializer
            write-output (new-object -type PSObject -property $ser.DeserializeObject($JsonData))
        }
        #End:: Json data to PSObject 

        $JsonObject = ConvertFrom-Json $JsonData
}
else{
        $JsonData = (Get-Content "B:\OFFICEBOX\OBEnvironmentAutomation\Officebox_environment\config.json" -Raw)
        $JsonObject = ConvertFrom-Json -InputObject $JsonData
}
#>

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
<#Function StartBackup {
		Param([string] $DBSERVER,
        [string] $databaseName,
        [string] $path)

          mysqldump -h $DBServer -u root -padmin --databases $databaseName > $path$databaseName.sql
            #check status           
  Write-Host "The $databaseName DATABASE BACKUP SUCCESSFULLY" -ForegroundColor Green
        
}		
#>

Function RestoreDatabase {
        param([String] $dbName)
        #Invoke-Expression -Command:
        $sqlfile = $databasePath+$dbName+'.sql'
       & cmd.exe /c "mysql -h $DBServer -u $userName ""-p$userPassword"" $dbName < $sqlfile"
}

Function CreateDatabases{
        param([String] $dbName)

        #Write-host "creating database $databaseName..." -NoNewline
        .\mysql.exe -h $DBServer -u $userName "-p$userPassword" -e "CREATE DATABASE IF NOT EXISTS $dbName"
        #mysql -h $DBServer -u $userName $userPassword  "show database like '$databaseName'"

        
}

<# foreach($MysqlDatabaseName in $DatabaseName){
		
    $statusname =  $MysqlDatabaseName.DBName
    Write-Progress -Activity "Databace Backup " -Status "$statusname" `
    -percentComplete ($progesscount / $SiteName.Count*100)

        $DBServer = $HostName.HostName
        $path = $($BackupPath.DBPath)
        $databaseName = $MysqlDatabaseName.DBName
		StartBackup $DBServer $databaseName $path
        $progesscount++

}
#>

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