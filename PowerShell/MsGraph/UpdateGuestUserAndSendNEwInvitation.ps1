$scopes = @('User.Read.All', 'User.Invite.All', 'Directory.ReadWrite.All', 'Directory.AccessAsUser.All')
Connect-MgGraph -Scopes $scopes
function Update-GuestUserEmailAndInvitation {
  [CmdletBinding()]
  param(
    [Parameter(Mandatory = $true)][ValidateNotNullOrEmpty()][string]$CurrentEmailAddress,
    [Parameter(Mandatory = $true)][ValidateNotNullOrEmpty()][string]$NewEmailAddress,
    [Parameter(Mandatory = $false)][string]$FirstName,
    [Parameter(Mandatory = $false)][string]$LastName,
    [Parameter(Mandatory = $false)][string]$domain = 'memberGateway.onmicrosoft.com',
    [Parameter(Mandatory = $true)][string]$TenantId
  )
  #validate the current email address
  if ([string]::IsNullOrEmpty($CurrentEmailAddress)) {
    throw "CurrentEmailAddress cannot be null or empty"
  }
  if ([string]::IsNullOrEmpty($NewEmailAddress)) {
    throw "NewEmailAddress cannot be null or empty"
  }
  # validate current guest user email address
  $user = Get-MgUser -Filter "Mail eq '$($CurrentEmailAddress)' and UserType eq 'Guest'"
  if (-not $user) {
    throw "No guest user found with email address $CurrentEmailAddress"
  }
  # validate new guest user email address
  $newUser = Get-MgUser -Filter "Mail eq '$($NewEmailAddress)' and UserType eq 'Guest'"
  if ($newUser) {
    throw "A guest user already exists with email address $NewEmailAddress"
  }
  # update the guest user email address
  $Id = $user.Id
  $userUpdatePayload = @{
    UserId            = $Id
    GivenName         = $FirstName
    Surname           = $LastName
    Mail              = $NewEmailAddress
    mailNickname      = $NewEmailAddress.Split('@')[0]
    userType          = 'Guest'
    displayName       = $FirstName + ' ' + $LastName
    UserPrincipalName = $NewEmailAddress.Replace('@', '_') + "#EXT#@" + $domain
  }
  Update-MgUser @userUpdatePayload
  # get the externalUserState value for guest user
  $externalUserState = $user.ExternalUserState
  # if the guest user has previously accepted the invitation on the current email address, reset the invitation and send a new invitation to the new email address.
  # if the guest user has not accepted the invitation on the current email address, the invitation will be sent to the new email address.
  if ($externalUserState -eq 'Accepted') {
    # send a new invitation
    $invitationPayload = @{
      Id                      = $Id
      InvitedUserEmailAddress = $NewEmailAddress
      InviteRedirectUrl       = 'https://myaccess.microsoft.com/@memberGateway.onmicrosoft.com#/access-packages'
      InviteRedeemUrl         = 'https://myaccess.microsoft.com/@memberGateway.onmicrosoft.com#/access-packages'
      InvitedUserDisplayName  = $FirstName + ' ' + $LastName
      SendInvitationMessage   = $true
      InvitedUserMessageInfo  = @{
        ccRecipients          = @()
        customizedMessageBody = 'Your access to Fountview has been updated. Please accept the invitation using the link below.'
        messageLanguage       = 'en-US'
        messageTemplate       = 'Invitation'
        additionalData        = @{}
      }
      ResetRedemption         = $true
    }
    New-MgInvitation $invitationPayload
  }
  elseif ($externalUserState -eq 'PendingAcceptance') {
    #remove exisitng user and send a new invitation
    Remove-MgUser -UserId $Id | Out-Null
    # send a new invitation
    $invitationPayload = @{
      InvtedUser              = $FirstName + ' ' + $LastName
      InvitedUserEmailAddress = $NewEmailAddress
      InvitedUserDisplayName  = $FirstName + ' ' + $LastName
      InviteRedirectUrl       = 'https://myaccess.microsoft.com/@memberGateway.onmicrosoft.com#/access-packages'
      SendInvitationMessage   = $true
      InvitedUserMessageInfo  = @{
        customizedMessageBody = 'Your access to Member Gateway has been updated. Please accept the invitation using the link below.'
        messageLanguage       = 'en-US'
      }
    }
    New-MgInvitation $invitationPayload
  }
}
