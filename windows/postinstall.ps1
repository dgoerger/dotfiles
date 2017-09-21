#########################################################
#################^                     ^#################
################ Windows 10 post-install ################
#################.                     .#################
#########################################################
####### regretably not everything is scriptable.. #######
#########################################################

## reduce system resource requirements => this is to be run in a VM, after all
#- My PC -> right-click within window -> System Properties
#  - Performance -> Adjust for best performance
#  - Performance -> Advanced -> Page File -> no page file
#  - Performance -> DEP -> On for ALL
#  - System Protection -> Restore -> turn off
#  - Remote -> disable Remote Assistance
#- System Settings (metro ui)
#  - Apps -> Optional Features -> disable probably everything except the Print to PDF option
#  - OneDrive -> Sync -> disable all
#  - Privacy -> disable nonprivate things
#  - Search -> disable all
#  - Time and language -> set to US Eastern
#- see also:
#  - http://windows.wonderhowto.com/inspiration/everything-you-need-disable-windows-10-0163552/
#
## assume hardware clock is UTC (i.e. UNIX host, we're in a virtual machine)
# ref: https://wiki.archlinux.org/index.php/Time#UTC_in_Windows
#reg add "HKEY_LOCAL_MACHINE\System\CurrentControlSet\Control\TimeZoneInformation" /v RealTimeIsUniversal /d 1 /t REG_DWORD /f
#
## reboot to load in new configuration
#\> shutdown.exe /r

#########################################################
######## now time for actually interesting things #######
#########################################################
############                                  ###########
########### LAUNCH POWERSHELL AS ADMINISTRATOR ##########
############                                  ###########
#########################################################

## permit current user to execute scripts
Set-ExecutionPolicy RemoteSigned -Scope CurrentUser

## stop Windows Search from wasting cycles and space
Set-Service WSearch -StartupType manual

## remove all the metro apps
# ref: https://itvision.altervista.org/why-windows-10-sucks.html
Get-AppXPackage -AllUsers | Remove-AppxPackage

## disable OneDrive
# ref: https://superuser.com/a/1201549
taskkill.exe /F /IM "OneDrive.exe"
%SystemRoot%\SysWOW64\OneDriveSetup.exe /uninstall

## install Chocolatey
iex ((new-object net.webclient).downloadstring('https://chocolatey.org/install.ps1'))

## install misc useful things
choco install -y notepadplusplus sdelete

## optional packages to consider
#choco install -y atom calibre ccleaner firefox gimp github googlechrome keepassx libreoffice sumatrapdf.install vlc winscp zotero
#choco install -y git miktex.install nmap openssh pandoc vim

## QEMU
choco install -y curl
curl.exe -LkO https://www.spice-space.org/download/windows/spice-guest-tools/spice-guest-tools-latest.exe
.\spice-guest-tools-latest.exe

## install Windows Updates powershell module
Install-Module PSWindowsUpdate -AcceptAll
Get-Command -module PSWindowsUpdate -AcceptAll

## let Windows Update install updates for other Microsoft software
# ServiceID verification: https://msdn.microsoft.com/en-us/library/windows/desktop/aa826676(v=vs.85).aspx
Add-WUServiceManager -ServiceID 7971f918-a847-4430-9279-4a52d1efe18d -AcceptAll

## fetch all available updates and reboot if necessary
Get-WUInstall -MicrosoftUpdate -AcceptAll -AutoReboot

#########################################################
###### assume we're fully patched and have rebooted #####
## now we zero the drive so the VMDK can be compressed ##
#########################################################

# launch PowerShell as Administrator, execute:
#\> cleanmgr.exe /sageset:1
#\> # ^ select options for automatic clearing (probably "all")
#\> cleanmgr.exe /sagerun:1; sdelete.exe -z; shutdown /s
# on host system, execute:
#$ qemu-img convert -p -c -f qcow2 -O qcow2 $input "$(date +%Y%m%d)_win10.qcow2"
