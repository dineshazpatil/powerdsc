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
configuration SmbCredTest
{
    Node $AllNodes.NodeName
    {
        Settings
        {
            RefreshMode = 'Pull'
            RefreshFrequencyMins = 30
            RebootNodeIfNeeded = $true
            ConfigurationID    = '959955d4-72c3-4ab8-9bb1-565bc07a8d5d'
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
            #PSDscAllowPlainTextPassword = $true
        })
}

SmbCredTest -OutputPath C:\ClientConfig\nodes -ConfigurationData $ConfigurationData 

$client="DSCClient"
$cimSessionOption = New-CimSessionOption -UseSsl -SkipCACheck -SkipCNCheck
$cimSession = New-CimSession -SessionOption $cimSessionOption -ComputerName "Dscclient" -Port 5986  -Credential $cred -Verbose

Set-DscLocalConfigurationManager -CimSession $cimSession -Path C:\ClientConfig\nodes

Update-DscConfiguration -CimSession $cimSession -Verbose -Wait -Debug






