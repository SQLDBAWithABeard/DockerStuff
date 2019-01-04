$containers = 'localhost,15589','localhost,15588','localhost,15587','localhost,15586','localhost,15585'
$cred = Import-Clixml D:\OneDrive\Documents\GitHub\DockerStuff\SQLEnvironment\sacred.xml
Get-DbaDatabase -SqlInstance $containers -SqlCredential $cred |ft

Get-DbaBuildReference -SqlInstance $containers -SqlCredential $cred | ft