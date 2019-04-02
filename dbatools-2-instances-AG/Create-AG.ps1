cd dockercompose:\dbatools-2-instances-AG

# I map C:\MSSQL\BACKUP\KEEP on my local machine (where my backups are) to /var/opt/mssql/backups 
# on the containers on lines 10 and 17 of the docker-compose - Change as required

docker-compose up -d 

# Create the credential with Get-Credential | Export-CliXml -Path sacred.xml
# U: sqladmin P: dbatools.IO

$cred = Import-Clixml -Path sacred.xml
$sqlinstance1 = 'localhost,15591'
$sqlinstance2 = 'localhost,15592'
$AGName = "dbatools-ag"

# use default parameters to save remembering to use the SqlCredential Param!

$PSDefaultParameterValues += @{ '*:SqlCredential' = $cred }

Get-DbaDatabase -SqlInstance $sqlinstance1  |ft 

$path = '/var/opt/mssql/backups/'

Test-DbaPath -SqlInstance $sqlinstance1 -SqlCredential $cred -Path $path

Get-DbaFile -SqlInstance $sqlinstance1 -SqlCredential $cred -Path $path
# look its on windows
ls C:\MSSQL\BACKUP\KEEP

$restoreDbaDatabaseSplat = @{
    SqlInstance = $sqlinstance1
    SqlCredential = $cred
    UseDestinationDefaultDirectories = $true
    Path = '/var/opt/mssql/backups/AdventureWorks2012-Full Database Backup.bak'
}
Restore-DbaDatabase @restoreDbaDatabaseSplat

Get-DbaDatabase -SqlInstance $sqlinstance1 -SqlCredential $cred -Database AdventureWorks2012
Get-DbaRestoreHistory  -SqlInstance $sqlinstance1 -SqlCredential $cred -Database AdventureWorks2012

Get-DbaAgHadr -SqlInstance $sqlinstance1 -SqlCredential $cred

# setup a powershell splat
$params = @{
    Primary = $sqlinstance1
    PrimarySqlCredential = $cred
    Secondary = $sqlinstance2
    SecondarySqlCredential = $cred
    Name = $AGName
    Database = "pubs"
    ClusterType = "None"
    SeedingMode = "Automatic"
    FailoverMode = "Manual"
    Confirm = $false
 }
 
# execute the command
 New-DbaAvailabilityGroup @params -Verbose

 Get-DbaAgHadr -SqlInstance $sqlinstance1 -SqlCredential $cred
 Get-DbaAvailabilityGroup -SqlInstance $sqlinstance1 -SqlCredential $cred
 Get-DbaAgDatabase -SqlInstance $sqlinstance1 -SqlCredential $cred -AvailabilityGroup $AGName
 Get-DbaAgReplica -SqlInstance $sqlinstance1 -SqlCredential $cred


docker-compose down