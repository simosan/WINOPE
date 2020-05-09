Configuration Mod_FOLDER_ACL
{
    Import-DscResource -ModuleName Carbon
    Node $env:TARGETHOSTNAME
    {
        Carbon_Permission Mod_D_ii_bin_ReadOnly
        {
            Path = 'D:\appl\ii\bin'
            Identity = 'simosan\sim'
            Permission = 'ReadData','ReadAttributes','ReadExtendedAttributes','ReadPermissions','ExecuteFile'
        }

        Carbon_Permission Mod_D_ii_etc_ReadOnly
        {
            Path = 'D:\appl\ii\etc'
            Identity = 'simosan\sim'
            Permission = 'ReadData','ReadAttributes','ReadExtendedAttributes','ReadPermissions','ExecuteFile'
        }

        Carbon_Permission Mod_D_ii_lib_ReadOnly
        {
            Path = 'D:\appl\ii\lib'
            Identity = 'simosan\sim'
            Permission = 'ReadData','ReadAttributes','ReadExtendedAttributes','ReadPermissions','ExecuteFile'
        }

        Carbon_Permission Mod_J_ii_bin_ReadOnly
        {
            Path = 'J:\appl\ii\bin'
            Identity = 'simosan\sim'
            Permission = 'ReadData','ReadAttributes','ReadExtendedAttributes','ReadPermissions','ExecuteFile'
        }

        Carbon_Permission Mod_J_ii_etc_ReadOnly
        {
            Path = 'J:\appl\ii\etc'
            Identity = 'simosan\sim'
            Permission = 'ReadData','ReadAttributes','ReadExtendedAttributes','ReadPermissions','ExecuteFile'
        }

        Carbon_Permission Mod_J_ii_lib_ReadOnly
        {
            Path = 'J:\appl\ii\lib'
            Identity = 'simosan\sim'
            Permission = 'ReadData','ReadAttributes','ReadExtendedAttributes','ReadPermissions','ExecuteFile'
        }
    }
}

$md = $env:DSCDIRECTORY + "\Mod_FOLDER_ACL"
New-Item $md -ItemType Directory -Force
Mod_FOLDER_ACL -outputpath $md