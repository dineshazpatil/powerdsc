# In sequence

workflow test-sequence
{
    sequence 
    {
        Get-CimInstance win32_bios
        Get-CimInstance win32_computerSystem
    
    }


}

test-sequence
measure-command {1..100 | foreach{$test=test-sequence}}

workflow test-parallel
{
    Parallel 
    {
        Get-CimInstance win32_bios
        Get-CimInstance win32_computerSystem
    
    }


}

test-parallel
measure-command {1..100 | foreach {$test2=test-parallel}}


workflow Test-Foreachparallel
{
    $objs = @("win32_bios","win32_computersystem")

    foreach -Parallel ($obj in $objs) #-throttlelimit
    {
        Get-CimInstance $obj
    
    }

}
Test-Foreachparallel



Restrictions:

Some Automatic Variables unavailable
    
    $args $Error and few more

Some cmdlets you can not call

*-alias *-psdrive *-variable debug-process Get-credential Read-host show-command show-eventlog

Some PowerShell language features you can not see

$Date variable is not allowed
You cannot set assign enviornment variable 
SubExpression Begin/Process/End 


those not suported can be run 

Inlinescript {write-host }


#suspend-workflow 
Workflow Test-Suspend
{
    $a = Get-Date
    Suspend-Workflow
    (Get-Date)- $a
}
Test-Suspend


restart-computer in workflow

workflow New-ComputerSetup
{
   ...
   $cn =  Get-CimInstance -ClassName Win32_ComputerSystem
   if ($cn.SystemType -like "64*") 
   {
       $NewCnName = $PSComputerName + "64"
       Rename-Computer -ComputerName $PSComputerName -NewName $NewCnName
   }
   Restart-Computer -Wait
   $disks = Get-Disk
   ...
} 

$AtStartup = New-JobTrigger -AtStartup


Register-ScheduledJob -Name ResumeWorkflow -Trigger $AtStartup -ScriptBlock {Import-Module PSWorkflow; Get-Job ComputerSetup -State Suspended | Resume-Job}

New-ComputerSetup -JobName ComputerSetup
Get-Job ComputerSetup

Unregister-ScheduledJob -Name ComputerSetup