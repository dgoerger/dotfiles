Start-Process powershell -Verb runAs -ArgumentList "choco upgrade all -y; Get-WUInstall -MicrosoftUpdate -AcceptAll -AutoReboot"
