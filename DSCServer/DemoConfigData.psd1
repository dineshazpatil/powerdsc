@{
  
    AllNodes = @( 
                   @{
                        NodeName = "*";
                        Features = @("Telnet-Client","Windows-Server-Backup")
                    },

                   @{
                        NodeName = "DSCClient"; Role = "FilePrint"
                    },

                   @{
                        NodeName = "DSCClient1" ; Role = "Test"
                    }
    )
    ;
    
    NonNodeData = @{Services = "bits","remoteregistry","wuauserv"}
}