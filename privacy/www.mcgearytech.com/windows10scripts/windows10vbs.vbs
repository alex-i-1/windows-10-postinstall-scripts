Set WSHShell = CreateObject("WScript.Shell")

' check for admininstrator privileges
'is_admin = 0
'Set objNetwork = CreateObject("Wscript.Network")
'strComputer = objNetwork.ComputerName
'strUser = objNetwork.UserName

'Set objGroup = GetObject("WinNT://" & strComputer & "/Administrators")
'For Each objUser in objGroup.Members
'    If objUser.Name = strUser Then
''        Wscript.Echo strUser & " is a local administrator."
'	is_admin = 1
'    End If
'Next

' I didn't get up to call this; I am checking another way for the moment
'NET FILE 1>NUL 2>NUL
'if '%errorlevel%' == '0' ( goto got_privileges )

'If is_admin = 0 Then
'Wscript.Echo strUser & " is not a local administrator."
'Wscript.Echo "Administrator privileges are required."
'WScript.Quit
'End If

' if there are no args, means UAC elevation is required
If WScript.Arguments.length = 0 Then
Set objShell = CreateObject("Shell.Application")
' rerun us with dummy arg "uac"
objShell.ShellExecute "wscript.exe", Chr(34) & WScript.ScriptFullName & Chr(34) & " uac", "", "runas", 1
WScript.Quit
End If

