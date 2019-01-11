#requires -version 4.0

Function Invoke-Pull {
[cmdletbinding()]
param
(
[Parameter(Mandatory,HelpMessage="Enter the name of a DSC node",
ValueFromPipeline,ValueFromPipelineByPropertyName) ]
[ValidateNotNullorEmpty()]
[String[]] $ComputerName,
[ValidateRange( 1,3 )]
[uint32] $flag = 1
)

Begin {
    Write-Verbose -Message "Starting $($MyInvocation.Mycommand)"  
} #begin

Process { 

    foreach ($computer in $ComputerName) {
        Write-Verbose "Processing $($computer.toUpper())"

        $paramHash = @{
         ComputerName = $Computer         Namespace = 'root/microsoft/windows/desiredstateconfiguration'         Class = 'MSFT_DscLocalConfigurationManager'         MethodName = 'PerformRequiredConfigurationChecks'         Arguments = @{Flags=$flag}        }

        Invoke-CimMethod @paramHash
    } #foreach
} #process

End {
    Write-Verbose -Message "Ending $($MyInvocation.Mycommand)"
} #end
}