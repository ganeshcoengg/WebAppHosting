$securePassword = Read-Host "Enter Password" -AsSecureString `
     | ConvertFrom-SecureString | Out-File D:\OFFICEBOXINSTALLATION\Script\pass.txt

Set-ItemProperty "D:\OFFICEBOXINSTALLATION\Script\pass.txt" -Name IsReadOnly -Value true
