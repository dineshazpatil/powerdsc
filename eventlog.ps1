
#The other best way to track event logs is as below Using Get-winevent and XML this gives you an output as required 
#But there is one problem try to audit the folder and check what happens
# Let me know the issue
while($true)
{

$myevent=Get-WinEvent -logname "Security" | ?{$_.id -eq "4663"} | select -First 1 

[xml]$eventmesasge = $myevent.ToXml()

$eventmesasge.ChildNodes.Where({$_.Name -eq "Object Name" })

$requiredout=$eventmesasge.Event.EventData.Data.Where({$_.Name -eq "ObjectName" })

$requiredout.ForEach("#text")

$eventmesasge.Event.System.TimeCreated

}
