create csv file add two neighbour computernames

configuration to create folder on remote machine 

configuration has to be using paramter


Start-DscConfiguration -Path C:\demo -CimSession 

configuration config3
{
    Import-DscResource -ModuleName Psdesiredstateconfiguration 

    Node tigerpc
    {
        file createfolder
            {
                Type = 'Directory'
                DestinationPath = "C:\Dinesh"
                Force =$true      
            }
    
    }


}

config3

$cred = Get-Credential

$cimoption = New-CimSessionOption -SkipCACheck -SkipCNCheck -UseSsl

$cim =New-CimSession -Credential (Get-Credential) -ComputerName tigerpc -Port 5986 -SessionOption $cimoption

Start-DscConfiguration -CimSession $cim -Path C:\Demo\config4 -wait -Verbose


tigerpc 192.168.1.24

administrator ntms123#




$csvdetails = import-csv C:\Demo\tiger.csv

configuration config4
{
    param($compname)

    Import-DscResource -ModuleName Psdesiredstateconfiguration

    Node $compname
    {
        file dineshfolder
        {
            DestinationPath = "C:\dinesh\chapter1"
            type='Directory'
            Force = $true
               
        }
        
    }


    
}

config4

foreach ($com in $csvdetails)
{

   config4 -compname $com.compname -outputpath C:\demo\config4
    
    $cimoption = New-CimSessionOption -SkipCACheck -SkipCNCheck -UseSsl

    $cim =New-CimSession -Credential $cred -ComputerName $com.compname -Port 5986 -SessionOption $cimoption

    Start-DscConfiguration -path C:\demo\config4 -wait -Verbose 
}















