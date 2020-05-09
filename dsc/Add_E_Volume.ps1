Configuration Add_E_Volume
{
    
    Import-DSCResource -ModuleName StorageDsc 
    Node $env:TARGETHOSTNAME
    {
        WaitForDisk Disk1
        {
             DiskId = 1
             RetryIntervalSec = 60
             RetryCount = 60
        }
        Disk EVolume
        {
            DiskId = 1 
            DriveLetter = 'E'
            Size = 30592000000
            DependsOn = '[WaitForDisk]Disk1'
        }
    }
}

$md = $env:DSCDIRECTORY + "\Add_E_Volume"
New-Item $md -ItemType Directory -Force
Add_E_Volume -outputpath $md