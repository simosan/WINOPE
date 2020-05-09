Configuration Add_ORACLEENV
{
    # Carbonリソースの場合、システム環境変数のみ設定可能 
    Import-DscResource -ModuleName Carbon
    Node $env:TARGETHOSTNAME
    {
        Carbon_EnvironmentVariable OracleHome
        {
            Name = 'ORACLE_HOME'
            Value = 'd:\opt\oracle\product\193000\dbhome_1'
            Ensure = 'Present'
        }
    }
}

$md = $env:DSCDIRECTORY + "\Add_ORACLEENV"
New-Item $md -ItemType Directory -Force
Add_ORACLEENV -outputpath $md
