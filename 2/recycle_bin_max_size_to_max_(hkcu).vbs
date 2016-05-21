' the script base is gotten from https://azizhussainitblog.wordpress.com/2015/05/21/script-to-programmatically-set-specific-recycle-bin-size-limit-in-windows/
Const HKCU = &H80000001

strComputer = "."
Set objReg=GetObject("winmgmts:{impersonationLevel=impersonate}!\\" & strComputer & "\root\default:StdRegProv")

' Enumerate all subkeys of \volume key and stores in array
strKeyPath1 = "Software\Microsoft\Windows\CurrentVersion\Explorer\BitBucket\Volume"
objReg.EnumKey HKCU, strKeyPath1, arrSubKeys
 
For Each subkey In arrSubKeys
'	Wscript.Echo subkey
	strKeyPath2 = strKeyPath1 & "\" & subkey
'	Wscript.Echo "Full path is: " & strKeyPath2
'	objReg.GetDWORDValue HKCU, strKeyPath2, "MaxCapacity", var
'	Wscript.Echo "Value is: " & var
' *original script
'	objReg.SetDWORDValue HKCU, strKeyPath2, "MaxCapacity", "40"
' set to max
'val = -1
'val = 0xffffffff
'val = &Hffffffff
'val = CInt(-1)
'val = CInt(&Hffffffff&)
'val = &Hffffffff&
' hmmm, this is the max value which I can fit this way into 32 bit container to use later in 'SetDWORDValue'
'val = &Hffff0fff&
'val = &H00000000&
'val = val - 1
val = CLng(-1)
' "type mismatch"
'	objReg.SetDWORDValue HKCU, strKeyPath2, "MaxCapacity", "-1"
'	objReg.SetDWORDValue HKCU, strKeyPath2, "MaxCapacity", "&Hffffffff"
	objReg.SetDWORDValue HKCU, strKeyPath2, "MaxCapacity", val
Next
