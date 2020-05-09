Configuration Add_WindowsFW
{
    Import-DscResource -ModuleName Carbon
    Node $env:TARGETHOSTNAME
    {
        Carbon_FirewallRule Outbound_ALL_OK
        {
            Name = 'OutboundOK';
            Action = 'Allow';
            Profile = 'Domain','Private';
            Description = 'simgrp';
            Direction = 'Out';
            RemoteIPAddress = '192.168.0.0/16';
            Ensure = 'Present';
        }

        Carbon_FirewallRule Inbound_TCP_WINRM_OK
        {
            Name = 'WinRM_AD_OnlyOK';
            Action = 'Allow';
            Profile = 'Domain','Private';
            Description = 'simgrp';
            Direction = 'In';
            Protocol = 'tcp';
            RemoteIPAddress = '192.168.11.10';
            LocalPort = '5985-5986';
            Ensure = 'Present';
        }

        Carbon_FirewallRule Inbound_ICMPV4_OK
        {
            Name = 'icmpv4OK';
            Action = 'Allow';
            Profile = 'Domain','Private';
            Description = 'simgrp';
            Direction = 'In';
            Protocol = 'icmpv4';
            RemoteIPAddress = '192.168.11.0/24';
            Ensure = 'Present';
        }

        Carbon_FirewallRule Inbound_ICMPV6_OK
        {
            Name = 'icmpv6OK';
            Action = 'Allow';
            Profile = 'Domain','Private';
            Description = 'simgrp';
            Direction = 'In';
            Protocol = 'icmpv6';
            RemoteIPAddress = '192.168.11.0/24';
            Ensure = 'Present';
        }

        Carbon_FirewallRule Inbound_TCP_EPHERAMERAL_OK
        {
            Name = 'ephemeralTcpOK';
            Action = 'Allow';
            Profile = 'Domain','Private';
            Description = 'simgrp';
            Direction = 'In';
            Protocol = 'tcp';
            RemoteIPAddress = '192.168.0.0/16';
            LocalPort = '49152-65535'; 
            Ensure = 'Present';
        }

        Carbon_FirewallRule Inbound_UDP_EPHERAMERAL_OK
        {
            Name = 'ephemeralUdpOK';
            Action = 'Allow';
            Profile = 'Domain','Private';
            Description = 'simgrp';
            Direction = 'In';
            Protocol = 'udp';
            RemoteIPAddress = '192.168.0.0/16';
            LocalPort = '49152-65535'; 
            Ensure = 'Present';
        }

        Carbon_FirewallRule Inbound_UDP_AD_OK
        {
            Name = 'DomainUdpOK';
            Action = 'Allow';
            Profile = 'Domain','Private';
            Description = 'simgrp';
            Direction = 'In';
            Protocol = 'udp';
            RemoteIPAddress = '192.168.11.0/24';
            LocalPort = '123,137,138';
            Ensure = 'Present';
        }

        Carbon_FirewallRule Inbound_TCP_RDP_OK
        {
            Name = 'RdpOK';
            Action = 'Allow';
            Profile = 'Domain','Private';
            Description = 'simgrp';
            Direction = 'In';
            Protocol = 'tcp';
            RemoteIPAddress = '192.168.11.0/24';
            LocalPort = '3389';
            Ensure = 'Present';
        }

        Carbon_FirewallRule Inbound_TCP_WinShare_OK
        {
            Name = 'SMB/CIFSOK';
            Action = 'Allow';
            Profile = 'Domain','Private';
            Description = 'simgrp';
            Direction = 'In';
            Protocol = 'tcp';
            RemoteIPAddress = '192.168.11.0/24';
            LocalPort = '445';
            Ensure = 'Present';
        }

        Carbon_FirewallRule Inbound_TCP_SIMMAC_OK
        {
            Name = 'HostOSTcpOK';
            Action = 'Allow';
            Profile = 'Domain','Private';
            Description = 'simgrp';
            Direction = 'In';
            Protocol = 'tcp';
            RemoteIPAddress = '192.168.11.21';
            LocalPort = '0-65535';
            Ensure = 'Present';
        }

        Carbon_FirewallRule Inbound_UDP_SIMMAC_OK
        {
            Name = 'HostOSUdpOK';
            Action = 'Allow';
            Profile = 'Domain','Private';
            Description = 'simgrp';
            Direction = 'In';
            Protocol = 'udp';
            RemoteIPAddress = '192.168.11.21';
            LocalPort = '0-65535';
            Ensure = 'Present';
        }
 
    }
}

$md = $env:DSCDIRECTORY + "\Add_WindowsFW"
New-Item $md -ItemType Directory -Force
Add_WindowsFW -outputpath $md