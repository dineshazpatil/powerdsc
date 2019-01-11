
if($cred -eq $null)
{
    $cred = Get-Credential
}
$client="DSCClient"
$cimSessionOption = New-CimSessionOption -UseSsl -SkipCACheck -SkipCNCheck
$cimSession = New-CimSession -SessionOption $cimSessionOption -ComputerName $client -Port 5986  -Credential $cred -Verbose


Configuration DemoLocalAdmin {

param(
[Parameter(Mandatory=$true)]
[ValidateNotNullorEmpty()]
[System.Management.Automation.Credential()]$Credential = [System.Management.Automation.PSCredential]::Empty
)

Node "DSCClient" {

    User LocalAdmin {
        UserName = "NtmsAdmin1"
        Description = "NTMS Local administrator account"
        Disabled = $False
        Ensure = "Present"
        Password = $Credential

    } 

    
    Group Administrators {
    	GroupName = "Administrators"
    	DependsOn = "[User]LocalAdmin"
    	MembersToInclude = "NtmsAdmin1"
    
    } 
    
    LocalConfigurationManager {
       
        CertificateID = $node.thumbprint
        ConfigurationMode = "ApplyandMonitor"
    } 
} 

} 


$ConfigData = @{
  AllNodes = @( 
    @{
       NodeName = "DscClient"                
       CertificateFile = "C:\DSCDemo\DSCClient.cer"
       
       Thumbprint = "A933AEC2DB6527D3C1E77C98C8600365CB7D1834" 
     }; 
   );
} 

#endregion

#region create MOf

#parameters to splat to the configuration
$paramHash = @{
 credential = 'NtmsAdmin1' ConfigurationData = $ConfigData OutputPath = 'C:\DSCDemo\DemoLocalAdmin'}

DemoLocalAdmin @paramHash

#view MOFs and note encrypted passwords
dir C:\DSCDemo\DemoLocalAdmin | foreach {psedit $_.FullName}

#endregion

#region configure LCM on remote server

$paramHash = @{
 computername = $ConfigData.allnodes.nodename Path = 'C:\DSCDemo\DemoLocalAdmin' Verbose = $True CimSession=$cimSession}

Set-DscLocalConfigurationManager -ComputerName "DscClient" -Path C:\DSCDemo\DemoLocalAdmin 

#verify LCM
Get-DscLocalConfigurationManager -Computername $paramhash.computername

#endregion

#region push the configuration

Start-DscConfiguration -Path C:\DSCDemo\DemoLocalAdmin -CimSession $cimSession -Wait -Verbose -force

#endregion

#region verify

Invoke-Command { net user ; Restart-Service winrm } -computername $client -Credential $cred -Port 5986 -UseSSL
Invoke-Command { net localgroup administrators } -computername $client -Credential $cred -Port 5986 -UseSSL


Invoke-Command { net user } -computername $client -Credential (Get-Credential) -Port 5986 -UseSSL

#test the credential
Get-WmiObject win32_logicaldisk -computer $client -credential "$Client\NtmsAdmin"

#endregion

