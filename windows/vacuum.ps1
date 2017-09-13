Start-Process powershell -Verb runAs -ArgumentList "Start-Process cleanmgr.exe /sagerun:1 -NoNewWindow -Wait; sdelete.exe -z; shutdown /s"
