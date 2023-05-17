<#
.SYNOPSIS
  This function will add a file to a drive, if the file already exists it will not be overwritten.
.DESCRIPTION
  This function will add a file to a drive, if the file already exists it will not be overwritten.
  If the file already exists and the Hidden switch is used, the file will be hidden.
  If the file does not exist and the Hidden switch is used, the file will be created and hidden.
.PARAMETER FileName
  The name of the file to be created.
.PARAMETER FilePath
  The path to the directory where the file will be created.
.PARAMETER Hidden
  This switch will hide the file if it already exists or create a hidden file if it does not exist.
.NOTES
  Information or caveats about the function e.g. 'This function is not supported in Linux'
.LINK
  Specify a URI to a help page, this will show when Get-Help -Online is used.
.EXAMPLE
  Add-FiletoDrive -FileName "test.txt" -FilePath "C:\Temp"
  This will create a file called test.txt in the C:\Temp directory.
.EXAMPLE
  Add-FiletoDrive -FileName "test.txt" -FilePath "C:\Temp" -Hidden
  This will create a file called test.txt in the C:\Temp directory and hide it.
#>

function Add-FiletoDrive {
  [CmdletBinding()]
  Param(
    [Parameter(Mandatory = $true, Position = 0, ValueFromPipeline = $true, ValueFromPipelineByPropertyName = $true)][ValidateNotNullOrEmpty()][string]$FileName,
    [Parameter(Mandatory = $true, Position = 1, ValueFromPipeline = $true, ValueFromPipelineByPropertyName = $true)][ValidateNotNullOrEmpty()][string]$FilePath,
    [Parameter(Mandatory = $false, Position = 2, ValueFromPipeline = $true, ValueFromPipelineByPropertyName = $true)][switch]$Hidden
  )
  if ([string]::IsNullOrEmpty($FileName)) { throw "FileName cannot be null or empty" }
  if ([string]::IsNullOrEmpty($FilePath)) { throw "FilePath cannot be null or empty" }
  if (-not(Test-Path -Path (Join-Path -Path $FilePath -ChildPath $FileName))) {
    New-Item -Path $FilePath -Name $FileName -ItemType File -Force
  }
  elseIf ($Hidden.IsPresent -and (Test-Path -Path (Join-Path -Path $FilePath -ChildPath $FileName))) {
    Set-ItemProperty -Path (Join-Path -Path $FilePath -ChildPath $FileName) -Name "Attributes" -Value "Hidden"
  }
  elseIf ($Hidden.IsPresent) {
    New-Item -Path $FilePath -Name $FileName -ItemType File | ForEach-Object { $_.Attributes = "Hidden" }
  }
}