https://gitforwindows.org/ 

$cert=New-SelfSignedCertificate -Subject $($env:Computername) -DnsName $($env:Computername) -HashAlgorithm Sha256 -KeyLength 2048

$cert | Export-Certificate -FilePath C:\publickey\DSCServer.cer -Force

$registrationkey = ([guid]::NewGuid()).GUid

Configuration PullServerHTTPS
{
    param 
    (
        [Parameter()]
        [String]
        $NodeName = 'localhost',

        [Parameter(Mandatory = $true)]
        [String]
        $certificateThumbPrint,

        [Parameter(Mandatory = $true)]
        [String]
        $RegistrationKey
    )
    
    Import-DSCResource -ModuleName xPSDesiredStateConfiguration -Name xDSCWebService -ModuleVersion 8.4.0.0
    Import-DscResource -ModuleName PSDesiredStateConfiguration -ModuleVersion 1.1

    Node $NodeName
    {
        WindowsFeature DSCServiceFeature
        {
            Ensure = 'Present'
            Name   = 'DSC-Service'            
        }

        xDscWebService PSDSCPullServer
        {
            Ensure                  = 'Present'
            EndpointName            = 'PSDSCPullServer'
            Port                    = 8080
            PhysicalPath            = "$env:SystemDrive\inetpub\PSDSCPullServer"
            CertificateThumbPrint   = $certificateThumbPrint         
            ModulePath              = "$env:PROGRAMFILES\WindowsPowerShell\DscService\Modules"
            ConfigurationPath       = "$env:PROGRAMFILES\WindowsPowerShell\DscService\Configuration"            
            State                   = 'Started' 
            RegistrationKeyPath     = "$env:PROGRAMFILES\WindowsPowerShell\DscService"   
            AcceptSelfSignedCertificates = $true
            UseSecurityBestPractices = $true
            DependsOn               = '[WindowsFeature]DSCServiceFeature'
        }

        File RegistrationKeyFile
        {
            Ensure          = 'Present'
            Type            = 'File'
            DestinationPath = "$env:ProgramFiles\WindowsPowerShell\DscService\RegistrationKeys.txt"
            Contents        = $RegistrationKey
        }
    }
}
PullServerHTTPS -RegistrationKey $registrationkey -certificateThumbPrint $cert.Thumbprint
