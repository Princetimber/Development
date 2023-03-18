Function New-Password {
  [cmdletbinding()]
  Param (
    [Parameter(Mandatory=$false)]
    [Int]$MinimumPasswordLength = 8,
    [Parameter(Mandatory=$false)]
    [Int]$MaximumPasswordLength = 27,
    [Parameter(Mandatory=$false)]
    [Int]$MinimumNumberOfNonAlphanumericCharacters = 5,
    [Parameter(Mandatory=$false)]
    [switch]$ConvertToSecureString
  )
  Add-Type -AssemblyName 'System.Web'
  $Length = Get-Random -Minimum $MinimumPasswordLength -Maximum $MaximumPasswordLength
  $Password = [System.Web.Security.Membership]::GeneratePassword($Length, $MinimumNumberOfNonAlphanumericCharacters)
  if ($converttosecurestring.IsPresent) {
    ConvertTo-SecureString -String $Password -AsPlainText -Force
  }else {
    $Password
  }
}