Function Send-UserInvite {
  [CmdletBinding(DefaultParameterSetName = 'Send', SupportsShouldProcess = $true, ConfirmImpact = 'Medium')]
  param(
    [Parameter(Mandatory = $true, Position = 0, ParameterSetName = 'Send', HelpMessage = 'Required to send an invite')][switch]$Send,
    [Parameter(Mandatory = $true, Position = 1, HelpMessage = 'Email address of the user to invite', ValueFromPipeline = $true, ValueFromPipelineByPropertyName = $true)][string]$EmailAddress,
    [Parameter(Mandatory = $true, Position = 2, HelpMessage = 'First name of the user to invite', ValueFromPipeline = $true, ValueFromPipelineByPropertyName = $true)][string]$FirstName,
    [Parameter(Mandatory = $true, Position = 3, HelpMessage = 'Last name of the user to invite', ValueFromPipeline = $true, ValueFromPipelineByPropertyName = $true)][string]$Surname,
    [Parameter(Mandatory = $false, Position = 4, HelpMessage = 'Optional message to include in the invite')][string]$Message,
    [Parameter(Mandatory = $false, Position = 5, HelpMessage = 'Redirect URL for the invite')][ValidateSet('https://myapps.microsoft.com', 'https://myapplications.microsoft.com')][string]$RedirectUrl
  )
  switch ($PSCmdlet.ParameterSetName) {
    "Send" {
      If ($PSCmdlet.ShouldProcess($EmailAddress, "Send Invite")) {
        $body = @{
          InvitedUserEmailAddress = $EmailAddress
          InviteRedirectUrl       = $RedirectUrl
          InvitedUserDisplayName  = "$FirstName $Surname"
          SendInvitationMessage   = $true
          InvitedUserMessageInfo  = @{
            "customizedMessageBody" = $Message
          }
        }
        $body = $body | ConvertTo-Json
        $uri = "https://graph.microsoft.com/v1.0/invitations"
        $response = Invoke-MgGraphRequest -Method POST -Uri $uri -Body $body
        $response
      }
      elseif ($PSCmdlet.ShouldContinue("Do you want to create a new invite?", "Create Invite")) {
        $body = @{
          InvitedUserEmailAddress = $EmailAddress
          InviteRedirectUrl       = $RedirectUrl
          InvitedUserDisplayName  = "$FirstName $Surname"
          SendInvitationMessage   = $true
          InvitedUserMessageInfo  = @{
            "customizedMessageBody" = $Message
          }
        }
        $body = $body | ConvertTo-Json
        $uri = "https://graph.microsoft.com/v1.0/invitations"
        $response = Invoke-MgGraphRequest -Method POST -Uri $uri -Body $body
        $response
      }
    }
  }
}