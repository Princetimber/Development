<#
.SYNOPSIS
  Generate a random password
.DESCRIPTION
  This function will generate a random password.
  You can specify the length of the password and convert the password to a secure string. The default length of the password is 8.
  The default is not to convert the password to a secure string.
  The password will contain upper and lower case letters, numbers and special characters.
.PARAMETER PasswordLength (Mandatory)
  The length of the password. The default value is 8.
.PARAMETER ConvertToSecureString (Optional)
  Convert the password to a secure string.
.NOTES
  This function is based on ensuring that the password contains upper and lower case letters, numbers and special characters, which are ramdomly generated from a set of characters.
  The passowrd length must be between 8 and 30.
.EXAMPLE
  Generate-Password -PasswordLength 8 -ConvertToSecureString
  This will generate a random password with a length of 8 and convert the password to a secure string.
.EXAMPLE
  Generate-Password -PasswordLength 8
  This will generate a random password with a length of 8.
#>
Function New-Password {
  [cmdletbinding()]
  Param(
    [Parameter(Mandatory = $true, Position = 0, HelpMessage = "Password length", ValueFromPipeline = $true, ValueFromPipelineByPropertyName = $true)][ValidateRange(8, 30)][int]$PasswordLength,
    [Parameter(Mandatory = $false, Position = 1, HelpMessage = "Convert to Secure string", ValueFromPipeline = $true, ValueFromPipelineByPropertyName = $true)][switch]$ConvertToSecureString
  )
  # Validate password length
  if ($PasswordLength -lt 8 -or $PasswordLength -gt 30) {
    throw "Password length must be between 8 and 30."
  }
  # Generate password
  $CharSet = @{
    UpperCase   = (97..122) | ForEach-Object { [char]$_ }
    LowerCase   = (65..90) | ForEach-Object { [char]$_ }
    Numeric     = (48..57) | ForEach-Object { [char]$_ }
    SpecialChar = (33..47) + (58..64) + (91..96) + (123..126) | ForEach-Object { [char]$_ }
  }
  $StringSet = $CharSet.UpperCase + $CharSet.LowerCase + $CharSet.Numeric + $CharSet.SpecialChar
  $Password = -join (Get-Random -InputObject $StringSet -Count $PasswordLength)
  # Convert to secure string
  if ($ConvertToSecureString.IsPresent) {
    ConvertTo-SecureString -String $Password -AsPlainText -Force
  }
  else {
    $Password
  }
}
