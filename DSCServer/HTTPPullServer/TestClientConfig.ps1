Configuration Clienthostfile
{

    Import-DscResource -ModuleName xNetworking -ModuleVersion 5.7.0.0
    Node localhost
    {
        xHostsFile myhostfile
        {
            HostName = "Test"
            IPAddress = "10.0.0.100"
               
        
        }
    
    
    
    }


}

clienthostfile -OutputPath C:\Clientconfig

Copy-Item -Path C:\Clientconfig\localhost.mof -Destination "$env:PROGRAMFILES\WindowsPowerShell\DscService\Configuration\ClientConfig.mof" -Force
New-DscChecksum -Path "$env:PROGRAMFILES\WindowsPowerShell\DscService\Configuration\ClientConfig.mof" -OutPath "$env:PROGRAMFILES\WindowsPowerShell\DscService\Configuration" -Force