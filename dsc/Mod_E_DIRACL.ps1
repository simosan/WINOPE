Configuration Mod_E_DIRACL
{
    Import-DscResource -ModuleName Carbon
    Node $env:TARGETHOSTNAME
    {
        Carbon_Permission Mod_ii_bin_ReadOnly
        {
            Path = 'E:\appl\ii\bin'
            Identity = 'simosan\sim'
            Permission = 'ReadData','ReadAttributes','ReadExtendedAttributes','ReadPermissions','ExecuteFile'
        }

        Carbon_Permission Mod_ii_etc_ReadOnly
        {
            Path = 'E:\appl\ii\etc'
            Identity = 'simosan\sim'
            Permission = 'ReadData','ReadAttributes','ReadExtendedAttributes','ReadPermissions','ExecuteFile'
        }

        Carbon_Permission Mod_ii_lib_ReadOnly
        {
            Path = 'E:\appl\ii\lib'
            Identity = 'simosan\sim'
            Permission = 'ReadData','ReadAttributes','ReadExtendedAttributes','ReadPermissions','ExecuteFile'
        }
    }
}

$md = $env:DSCDIRECTORY + "\Mod_E_DIRACL"
New-Item $md -ItemType Directory -Force
Mod_E_DIRACL -outputpath $md