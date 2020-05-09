param (
    [String]$Certname
)

$thum = $(Get-ChildItem -Path Cert:\LocalMachine\My | Where-Object {$_.Subject -match $Certname}).Thumbprint
Write-Output $thum