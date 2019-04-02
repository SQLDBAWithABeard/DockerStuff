docker-compose -f .\SQL2017\docker-compose.yml up -d

$cred = Get-Credential 

$SQL2019CTP23 = 'localhost,15593'
$SQL2019CTP24 = 'localhost,15594'

$PSDefaultParameterValues += @{'*dba*:SqlCredential' = $cred}

Test-DbaConnection -SqlInstance $SQL2019CTP23
Test-DbaConnection -SqlInstance $SQL2019CTP24

Get-DbaBuildReference -SqlInstance $SQL2019CTP23 -Update

$restoreDbaDatabaseSplat = @{
    DestinationLogDirectory = '/var/opt/sqlserver'
    Path = '/var/opt/mssql/backups\ROB-XPS_AdventureWorks2014_FULL_20180509_084604.bak'
    DestinationDataDirectory = '/var/opt/sqlserver'
    SqlInstance = $SQL2019CTP23
    WithReplace = $true
}
Restore-DbaDatabase @restoreDbaDatabaseSplat

docker-compose -f .\SQL2019\CTP2.4\docker-compose.yml up -d

docker-compose -f .\SQL2019\CTP2.3\docker-compose.yml down
docker-compose -f .\SQL2019\CTP2.4\docker-compose.yml down

docker-compose -f .\SQL2019\CTP2.3\docker-compose.yml up -d

$query = @"
CREATE DATABASE [WIP]
ON PRIMARY
    (NAME = N'WIP_Data', FILENAME = N'/var/opt/sqlserver/WIP_Data.mdf')
LOG ON
    (NAME = N'WIP_log', FILENAME = N'/var/opt/sqlserver/WIP_log.ldf');
GO
"@

Invoke-DbaQuery -SqlInstance $SQL2019CTP23 -Query $query

docker-compose -f .\SQL2019\CTP2.3\docker-compose.yml down 

Set-Location C:\temp\SqlWorkloadGenerator
.\RunWorkload.ps1 -SQLServer 'localhost,15593' -Database AdventureWorks2014 -UserName sa -Password 'Password0!' -TSQLFile C:\temp\SqlWorkloadGenerator\SqlScripts\AdventureWorksWorkload.sql -Frequency "Fast" -Duration 600


$restoreDbaDatabaseSplat = @{
    DestinationLogDirectory = '/var/opt/sqlserver'
    Path = '/var/opt/mssql/backups\ROB-XPS_AdventureWorks2014_FULL_20180509_084604.bak'
    DestinationDataDirectory = '/var/opt/sqlserver'
    SqlInstance = $SQL2019CTP23
    WithReplace = $true
}
Restore-DbaDatabase @restoreDbaDatabaseSplat


$scriptblock = {
    Import-Module SqlServer
    cd C:\temp\SqlWorkloadGenerator
    .\RunWorkload.ps1 -SQLServer 'localhost,15593' -Database AdventureWorks2014 -UserName sa -Password 'Password0!' -TSQLFile C:\temp\SqlWorkloadGenerator\SqlScripts\AdventureWorksWorkload.sql -Frequency "Fast" -Duration 600
}

1..2 | Start-RsJob $scriptblock 