Configuration Mod_VMemorySize
{
    Import-DscResource -ModuleName ComputerManagementDsc
    Node $env:TARGETHOSTNAME
    {
        VirtualMemory PagingSettings
        {
           Type = 'CustomSize'
           Drive = 'C'
           InitialSize = '2048'
           MaximumSize = '2048'
        }
    }
}

$md = $env:DSCDIRECTORY + "\Mod_VMemorySize"
New-Item $md -ItemType Directory -Force
Mod_VMemorySize -outputpath $md