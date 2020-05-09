$PRIVKEY = $env:DSCDIRECTORY + "\DscPrivateKey.pfx"
$PUBKEY = $env:DSCDIRECTORY + "\DscPublicKey.cer"

$cert = New-SelfSignedCertificate -Type DocumentEncryptionCertLegacyCsp -DnsName 'DscEncryptionCert' -HashAlgorithm SHA256
# プライベートキーをエクスポート
$mypwd = ConvertTo-SecureString -String $env:CERTPASSWD -Force -AsPlainText
$cert | Export-PfxCertificate -FilePath $PRIVKEY -Password $mypwd -Force
# このサーバからプライベートキーを削除。公開キーだけ残す。
$cert | Export-Certificate -FilePath $PUBKEY -Force
$cert | Remove-Item -Force
Import-Certificate -FilePath $PUBKEY -CertStoreLocation Cert:\LocalMachine\My