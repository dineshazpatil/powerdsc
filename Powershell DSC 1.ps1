Get-CimInstance -namespace root/microsoft/windows -ClassName __NAMESPACE

get-cimclass -Namespace root/microsoft/windows/DesiredStateConfiguration -ClassName MSFT_* | fw

get-cimclass -Namespace root/microsoft/windows/DesiredStateConfiguration -ClassName MSFT_DSCmetaconfiguration 

get-cimclass -Namespace root/microsoft/windows/DesiredStateConfiguration -ClassName MSFT_DSCLOcalConfigurationmanager

Get-DscConfiguration

ApplyOnly
ApplyandMonitor
ApplyaAutoCorrect

Get-DscLocalConfigurationManager

#Anatomy of the Configuration Docs

Configuration ConfigurationName
{
#Module import using Import-DscResource
#This has different possible parameters
Import-DscResource -ModuleName ModuleName

#Optional Node block with one or more node names
        Node @(NodeNameArray) #Or a string literal
        {
        #One or more resource instances
            ResourceName ResourceInstanceName
            {
            KeyProperty = Value
            AnotherProperty = AnotherValue
            }
        }
}


#Finding and Installing DSC Resource Modules

#WMF 5.1

get-command -Module Powershellget

install-module -name PowershellGet -force
find-module
find-dscresource

get-module -ListAvailable

Find-Module -Includes DscResource

Find-Module -name cWindowsOS | select -ExpandProperty Additionalmetadata 


Find-Module -DscResource CDiskImage

Find-DscResource -ModuleName xNetworking -Name xHostsfile

Find-DscResource -name cDiskImage -ModuleName cWindowsOs -AllVersions 

use -requiredversion

Find-Module -Name xNetworking | install-module -force

${env:ProgramFiles}\WindowsPowerShell\Modules.

Install-Module -Name PsDscResources -Force

Save-Module -Name PSDscResources -Path C:\Modules -Force




Configuration FirstConfiguration
{
    Import-DscResource -ModuleName PSDesiredStateConfiguration
        Node localhost
        {
            Archive FirstArchiveConfiguration
            {
                Path = 'C:\Scripts\test.zip'
                Destination = 'C:\Demo'
                Ensure = 'Present'
            }
        }
}

FirstConfiguration


Configuration FirstConfiguration
{
    Import-DscResource -ModuleName PSDscResources
    Node localhost
    {
    Archive FirstArchiveConfiguration
    {
    Path = 'C:\Scripts\test.zip'
    Destination = 'C:\Demo'
    Ensure = 'Present'
    }
    }
}

Therefore, when you use the -Name parameter, it is recommended that you always
use the -ModuleName parameter to make it faster for the parser to find the right module
for you.

#check the different Module version


Configuration FirstConfiguration
    {
        Import-DscResource -Name xHostsFile -ModuleName xNetworking
            xHostsFile HostsFileConfiguration
                {
                    IPAddress = '10.0.0.1'
                    HostName = 'TestHost10'
                }
    }

FirstConfiguration


Specifying ModuleName and ModuleVersion is always the best practice

Import-DscResource -ModuleName @{ModuleName='xNetworking';RequiredVersion='5.0.0.0'}, @{ModuleName='PSDscResources';ModuleVersion='2.8.0.0'}

Get-DscResource -Name xHostsFile -Module xNetworking -Syntax

Get-DscResource -Name xHostsFile -Module xNetworking | Select-Object
-ExpandProperty Properties




Configuration DemoGroupConfiguration
{
    Import-DscResource -ModuleName PSDscResources
    Node @('S16-01','S16-02')
        {
            User DemoGroup
                {
                GroupName = 'DemoGroup'
                Description = 'Demo Group'
                Ensure = 'Present'
                }
        }
}

DemoGroupConfiguration -OutputPath C:\DemoGroupConfiguration -Verbose

start-dscconfiguration -path .\  -wait -verbosr -force

Invoke-Command -ComputerName S16-01, S16-02 -ScriptBlock { Install-Module
-Name PSDscResources -RequiredVersion 2.8.0.0 -Force } -Verbose
Invoke-Command -ComputerName S16-01, S16-02 -ScriptBlock { Get-Module -Name
PSDscResources -ListAvailable } -Verbose


Configuration DemoGroupConfiguration
{
    param (
    [Parameter(Mandatory)]
    [String]
    $GroupName,
    [Parameter(Mandatory)]
    [String]
    $Description,
    [Parameter()]
    [String[]] $Nodes = 'localhost'
    )
    
    Import-DscResource -ModuleName PSDscResources
        
        Node $Nodes
        {
         Group DemoGroup
            {
                GroupName = $GroupName
                Description = $Description
                Ensure = 'Present'
            }
    }
}

