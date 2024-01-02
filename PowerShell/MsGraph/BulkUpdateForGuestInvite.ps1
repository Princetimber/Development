# Import list of users using CSV file
# CSV should have the following column FirstName, Surname, CurrentEmail, NewEmail, SendInvite(Yes/No), Message
# SendInvite is optional, if not specified, it will default to Y
# Check if user has accepted previous invite, if so, reset redemption status and resend invite.
# If user has not accepted previous invite, update user details and send invite.
# If user has not accepted previous invite and SendInvite is N, update user details only.
# If user has not accepted previous invite and SendInvite is Y, update user details and send invite.
$credential = Get-Credential -UserName "ibrahim.Olaleye@membergateway.onmicrosoft.com" -Message "Enter your Azure AD credentials"
Connect-AzureAD -Credential $credential
$scope = @("user.read.all", "user.invite.all", "directory.readwrite.all")
Connect-MgGraph -Scopes $scope
$user = Import-Csv -Path "C:\temp\users.csv" -Delimiter "," -Encoding UTF8 -Header FirstName, Surname, CurrentEmail, NewEmail, SendInvite, Message
$states = $user | ForEach-Object { Get-AzureADUser -Filter "mail eq '$($_.CurrentEmail)' and userType eq 'Guest' and UserState eq 'PendingAcceptance'" }
$Object = $User | ForEach-Object { Get-MgUser -Filter "mail eq '$($_.CurrentEmail)' and UserType eq 'Guest'" }
foreach ($u in $User) {
  foreach ($state in $states) {
    foreach ($obj in $Object) {
      if ( ($obj.Mail -eq $u.CurrentEmail) -and ($state -EQ 'Accepted') ) {
        $bodyParameter = @{
          "id"           = $obj.Id
          "mailNickname" = $u.NewEmail.Split("@")[0]
          "displayName"  = $u.FirstName + " " + $u.Surname
          "mail"         = $u.NewEmail
        }
        $body = $bodyParameter | ConvertTo-Json
        $uri = "https://graph.microsoft.com/v1.0/users/$Id"
        Write-Information "Updating user $mail to $u.NewEmail"
        Invoke-MgGraphRequest -Method PATCH -Uri $uri -Body $body
        $bodyParameter = @{
          "invitedUserId"           = $obj.Id
          "invitedUserEmailAddress" = $u.NewEmail
          "inviteRedirectUrl"       = "https://myaccess.microsoft.com/@MemberGateway.onmicrosoft.com#/access-packages"
          "sendInvitationMessage"   = $true
          "invitedUserDisplayName"  = $u.FirstName + " " + $u.Surname
          "invitedUserMessageInfo"  = @{
            "customizedMessageBody" = $u.Message
          }
          "resetRedemption"         = $true
        }
        $body = $bodyParameter | ConvertTo-Json
        $uri = "https://graph.microsoft.com/v1.0/invitations"
        Write-Information "Resending invite to $u.NewEmail"
        Invoke-MgGraphRequest -Method POST -Uri $uri -Body $body
      }
      ElseIf (($obj.Mail -eq $u.CurrentEmail) -and ($u.SendInvite -eq "Yes") -and ($state -ne 'Accepted')) {
        $bodyParameter = @{
          "id"           = $obj.Id
          "mailNickname" = $u.NewEmail.Split("@")[0]
          "displayName"  = $u.FirstName + " " + $u.Surname
          "mail"         = $u.NewEmail
        }
        $body = $bodyParameter | ConvertTo-Json
        $uri = "https://graph.microsoft.com/v1.0/users/$Id"
        Write-Information "Updating user $mail to $u.NewEmail"
        Invoke-MgGraphRequest -Method PATCH -Uri $uri -Body $body
        $bodyParameter = @{
          "invitedUserEmailAddress" = $u.NewEmail
          "inviteRedirectUrl"       = "https://myaccess.microsoft.com/@MemberGateway.onmicrosoft.com#/access-packages"
          "sendInvitationMessage"   = $true
          "invitedUserDisplayName"  = $u.FirstName + " " + $u.Surname
          "invitedUserMessageInfo"  = @{
            "customizedMessageBody" = $u.Message
          }
          "invitedUserType"         = "Guest"
        }
        $body = $bodyParameter | ConvertTo-Json
        $uri = "https://graph.microsoft.com/v1.0/invitations"
        Write-Information "Sending invite to $u.NewEmail"
        Invoke-MgGraphRequest -Method POST -Uri $uri -Body $body
      }
    }
  }
}