' not all keys might be present, so we must avoid of error 80070002
On Error Resume Next
'#
'#This script will remove and create new registry entries on your windows 10 PC it is intended only for windows 10
'#Ths script is provided for informational use only please use at your own risk
'#Len McGeary http://www.mcgearytech.com
'#these commands delete all currently created keys for settings we want to change we do this so we can re create the keys as we want them cleanly
'#
'#delete key disable using your machine for sending windows updates to others
'WSHShell.RegDelete "HKLM\SOFTWARE\Microsoft\Windows\CurrentVersion\DeliveryOptimization\Config\DownloadMode"
'#delete disable sending settings to cloud
WSHShell.RegDelete "HKLM\SOFTWARE\Policies\Microsoft\Windows\SettingSync\DisableSettingSync"
'#delete disable syncronizing files to cloud
WSHShell.RegDelete "HKLM\SOFTWARE\Policies\Microsoft\Windows\SettingSync\DisableSettingSyncUserOverride"
'#delete disable ad customization
WSHShell.RegDelete "HKLM\SOFTWARE\Policies\Microsoft\Windows\AdvertisingInfo\DisabledByGroupPolicy"
'#delete disable data collection and sending to MS
WSHShell.RegDelete "HKLM\SOFTWARE\Policies\Microsoft\Windows\DataCollection\AllowTelemetry"
'#delete disable sending files to encrypted drives
WSHShell.RegDelete "HKLM\SOFTWARE\Policies\Microsoft\Windows\EnhancedStorageDevices\TCGSecurityActivationDisabled"
'#delete disable sync files to one drive
WSHShell.RegDelete "HKLM\SOFTWARE\Policies\Microsoft\Windows\OneDrive\DisableFileSyncNGSC"
'#delete disable certificate revocation check
WSHShell.RegDelete "HKLM\SOFTWARE\Policies\Microsoft\Windows\safer\codeidentifiers\authenticodeenabled"
'#delete disable send additional info with error reports
WSHShell.RegDelete "HKLM\SOFTWARE\Policies\Microsoft\Windows\Windows Error Reporting\DontSendAdditionalData"
'#delete disable cortana in windows search
WSHShell.RegDelete "HKLM\SOFTWARE\Policies\Microsoft\Windows\Windows Search\AllowCortana"
'#delete disable web search in search bar
WSHShell.RegDelete "HKLM\SOFTWARE\Policies\Microsoft\Windows\Windows Search\DisableWebSearch"
'#delete disable seach web when searching pc
WSHShell.RegDelete "HKLM\SOFTWARE\Policies\Microsoft\Windows\Windows Search\ConnectedSearchUseWeb"
'#delete disable search indexing
WSHShell.RegDelete "HKLM\SOFTWARE\Policies\Microsoft\Windows\Windows Search\AllowIndexingEncryptedStoresOrItems"
'#delete disable location based info in searches
WSHShell.RegDelete "HKLM\SOFTWARE\Policies\Microsoft\Windows\Windows Search\AllowSearchToUseLocation"
'#delete disable language detection
WSHShell.RegDelete "HKLM\SOFTWARE\Policies\Microsoft\Windows\Windows Search\AlwaysUseAutoLangDetection"
'Wscript.Echo "keys deletion completed"
'#
'#
'#Now We will write our new registry entries
'#
'#
' any of these lines should not report any error
On Error GoTo 0
'#write disable using your machine for sending windows updates to others
WSHShell.RegWrite "HKLM\SOFTWARE\Microsoft\Windows\CurrentVersion\DeliveryOptimization\Config\DownloadMode", 0,"REG_DWORD"
'#write disable sending settings to cloud
WSHShell.RegWrite "HKLM\SOFTWARE\Policies\Microsoft\Windows\SettingSync\DisableSettingSync", 2,"REG_DWORD"
'#write disable syncronizing files to cloud
WSHShell.RegWrite "HKLM\SOFTWARE\Policies\Microsoft\Windows\SettingSync\DisableSettingSyncUserOverride", 1,"REG_DWORD"
'#write disable ad customization
WSHShell.RegWrite "HKLM\SOFTWARE\Policies\Microsoft\Windows\AdvertisingInfo\DisabledByGroupPolicy", 1,"REG_DWORD"
'#write disable data collection and sending to MS
WSHShell.RegWrite "HKLM\SOFTWARE\Policies\Microsoft\Windows\DataCollection", 0,"REG_DWORD"
'#write disable sending files to encrypted drives
WSHShell.RegWrite "HKLM\SOFTWARE\Policies\Microsoft\Windows\EnhancedStorageDevices\TCGSecurityActivationDisabled", 0,"REG_DWORD"
'#write disable sync files to one drive
WSHShell.RegWrite "HKLM\SOFTWARE\Policies\Microsoft\Windows\OneDrive\DisableFileSyncNGSC", 1,"REG_DWORD"
'#write disable certificate revocation check
WSHShell.RegWrite "HKLM\SOFTWARE\Policies\Microsoft\Windows\safer\codeidentifiers\authenticodeenabled", 0,"REG_DWORD"
'#write disable send additional info with error reports
WSHShell.RegWrite "HKLM\SOFTWARE\Policies\Microsoft\Windows\Windows Error Reporting\DontSendAdditionalData", 1,"REG_DWORD"
'#write disable cortana in windows search
WSHShell.RegWrite "HKLM\SOFTWARE\Policies\Microsoft\Windows\Windows Search\AllowCortana", 0,"REG_DWORD"
'#write disable web search in search bar
WSHShell.RegWrite "HKLM\SOFTWARE\Policies\Microsoft\Windows\Windows Search\DisableWebSearch", 1,"REG_DWORD"
'#write disable seach web when searching pc
WSHShell.RegWrite "HKLM\SOFTWARE\Policies\Microsoft\Windows\Windows Search\ConnectedSearchUseWeb", 0,"REG_DWORD"
'#write disable search indexing
WSHShell.RegWrite "HKLM\SOFTWARE\Policies\Microsoft\Windows\Windows Search\AllowIndexingEncryptedStoresOrItems", 0,"REG_DWORD"
'#write disable location based info in searches
WSHShell.RegWrite "HKLM\SOFTWARE\Policies\Microsoft\Windows\Windows Search\AllowSearchToUseLocation", 0,"REG_DWORD"
'#write disable language detection
WSHShell.RegWrite "HKLM\SOFTWARE\Policies\Microsoft\Windows\Windows Search\AlwaysUseAutoLangDetection", 0,"REG_DWORD"
'Wscript.Echo "keys write is completed"
'#
'#Thats it you are all done
'#
Set WSHShell = Nothing
