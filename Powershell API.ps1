﻿$url = "http://dineshapi.azurewebsites.net/api/Student"



$student = @{
      name='Dinesh patil'
      company='GeneralMills'
      isPresent = "True"
   }
   $body = (ConvertTo-Json $student)
   
   Invoke-RestMethod -Uri $url -Method Post -Body $body -ContentType 'application/json'

$student = @{
      name='basant nayak'
      company='Netmagic'
      isPresent = "True"
   }
   $body = (ConvertTo-Json $student)
   
   Invoke-RestMethod -Uri $url -Method Post -Body $body -ContentType 'application/json'


   $Allstudents = Invoke-RestMethod -Uri $url -Method get

      Invoke-RestMethod -Uri $url -Method get -ContentType 'application/json'
   
      
   $id="dcb2d79be1fd4accabf3d1f93f9a5e80"
   $puturl = "http://dineshapi.azurewebsites.net/api/student/$id"


$updatestudent = @{
      name='Dinesh Patil'
      company='generalmills'
      isPresent = "False"
      isCompleted  = "True"
   } 

   $body = (ConvertTo-Json $updatestudent)
   Invoke-RestMethod -Uri $puturl -Method Put -Body $body -ContentType 'application/json'


 $id="16b7a5fdb0ed44feba2fd661f4f873a0"
   $deleteurl = "http://dineshapi.azurewebsites.net/api/student/$id"
   #$cred = Get-Credential 

   Invoke-RestMethod -Uri $deleteurl -Method Delete -Credential $cred
   
   
   $site = Invoke-WebRequest http://www.bing.com

$site | gm

$site.StatusCode
$site.StatusDescription

#Download files

$param = @{URI="https://download.sysinternals.com/files/SysinternalsSuite.zip";Outfile = "C:\demo\sys.zip" }
Invoke-RestMethod @param

to download large file

$url = "https://download.sysinternals.com/files/SysinternalsSuite.zip"
$target = "C:\Demo\sys1.zip"

Import-Module BitsTransfer
Start-BitsTransfer -Source $url -Destination $target -DisplayName Mysysdownload -Asynchronous



   
   
