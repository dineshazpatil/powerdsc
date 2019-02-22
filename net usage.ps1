#COM usage

function invoke-standby
{
    add-type -AssemblyName System.windows.forms
    [System.Windows.Forms.Application]::SetSuspendState(0,0,0) | out-null

}

invoke-standby

function test-ipaddress($value)
{
    ($value -as [System.Net.IPAddress]) -ne $null -and ($value -as [Int] -eq $null)

}
test-ipaddress -value 10.1.1.1




[System.Enum]::GetNames([System.DayOfWeek])

[System.TimeZoneInfo]::Local

[System.Media.SystemSounds]::Beep.Play()
[System.Media.SystemSounds]::Asterisk.Play()
[System.Media.SystemSounds]::Exclamation.Play()
[System.Media.SystemSounds]::hand.Play()

[Datetime]::DaysInMonth(2009,3)

[datetime]::IsLeapYear(2009)

DNS Lookup

[System.Net.Dns]::GetHostByName("www.google.com")

[Security.Principal.WindowsIdentity]::GetCurrent().User

function test-admin 
{
    $identity = [Security.Principal.WindowsIdentity]::GetCurrent()
    $user = New-Object Security.Principal.windowsPrincipal $identity
    $user.IsInRole([Security.Principal.WindowsBuiltInRole]::Administrator)

}


test-admin


[System.Math]::Sqrt(36)


$DateTime = New-Object System.DateTime  -ArgumentList 2015, 10, 10

[System.IO.File]::ReadAllText

[System.IO.Compression]

[system.console] | Get-Member -Static -MemberType method | Format-Table name,definition -AutoSize

[System.Console]::Beep()

[System.Console]::Clear()
[console]::WindowHeight
[console]::BackgroundColor
[console]::ForegroundColor

[console]::WindowHeight = 14

[console]::ForegroundColor = “yellow”

[console]::Title = "HI this is Dinesh"

Add-Type -AssemblyName System.speech
$talker = New-Object System.Speech.Synthesis.SpeechSynthesizer



$talker.speak("hello there")

$talker.GetInstalledVoices() | gm

$talker.GetInstalledVoices().voiceinfo

$talker.GetInstalledVoices().voiceinfo.name

$talker.SelectVoice("Microsoft Zira Desktop")


$talker.SetOutputToWaveFile(".\test.wav")
$talker.Speak("Would you like to play a game?")
$talker.Dispose()









add-type -AssemblyName System.Drawing
$mybrush = New-Object Drawing.SolidBrush green
$mypen = new-object Drawing.Pen black
$mypen | gm
$mybrush | gm

$mypen.color = "red"
$mypen.width = 10







$form = New-Object Windows.Forms.Form
$formGraphics = $form.createGraphics()

$form.add_paint({

$formGraphics.DrawLine($mypen, 10,10,190,190)
$formGraphics.FillEllipse($mybrush, 20,20,180,180)


})


$form.ShowDialog()

$ButtonType = [System.Windows.MessageBoxButton]::OK
$MessageIcon = [System.Windows.MessageBoxImage]::Warning
$MessageBody = "Your Computer is going to shutdown in 10 Minutes after patch update"
$MessageTitle = "Computer Restart"
 
$Result =[System.Windows.MessageBox]::Show($MessageBody,$MessageTitle,$ButtonType,$MessageIcon)
  
Write-Host "Your choice is $Result"


$version = new-object -typename System.version -Argumentlist 1.2.3.4
$version















https://docs.microsoft.com/en-us/powershell/scripting/samples/creating-a-custom-input-box?view=powershell-6

http://techgenix.com/building-powershell-gui-part8/







