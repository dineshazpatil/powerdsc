param($regkey , $dscserver)
$regkey = get-content -Path "$env:ProgramFiles\WindowsPowerShell\DscService\RegistrationKeys.txt"
$dscserver = $env:COMPUTERNAME

$ClientConfig ="C:\Clientconfig"

$secpasswd = ConvertTo-SecureString "dineshSRV@123" -AsPlainText -Force
$Cred = New-Object System.Management.Automation.PSCredential ("administrator", $secpasswd)

$client=$($env:COMPUTERNAME)
$cimSessionOption = New-CimSessionOption -UseSsl -SkipCACheck -SkipCNCheck
$cimSession = New-CimSession -SessionOption $cimSessionOption -ComputerName $client -Port 5986  -Credential $Cred -Verbose


mkdir $ClientConfig

[DSCLocalConfigurationManager()]
configuration ClientLCMConfiguration
{
    param
    (
        [ValidateNotNullOrEmpty()]
        [string] $NodeName = 'localhost',

        [ValidateNotNullOrEmpty()]
        [string] $RegistrationKey, #same as the one used to setup pull server in previous configuration

        [ValidateNotNullOrEmpty()]
        [string] $ServerName = 'localhost' #node name of the pull server, same as $NodeName used in previous configuration
    )

    Node $NodeName
    {
        Settings
        {
            RefreshMode        = 'Pull'
        }

        ConfigurationRepositoryWeb Config-PullSrv
        {
            ServerURL          = "https://$ServerName`:8080/PSDSCPullServer.svc" # notice it is https
            RegistrationKey    = $RegistrationKey
            ConfigurationNames = @('ClientConfig')
        }

        ReportServerWeb Report-PullSrv
        {
            ServerURL       = "https://$ServerName`:8080/PSDSCPullServer.svc" # notice it is https
            RegistrationKey = $RegistrationKey
        }
    }
}

ClientLCMConfiguration -RegistrationKey $regkey -ServerName $dscserver -Nodename $client -OutputPath $ClientConfig\TargetNodes 

Set-DscLocalConfigurationManager -Path "$ClientConfig\TargetNodes" -CimSession $cimSession -Verbose

Update-DscConfiguration -CimSession $cimSession -Verbose -Wait -Debug