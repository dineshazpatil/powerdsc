<#
    Create SMB Share
    Add DSC Windows Feature
    Copy Resources
    Copy MOFs (GUID)
    Configure node's LCM to Pull

#>



\\Powershell-DSC\DSCshare


#region manual setup

$computer = $env:COMPUTERNAME

mkdir C:\DSCShare 


$paramHash = @{
 Name = "DSCShare"
 Path = "C:\DSCShare"
 CimSession = $computer
 FullAccess = "Administrators"
 ReadAccess = "Everyone"
}

New-SmbShare @paramHash

Get-SmbShare DSCShare -cimsession $computer


Add-WindowsFeature DSC-Service -ComputerName $computer -verbose 


#Create a zip of all files from modules folder

Get-DscResource | 
where path -match "^c:\\Program Files\\WindowsPowerShell\\Modules" |
Select -expandProperty Module -Unique | 
foreach {
 $out = "{0}_{1}.zip" -f $_.Name,$_.Version
 $zip = Join-Path -path "\\$computer\DSCshare" -ChildPath $out
 New-ZipArchive -path $_.ModuleBase -OutputPath $zip -Passthru
 #give file a chance to close
 start-sleep -Seconds 3 
 If (Test-Path $zip) {
    Try {
        
        New-DSCCheckSum -ConfigurationPath $zip -ErrorAction Stop
    }
    Catch {
        Write-Warning "Failed to create checksum for $zip"
    }
 }
 else {
    Write-Warning "Failed to find $zip"
 }
 
}



#DemoPullConfig

$ConfigData = @{
  AllNodes = @( 
    @{
       NodeName = "DSCClient"                
       CertificateFile = "C:\DSCDemo\DSCClient.cer"
       Thumbprint = "A933AEC2DB6527D3C1E77C98C8600365CB7D1834" 
     }; 
   );
} 

Configuration DemoSMBPull {
    Import-DscResource -ModuleName PSDesiredStateConfiguration

    Node $AllNodes.nodename {
    
        file writesmbfile
        {
            
            DestinationPath = "C:\Temp\smbpull.txt"
            Type = "File"
            Contents = "This is test cerated by SMB Pull server"
            Ensure="Present"
        }
        
    }
}


$guid="1ca8e18e-7ce9-4468-ab53-b55bc8dafe11"
DemoSMBPull -OutputPath "C:\DSC\PullServer\SMB" -ConfigurationData $ConfigData

$src = "C:\Dsc\PullServer\SMB\DSCClient.mof"
$dst = Join-path -path "\\Powershell-dsc\DSCshare" -childpath "$guid.mof"

copy-item -path $src -des $dst -PassThru
New-DSCChecksum $dst 

dir \\Powershell-dsc\DSCshare "$guid*"
dir \\Powershell-dsc\DSCshare | group extension


$Client = "DscClient"
if($cred -eq $null)
{
    $cred = Get-Credential
}
Invoke-Command { Update-DscConfiguration } -computername $client -Credential $cred -Port 5986 -UseSSL

$client="DSCClient"
$cimSessionOption = New-CimSessionOption -UseSsl -SkipCACheck -SkipCNCheck
$cimSession = New-CimSession -SessionOption $cimSessionOption -ComputerName $client -Port 5986  -Credential $cred -Verbose

Get-DscConfiguration -CimSession $cimSession

Test-DscConfiguration -CimSession $cimSession

#Now let's make some changes to configuration


$ConfigData = @{
  AllNodes = @( 
    @{
       NodeName = "DSCClient"                
       CertificateFile = "C:\DSCDemo\DSCClient.cer"
       Thumbprint = "A933AEC2DB6527D3C1E77C98C8600365CB7D1834" 
     }; 
   );
} 

Configuration DemoSMBPullchange {
    Import-DscResource -ModuleName PSDesiredStateConfiguration
    Import-DscResource -ModuleName xnetworking 

    Node $AllNodes.nodename {
    
        file writesmbfile
        {
            
            DestinationPath = "C:\Temp\smbpull.txt"
            Type = "File"
            Contents = "This is test cerated by SMB Pull server"
            Ensure="Present"
        }

        xHostsFile addserverentry
        {
             HostName = "Powershell-dsc"
             IPAddress = "10.0.0.4"
        }
        
    }
}

DemoSMBPullchange -OutputPath "C:\DSC\PullServer\SMB" -ConfigurationData $ConfigData -verbose

$lcm =Get-DscLocalConfigurationManager -CimSession $cimSession
$guid =$lcm.ConfigurationID

del "\\powershell-dsc\DSCShare\$guid.mof.checksum"

$src = "C:\Dsc\PullServer\SMB\DSCClient.mof"
$dst = Join-path -path "\\Powershell-dsc\DSCshare" -childpath "$guid.mof"

copy-item -path $src -des $dst -PassThru
New-DSCChecksum $dst 

dir \\Powershell-dsc\DSCshare "$guid*"
dir \\Powershell-dsc\DSCshare | group extension

Invoke-Command { Update-DscConfiguration } -computername $client -Credential $cred -Port 5986 -UseSSL

Get-DscConfiguration -CimSession $cimSession

Test-DscConfiguration -CimSession $cimSession