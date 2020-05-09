Configuration Add_IIS
{
    
    Import-DscResource -ModuleName PSDscResources
    Node $env:TARGETHOSTNAME
    {
        # WindowsFeatureのnameはGet-WindowsFeatureで確認できる
        WindowsFeature IIS
        {
            Ensure = "Present"
            Name = "Web-Server"
        }

        WindowsFeature IISmgr
        {
            Ensure = "Present"
            Name = "Web-Mgmt-Tools"
        }

        WindowsFeature ASPDOTNET
        {
            Ensure = "Present"
            Name = "Web-Asp-Net45"
        }

        Service ServiceStart
        {
            Name = "W3SVC"
            StartupType = "Automatic"
            State = "Running"
        }
    }
}

$md = $env:DSCDIRECTORY + "\Add_IIS"
New-Item $md -ItemType Directory -Force
Add_IIS -outputpath $md
