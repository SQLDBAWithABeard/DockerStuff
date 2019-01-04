$containers = 'localhost,15589','localhost,15588'
$cred = Import-Clixml D:\OneDrive\Documents\GitHub\DockerStuff\SQLEnvironment\sacred.xml
$filenames = (Get-ChildItem D:\SQLBackups\ -File).Name
Write-PSFMessage "Restoring databases" -Level Host
$containers.ForEach{
    $Container = $Psitem
    $NameLevel = (Get-DbaBuildReference -SqlInstance $Container -SqlCredential $cred).NameLevel
    Write-PsfMessage -Message "Working on $NameLevel"  -Level Host
    switch ($NameLevel) {
        2017 { 
            $2017 = Restore-DbaDatabase -SqlInstance $Container -SqlCredential $cred -Path C:\sqlbackups\ -useDestinationDefaultDirectories -WithReplace           
            Write-PsfMessage -Message "Restored Databases on 2017" -Level Host
        }
        2016 {
            $Files = $Filenames.Where{$PSitem -notlike '*2017*'}.ForEach{'C:\sqlbackups\' + $Psitem}
            $2016 = Restore-DbaDatabase -SqlInstance $Container -SqlCredential $cred -Path $Files -useDestinationDefaultDirectories -WithReplace            
            Write-PsfMessage -Message "Restored Databases on 2016" -Level Host
        }
        2014 {
            $Files = $Filenames.Where{$PSitem -notlike '*2017*' -and $Psitem -notlike '*2016*'}.ForEach{'C:\sqlbackups\' + $Psitem}
            $2014 = Restore-DbaDatabase -SqlInstance $Container -SqlCredential $cred -Path $Files -useDestinationDefaultDirectories -WithReplace            
            Write-PsfMessage -Message "Restored Databases on 2014" -Level Host
        }
        2012 {
            $Files = $Filenames.Where{$PSitem -like '*2012*'}.ForEach{'C:\sqlbackups\' + $Psitem}
            $2012 = Restore-DbaDatabase -SqlInstance $Container -SqlCredential $cred -Path $Files -useDestinationDefaultDirectories -WithReplace            
            Write-PsfMessage -Message "Restored Databases on 2012" -Level Host
        }
        Default {}
    }
}

if($true -eq $false){
$2012
$2014
$2016
$2017
}

Write-PSFMessage "The databases are" -Level Host

Get-DbaDatabase -SqlInstance $containers -SqlCredential $cred | ft