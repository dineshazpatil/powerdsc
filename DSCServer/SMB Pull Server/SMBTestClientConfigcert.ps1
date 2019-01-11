$clientcertificate =Invoke-Command -ComputerName dscclient -Credential $cred -Port 5986 -UseSSL -ScriptBlock {

mkdir C:\temp
$cert = New-SelfSignedCertificate -Type DocumentEncryptionCertLegacyCsp -DnsName "$env:Computername" -HashAlgorithm SHA256

$cert | Export-Certificate -FilePath "C:\temp\$env:Computername.cer" -Force

return $cert

}

mkdir C:\Clientcertificate
$clientcertificate | Export-Certificate -FilePath "C:\Clientcertificate\DSCPublickey.cer"


# Import to the my store
Import-Certificate -FilePath "C:\Clientcertificate\DscPublicKey.cer" -CertStoreLocation Cert:\LocalMachine\My


#Get dsc config ready





Configuration Clienthostfile
{

    Import-DscResource -ModuleName xNetworking -ModuleVersion 5.7.0.0
    Node dscclient
    {
        xHostsFile myhostfile
        {
            HostName = "Test1"
            IPAddress = "10.0.0.101"
       
        }
       
    }
}

mkdir C:\ClientConfig
clienthostfile -OutputPath C:\Clientconfig

$Clientconfigid=([guid]::NewGuid()).Guid 

Copy-Item -Path C:\Clientconfig\dscclient.mof -Destination "C:\DscSmbShare\$Clientconfigid.mof" -Force
New-DscChecksum -Path "C:\DscSmbShare\$Clientconfigid.mof"

 #-OutPath "$env:PROGRAMFILES\WindowsPowerShell\DscService\Configuration" -Force

# Setting the local config manager to client using guid for confiuration id


if($cred -eq $null)
{
    $cred = Get-Credential
}

Invoke-Command -ComputerName dscclient -Credential $cred -Port 5986 -UseSSL -ScriptBlock {Get-DscLocalConfigurationManager}

$secpasswd = ConvertTo-SecureString “123#ntms123#” -AsPlainText -Force
$mycreds = New-Object System.Management.Automation.PSCredential (“dscadmin”, $secpasswd)

[DSCLocalConfigurationManager()]
configuration SmbencryCredTest
{
    param ($cert)
    Node $AllNodes.NodeName
    {
        Settings
        {
            RefreshMode = 'Pull'
            RefreshFrequencyMins = 30
            RebootNodeIfNeeded = $true
            ConfigurationID    = '959955d4-72c3-4ab8-9bb1-565bc07a8d5d'
            CertificateID = "5F3E04C5C7CF58F33E905F5EF64E114BA42AB91C"
        }

         ConfigurationRepositoryShare SmbConfigShare
        {
            SourcePath = '\\DSCSRV1\DscSmbShare'
            Credential = $mycreds
        }

        ResourceRepositoryShare SmbResourceShare
        {
            SourcePath = '\\DSCSRV1\DscSmbShare'
            Credential = $mycreds

        }
    }
}

$ConfigurationData = @{
    AllNodes = @(
        @{
            #the "*" means "all nodes named in ConfigData" so we don't have to repeat ourselves
            NodeName="dscclient"
            CertificateFile = "C:\Clientcertificate\DSCPublickey.cer"
            Thumbprint = "5F3E04C5C7CF58F33E905F5EF64E114BA42AB91C"
        })
}

SmbencryCredTest -OutputPath C:\ClientConfig\nodes -ConfigurationData $ConfigurationData -cert $($clientcertificate.Thumbprint)

$client="DSCClient"
$cimSessionOption = New-CimSessionOption -UseSsl -SkipCACheck -SkipCNCheck
$cimSession = New-CimSession -SessionOption $cimSessionOption -ComputerName "Dscclient" -Port 5986  -Credential $cred -Verbose

Set-DscLocalConfigurationManager -CimSession $cimSession -Path C:\ClientConfig\nodes

Update-DscConfiguration -CimSession $cimSession -Verbose -Wait -Debug

Invoke-Command -Credential $servercred -ComputerName dscclient -Port 5986 -UseSSL -ScriptBlock {Update-DscConfiguration -Verbose -Wait -Debug}

