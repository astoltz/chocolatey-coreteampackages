﻿$ErrorActionPreference = 'Stop'

# Check if Sourcetree standard (with Squirrel installer) is installed 
[array] $key = Get-UninstallRegistryKey "sourcetree" | Where-Object { -Not ($_.WindowsInstaller) }
if ($key.Count -eq 1) {
  Write-Warning "Found installation of standard version of Sourcetree."
  Write-Warning "This package will install the enterprise version of Sourcetree."
  Write-Warning "Both applications can be installed side-by-side. Settings won't be migrated from the existing installation."
  Write-Host "Would you like to uninstall existing installation of Sourcetree?"
  $uninstallDefaultValue = 'n'
  $uninstallValue = (Read-Host "[Y]es  [N]o  (default is '$uninstallDefaultValue'): ").ToLower()
  if ($uninstallValue -eq "") {
    $uninstallValue = $uninstallDefaultValue
  }
  while("y","n" -notcontains $uninstallValue )
  {
    Write-Host "Invalid entry"
    $uninstallValue = (Read-Host "[Y]es  [N]o  (default is '$uninstallDefaultValue'): ").ToLower()
    if ($uninstallValue -eq "") {
      $uninstallValue = $uninstallDefaultValue
    }
  }

  if ($uninstallValue -eq "y") {
    $uninstallPath = $key[0].UninstallString.Replace('--uninstall', '').Replace('"', "")
    Write-Host "Uninstalling $uninstallPath"
    $packageArgs = @{
      packageName            = "sourcetree"
      silentArgs             = "--uninstall"
      fileType               = 'EXE'
      validExitCodes         = @(0)
      file                   = $uninstallPath
    }
    Uninstall-ChocolateyPackage @packageArgs
  }
}
elseif ($key.Count -gt 1) {
    Write-Warning "Found $($key.Count) matches for existing Sourcetree installations."
    Write-Warning "To prevent accidental data loss, no programs can be uninstalled."
    Write-Warning "Please alert package maintainer the following keys were matched:"
    $key | ForEach-Object {Write-Warning "- $($_.DisplayName)"}
}

# Install Sourcetree Enterprise
$packageArgs = @{
  packageName   = $env:ChocolateyPackageName
  softwareName  = 'Sourcetree*'
  fileType      = 'msi'
  silentArgs    = "/qn /norestart ACCEPTEULA=1 /l*v `"$env:TEMP\$env:ChocolateyPackageName.$env:ChocolateyPackageVersion.log`""
  validExitCodes= @(0,1641,3010)
  url           = 'https://downloads.atlassian.com/software/sourcetree/windows/ga/SourcetreeEnterpriseSetup_2.5.5.msi'
  checksum      = '2fb9c8676259f8d74acd50e6069bc93c2ca7c3e9305341fa6e0571df0d7d74e9'
  checksumType  = 'sha256'
  url64bit      = ''
  checksum64    = ''
  checksumType64= 'sha256'
}

Install-ChocolateyPackage @packageArgs
