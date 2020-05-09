Configuration Add_DJ_Volume
{
    
    Import-DSCResource -ModuleName StorageDsc 
    Node $env:TARGETHOSTNAME
    {
        Disk DVolume
        {
            DiskId = 1 
            DriveLetter = 'D'
            Size = 32000000000 
        }

        Disk JVolume
        {
            DiskId = 2 
            DriveLetter = 'J'
            Size = 21300000000 
        }
    }
}

$md = $env:DSCDIRECTORY + "\Add_DJ_Volume"
New-Item $md -ItemType Directory -Force
Add_DJ_Volume -outputpath $md;