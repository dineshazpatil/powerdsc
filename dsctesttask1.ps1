$configdata= @{

    AllNodes = @(
    
            @{
                Nodename="Test1"
                Features = @("Web","TelnetClient")
            }
    
        )
    


}



Configuration FirstConfiguration
{ 

  
    Import-DscResource -ModuleName PSDesiredstateconfiguration
    Node $Allnodes.Nodename
    {
    
        WindowsFeatureSet $feature
        
        {
            Name = $node.features
            Ensure = "Present"
        
        }

    
    }
}


Firstconfiguration -OutputPath C:\Demo\FirstConfiguration -ConfigurationData $configdata


