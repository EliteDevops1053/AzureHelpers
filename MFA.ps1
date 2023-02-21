# Install-Module -Name MSOnline
Connect-MsolService
$Results=@()
$users = Get-MsolUser -All
foreach ($user in $users) {
    $Reg = ($user.StrongAuthenticationMethods | Where-Object { $_.IsDefault -eq "True" }).MethodType

    if (!($reg)) { $Reg = "Disabled" }

    $Output = [PSCustomObject]@{
        UserName  = $user.UserPrincipalName
        RegMethod = $reg
    }
    $Results += $Output
}
$Results



$Outlook = New-Object -ComObject Outlook.Application
$date = Get-Date -Format g
$Mail = $Outlook.CreateItem(0)
$Mail.to = ""
$Mail.Cc = ""
$Mail.Subject = "Weekly report for MFA"
$Mail.Htmlbody = $Results
Try
{

    $Mail.Send()
    Write-Host "Mail Sent Successfully"

}
Catch
{
    Write-Host "File Not Attached Successfully, Please Try Again"

    #Exit
}
