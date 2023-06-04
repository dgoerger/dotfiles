Start-Process powershell -Verb runAs -Args "defrag c: /u /v /x; sdelete -z c:; shutdown /s"
