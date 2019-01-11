Configuration DemoConfigData {

Import-DscResource -ModuleName "PsDesiredStateConfiguration"
Node $AllNodes.Nodename {


$Node.features.foreach({
  
                          WindowsFeature $_ {
                          Name = $_
                          Ensure = 'Present'
                          IncludeAllSubFeature = $True

                         } 

                       })

$ConfigurationData.NonNodeData.Services.foreach({
                                                  Service $_ {
                                                   Name = $_
                                                   StartupType = "Automatic"
                                                   State = "Running"
                                                   }

                                                }) 

} 

Node $allnodes.Where({$_.role -eq 'FilePrint'}).Nodename {

    WindowsFeature FileServices {
        Name = "File-Services"
        Ensure = "Present"
        IncludeAllSubFeature = $True
    }     WindowsFeature PrintServices {
        Name = "Print-Services"
        Ensure = "Present"
        IncludeAllSubFeature = $True
   } 
   
 } 

Node $allnodes.Where({$_.role -eq 'Test'}).Nodename {

    WindowsFeature RSAT-AD-Powershell {
        Name = "RSAT-AD-PowerShell"
        Ensure = "Present"
        IncludeAllSubFeature = $True
    } 
   
 } 
 
} 

DemoConfigData -configurationdata .\DemoConfigData.psd1 -output C:\DSCDemo\Democonfig -verbose


psedit C:\Demo\DemoConfig\DSCClient.mof

if($cred -eq $null)
{
    $cred = Get-Credential
}
$client="DSCClient"
$cimSessionOption = New-CimSessionOption -UseSsl -SkipCACheck -SkipCNCheck
$cimSession = New-CimSession -SessionOption $cimSessionOption -ComputerName "Dscclient" -Port 5986  -Credential $cred -Verbose

Start-DscConfiguration -Path C:\DSCDemo\Democonfig -CimSession $cimSession -Wait -Verbose

Get-Job -Id 3
$jobdata= Receive-Job -id 3