DemoGroupConfiguration -OutputPath C:\DemoGroupConfiguration `
-GroupName 'DemoGroup' `
-Description 'Demo Group' `
-Nodes 'S16-01','S16-02




Configuration DependentConfigurationDemo
{
        Import-DscResource -ModuleName PSDscResources -Name Registry
        Node S16-01
                {
                    File SetupScript
                    {
                        DestinationPath = 'C:\Scripts\setup.cmd'
                        Contents = 'C:\Windows\System32\Sysprep.exe /oobe /generalize /

                        shutdown'
                        Type = 'File'
                        Ensure = 'Present'
                        DependsOn = '[Registry]OOBEInProgress', '[Registry]SetupType'
                    }

                    Registry OOBEInProgress
                    {
                        Key = 'HKEY_LOCAL_MACHINE\SYSTEM\Setup'
                        ValueName = 'OOBEInProgress'
                        ValueData = 0
                        ValueType = 'DWord'
                        Ensure = 'Present'
                    }

                    Registry SetupType
                    {
                        Key = 'HKEY_LOCAL_MACHINE\SYSTEM\Setup'
                        ValueName = 'SetupType'
                        ValueData = 0
                        ValueType = 'DWord'
                        Ensure = 'Present'
                    }
                }
}



Configuration FileCopyConfiguration
{
    Import-DscResource -ModuleName PSDesiredStateConfiguration
    Node S16-01
    {
        File FileCopyDemo
        {
            SourcePath = '\\S16-JB\Share\Unattend.xml'
            DestinationPath = 'C:\Scripts\Unattend.xml'
            Type = 'File'
            Force = $true
        }
    }
}
FileCopyConfiguration


Configuration DSCRunDemo
{
    Import-DscResource -ModuleName PSDesiredStateConfiguration
    Node S16-01
        {
            Script DSCRunDemo
                {
                    SetScript =
                        {
                        Write-Verbose -Message $(whoami)
                        }
                    TestScript =
                        {
                        return $false
                        }
                    GetScript =
                        {
                        return @{}
                        }
            }
        }
}

DSCRunDemo -OutputPath C:\DemoGroupConfiguration -Verbose

start-dscconfiguration -path .\  -wait -verbose -force




Configuration FileCopyConfiguration
{
    Param
    (
    [Parameter(Mandatory)]
    [pscredential] $Credential
    )
    Import-DscResource -ModuleName PSDesiredStateConfiguration
    Node S16-01
        {
            File FileCopyDemo
                {
                SourcePath = '\\S16-JB\Share\Unattend.xml'
                DestinationPath = 'C:\Scripts\Unattend.xml'
                Type = 'File'
                Credential = $Credential Force = $true
                }
        }
}
FileCopyConfiguration -Credential (Get-Credential)

#This shoukd give an error



(get-command -name FileCopyConfiguration | select -Expandproperty parameters)['ConfigurationData']

$configurationData =
    @{
        AllNodes = @()
        EnvironmentData = ""
    }




$configurationData =
    @{
        AllNodes =
        @(
            @{
                NodeName = 'S16-01'
                SourceFile = '\\S16-JB\Share\S16-01.xml'
                DestinationFile = 'C:\Scripts\Unattend.xml'
            },
            @{
                NodeName = 'S16-02'
                SourceFile = '\\S16-JB\Share\S16-02.xml'
                DesitnationFile = 'C:\Scripts\Unattend.xml'
            }
        )
    }

Configuration FileCopyConfiguration
{
    Param
    (
    [Parameter(Mandatory)]
    [pscredential] $Credential
    )
    Import-DscResource -ModuleName PSDesiredStateConfiguration
    Node $AllNodes.NodeName
        {
            File FileCopyDemo
            {
                SourcePath = $Node.SourceFile
                DestinationPath = $Node.Destinationfile
                Type = 'File'
                Credential = $Credential
                Force = $true
            }
        }
}


FileCopyConfiguration -Credential (Get-Credential) -ConfigurationData

PSDscAllowPlainTextPassword to $true.



$config=@{
        NodeName ='*'
        DestinationFile ="C:\Scripts\Unattend.xml"
        PsDscAllowPlainTextPassword = $true
        PSDscAllowDomainUser = $true
}


#Using PSDscRunAsCredential


$configurationData =
    @{
        AllNodes =
        @(
            @{
                NodeName = "S16-01"
                PsDscAllowPlainTextPassword = $true
                PSDscAllowDomainUser = $true
            }
        )
    }

Configuration DSCRunDemo
    {
        Param
        (
        [Parameter(Mandatory)]
        [pscredential] $Credential
        )

    Import-DscResource -ModuleName PSDesiredStateConfiguration
    
    Node $AllNodes.NodeName
        {
        Script DSCRunDemo1
            {
                SetScript =
                {
                    Write-Verbose -Message $(whoami)
                }
                TestScript =
                    {
                        return $false
                    }
                GetScript =
                {
                    return @{}
                }
                    PSDscRunAsCredential = $Credential
            }
        }
    }

DSCRunDemo -configurationData $configurationData -Credential (Get-Credential)

# you might get an error in above configuration remove and use as PSDscRunAsCredential
DSCRunDemo -ConfigurationData $configurationData -PsDscRunAsCredential (Get-Credential) 



start-dscconfiguration -path .\Dscdemo  -wait -verbosr -force



#Using Certificates to Encrypt Credentials




Configuration MyDscConfiguration {

	Node $AllNodes.Where{$_.Role -eq "WebServer"}.NodeName
    {
		WindowsFeature IISInstall {
			Ensure = 'Present'
			Name   = 'Web-Server'
		}

	}
    Node $AllNodes.Where{$_.Role -eq "VMHost"}.NodeName
    {
        WindowsFeature HyperVInstall {
            Ensure = 'Present'
			Name   = 'Hyper-V'
        }
    }
}

$MyData =
@{
    AllNodes =
    @(
        @{
            NodeName    = 'VM-1'
            Role = 'WebServer'
        },

        @{
            NodeName    = 'VM-2'
            Role = 'VMHost'
        }
    )
}

MyDscConfiguration -ConfigurationData $MyData


$MyData =
@{
    AllNodes =
    @(
        @{
            NodeName           = “*”
            LogPath            = “C:\Logs”
        },

        @{
            NodeName = “VM-1”
            SiteContents = “C:\Site1”
            SiteName = “Website1”
        },


        @{
            NodeName = “VM-2”;
            SiteContents = “C:\Site2”
            SiteName = “Website2”
        }
    );

    NonNodeData =
    @{
        ConfigFileContents = (Get-Content C:\Template\Config.xml)
     }
}

configuration WebsiteConfig
{
    Import-DscResource -ModuleName xWebAdministration -Name MSFT_xWebsite

    node $AllNodes.NodeName
    {
        xWebsite Site
        {
            Name         = $Node.SiteName
            PhysicalPath = $Node.SiteContents
            Ensure       = “Present”
        }

        File ConfigFile
        {
            DestinationPath = $Node.SiteContents + “\\config.xml”
            Contents = $ConfigurationData.NonNodeData.ConfigFileContents
        }
    }
}


configuration VersionTest
{
    Import-DscResource -ModuleName (@{ModuleName='xFailOverCluster'; RequiredVersion='1.1'} )

    Node 'localhost'
    {
       xCluster ClusterTest
       {
            Name                          = 'TestCluster'
            StaticIPAddress               = '10.0.0.3'
            DomainAdministratorCredential = Get-Credential
        }
     }
}




Configuration ChangeCmdBackGroundColor
{
    Import-DscResource -ModuleName PSDesiredStateConfiguration

    Node $AllNodes.NodeName
    {
        Registry CmdPath
        {
            Key                  = 'HKEY_CURRENT_USER\SOFTWARE\Microsoft\Command Processor'
            ValueName            = 'DefaultColor'
            ValueData            = '1F'
            ValueType            = 'DWORD'
            Ensure               = 'Present'
            Force                = $true
            Hex                  = $true
            PsDscRunAsCredential = Get-Credential
        }
    }
}

$configData = @{
    AllNodes = @(
        @{
            NodeName             = 'localhost';
            PSDscAllowDomainUser = $true
            CertificateFile      = 'C:\publicKeys\targetNode.cer'
            Thumbprint           = '7ee7f09d-4be0-41aa-a47f-96b9e3bdec25'
        }
    )
}

ChangeCmdBackGroundColor -ConfigurationData $configData





Configuration JoinDomain

{
	Import-DscResource -Module xComputerManagement, xActiveDirectory

	Node myDC
	{
		WindowsFeature InstallAD
		{
			Ensure = 'Present'
			Name = 'AD-Domain-Services'
		}

		xADDomain NewDomain
		{
			DomainName = 'Contoso.com'
			DomainAdministratorCredential = (Get-Credential)
			SafemodeAdministratorPassword = (Get-Credential)
			DatabasePath = "C:\Windows\NTDS"
			LogPath = "C:\Windows\NTDS"
			SysvolPath = "C:\Windows\Sysvol"
		}

	}

    Node myDomainJoinedServer
    {

	    WaitForAll DC
	    {
		    ResourceName      = '[xADDomain]NewDomain'
		    NodeName          = 'MyDC'
		    RetryIntervalSec  = 15
		    RetryCount        = 30
	    }

	    xComputer JoinDomain
	    {
		    Name             = 'myPC'
		    DomainName       = 'Contoso.com'
		    Credential       = (Get-Credential)
		    DependsOn        ='[WaitForAll]DC'
	    }
    }
}






#Prompt user for their credentials
#credentials will be unencrypted in the MOF
$promptedCreds = get-credential -Message "Please enter your credentials to generate a DSC MOF:"

# Store passwords in plaintext, in the document itself
# will also be stored in plaintext in the mof
$password = "ThisIsAPlaintextPassword" | ConvertTo-SecureString -asPlainText -Force
$username = "User1"
[PSCredential] $credential = New-Object System.Management.Automation.PSCredential($username,$password)

# DSC requires explicit confirmation before storing passwords insecurely
$ConfigurationData = @{
    AllNodes = @(
        @{
            # The "*" means "all nodes named in ConfigData" so we don't have to repeat ourselves
            NodeName="*"
            PSDscAllowPlainTextPassword = $true
        },
        #however, each node still needs to be explicitly defined for "*" to have meaning
        @{
            NodeName = "TestMachine1"
        },
        #we can also use a property to define node-specific passwords, although this is no more secure
        @{
            NodeName = "TestMachine2";
            UserName = "User2"
            LocalPassword = "ThisIsYetAnotherPlaintextPassword"
        }
        )
}
configuration unencryptedPasswordDemo
{
    Node "TestMachine1"
    {
        # We use the plaintext password to generate a new account
        User User1
        {
            UserName = $username
            Password = $credential
            Description = "local account"
            Ensure = "Present"
            Disabled = $false
            PasswordNeverExpires = $true
            PasswordChangeRequired = $false
        }
        # We use the prompted password to add this account to the local admins group
        Group addToAdmin
        {
            # Ensure the user exists before we add the user to a group
            DependsOn = "[User]User1"
            Credential = $promptedCreds
            GroupName = "Administrators"
            Ensure = "Present"
            MembersToInclude = "User1"
        }
    }

    Node "TestMachine2"
    {
        # Now we'll use a node-specific password to this machine
        $password = $Node.LocalPass | ConvertTo-SecureString -asPlainText -Force
        $username = $node.UserName
        [PSCredential] $nodeCred = New-Object System.Management.Automation.PSCredential($username,$password)

        User User2
        {
            UserName = $username
            Password = $nodeCred
            Description = "local account"
            Ensure = "Present"
            Disabled = $false
            PasswordNeverExpires = $true
            PasswordChangeRequired = $false
        }

        Group addToAdmin
        {
            Credential = $domain
            GroupName = "Administrators"
            DependsOn = "[User]User2"
            Ensure = "Present"
            MembersToInclude = "User2"
        }
    }

}
# We declared the ConfigurationData in a local variable, but we need to pass it in to our configuration function
# We need to invoke the configuration function we created to generate a MOF
unencryptedPasswordDemo -ConfigurationData $ConfigurationData
# We need to pass the MOF to the machines we named.
#-wait: doesn't use jobs so we get blocked at the prompt until the configuration is done
#-verbose: so we can see what's going on and catch any errors
#-force: for testing purposes, I run start-dscconfiguration frequently + want to make sure i'm
#        not blocked by previous configurations that are still running
Start-DscConfiguration ./unencryptedPasswordDemo -verbose -wait -force




Configuration DomainCredentialExample
{
    param
    (
        [PSCredential] $DomainCredential
    )
    Import-DscResource -ModuleName PSDesiredStateConfiguration

    node localhost
    {
        Group DomainUserToLocalGroup
        {
            GroupName        = 'ApplicationAdmins'
            MembersToInclude = 'contoso\alice'
            Credential       = $DomainCredential
        }
    }
}

$cred = Get-Credential -UserName contoso\genericuser -Message "Password please"
DomainCredentialExample -DomainCredential $cred




Configuration DomainCredentialExample
{
    param
    (
        [PSCredential] $DomainCredential
    )
    Import-DscResource -ModuleName PSDesiredStateConfiguration

    node localhost
    {
        Group DomainUserToLocalGroup
        {
            GroupName        = 'ApplicationAdmins'
            MembersToInclude = 'contoso\alice'
            Credential       = $DomainCredential
        }
    }
}

$cd = @{
    AllNodes = @(
        @{
            NodeName = 'localhost'
            PSDscAllowPlainTextPassword = $true
        }
    )
}

$cred = Get-Credential -UserName contoso\genericuser -Message "Password please"
DomainCredentialExample -DomainCredential $cred -ConfigurationData $cd