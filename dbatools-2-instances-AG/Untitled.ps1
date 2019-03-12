$cred = Import-Clixml -Path GIT:\DockerStuff\dbatools\sacred.xml
$sqlinstance1 = 'localhost,15591'
$sqlinstance2 = 'localhost,15592'

Invoke-DbcCheck -SqlInstance $sqlinstance2 -SqlCredential $cred -Check LastBackup

$Instance = $connectioncheck = Connect-DbaInstance  -SqlInstance $sqlinstance2 -SqlCredential $cred 

$Instance.Databases.Where{ ($psitem.Name -ne 'tempdb') } | Select Name, Status, IsAccessible , Readonly

($psitem.Status -match "Offline") -or ($psitem.IsAccessible -eq $false) -or ($psitem.Readonly -eq $true -and $skipreadonly -eq $true)