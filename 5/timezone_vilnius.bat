rem it is more cleaner way than modify the block of "HKEY_LOCAL_MACHINE\SYSTEM\CurrentControlSet\Control\TimeZoneInformation"
%windir%\system32\tzutil /s "FLE Standard Time"
if %errorlevel% neq 0 pause
