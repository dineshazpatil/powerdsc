$site = Invoke-WebRequest http://www.bing.com

$site | gm

$site.StatusCode
$site.StatusDescription

$cred = Get-Credential

$request = Invoke-WebRequest "https://www.facebook.com/login.php" -SessionVariable test

$forms = $request.Forms[0]
$forms.Fields

$forms.Fields['email']= 'dineshppatil@gmail.com'
$forms.Fields['pass']= $cred.Password

$login = Invoke-WebRequest -Uri ("https://www.facebook.com" + $forms.Action) -WebSession $test -Method Post -Body $forms.Fields -UseBasicParsing

$login.Links | out-gridview

#Invoke-restmethod returns contents and excludes headers mostly used with API 

Download files

$param = @{URI="https://download.sysinternals.com/files/SysinternalsSuite.zip";Outfile = "C:\demo\sys.zip" }
Invoke-RestMethod @param

to download large file

$url = "https://download.sysinternals.com/files/SysinternalsSuite.zip"
$target = "C:\Demo\sys1.zip"

Import-Module BitsTransfer
Start-BitsTransfer -Source $url -Destination $target -DisplayName Mysysdownload -Asynchronous



#Using com object

$ie = new-object -ComObject Internetexplorer.application
$ie.Visible = $true
$ie.Navigate("http://microsoft.com")

$ie
$ie.Document




function Get-ComObject {
 
    param(
        [Parameter(Mandatory=$true,
        ParameterSetName='FilterByName')]
        [string]$Filter,
 
        [Parameter(Mandatory=$true,
        ParameterSetName='ListAllComObjects')]
        [switch]$ListAll
    )
 
    $ListofObjects = Get-ChildItem HKLM:\Software\Classes -ErrorAction SilentlyContinue | Where-Object {
        $_.PSChildName -match '^\w+\.\w+$' -and (Test-Path -Path "$($_.PSPath)\CLSID")
    } | Select-Object -ExpandProperty PSChildName
 
    if ($Filter) {
        $ListofObjects | Where-Object {$_ -like $Filter}
    } else {
        $ListofObjects
    }
}







#How to use .svc service interface

$Odata = @{
Uri = 'https://services.odata.org/V3/(S(ibirkug3ccv2v2jxd4y2h3uz))/OData/OData.svc'
MetadataUri = 'https://services.odata.org/V3/(S(ibirkug3ccv2v2jxd4y2h3uz))/OData/OData.svc/$metadata'
OutputModule = 'C:\Temp\DemoModule'
AllowUnSecureConnection = $true
}
Export-odataEndpointProxy @Odata -Force

Import-Module C:\temp\DemoModule -Verbose

Get-Command -Module DemoModule


Get-Person