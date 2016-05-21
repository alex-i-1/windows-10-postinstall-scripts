# 2016-04-15 - 2016-04-15
# by Alexander Ilyin
# set permissions for a file of an antivirus so that it couldn't be executed
# (the purpose is to rid off popping up adds)
# I am running this script from Task Scheduler, setting the user to SYSTEM; it though sometimes starts as ordinary user, and I will not attempt to find why

# redirect output to a file (since from the SYSTEM account we will not see anything displayed)
# *don't call 'Out-File c:\log.txt' with that
#Start-Transcript -path C:\log.txt -append
Start-Transcript -path C:\log.txt

#whoami /priv
#whoami /priv > C:\log_1.txt

#.\Set-LHSTokenPrivilege.ps1 -Privilege SeRestorePrivilege
#.\Set-LHSTokenPrivilege.ps1 -Privilege SeSecurityPrivilege
. .\Set-LHSTokenPrivilege.ps1
Set-LHSTokenPrivilege -Privilege SeRestorePrivilege
Set-LHSTokenPrivilege -Privilege SeSecurityPrivilege
Set-LHSTokenPrivilege -Privilege SeTakeOwnershipPrivilege
Set-LHSTokenPrivilege -Privilege SeBackupPrivilege
#Break

#whoami /priv
#whoami /priv >> C:\log_1.txt
#Break

# check if now has administrator privileges
# it doesn't matter anymore - we need SYSTEM privileges
##requires -version 4.0
##requires –runasadministrator

#$exe = "C:\Program Files (x86)\Avira\Antivirus\ipmgui.exe"
#$exe = ".\_test.txt"
#$exe = "C:\Users\u1\Desktop\reg\av\_test.txt"
# oook, and at this point I have noticed that the folder "C:\Program Files (x86)\Avira\Antivirus", different from other folders, is not accessible for changes at all :)
$exe = "C:\Program Files (x86)\Avira\Antivirus\_test.txt"

# what privileges are necessary for this script to work
# we need "SYSTEM" privileges to do that
# can't create user with name "system" or "SYSTEM" - the returned error is - "The account already exists."
#$required_privileges = "User"
#$required_privileges = "Administrator"
$required_privileges = "SYSTEM"
#$required_privileges = "Administrators"
# for which user a new security entry will be added
#$target_user = "u1"
#$target_user = "Administrator"
$target_user = "Administrators"
#$target_user = "SYSTEM"

# part of Msoft's 'Assert-True()'
# note that in this script this function is not used for a program errors, but to design an unexpected situations
function A
{
	[CmdletBinding()]
	Param
	(
#The value to assert.
		[Parameter(Mandatory = $true, ValueFromPipeline = $false, Position = 0)]
		[AllowNull()]
		[AllowEmptyCollection()]
		[System.Object]
		$Value
	)

	$ErrorActionPreference = [System.Management.Automation.ActionPreference]::Stop
	if (-not $PSBoundParameters.ContainsKey('Verbose'))
	{
		$VerbosePreference = $PSCmdlet.GetVariableValue('VerbosePreference') -as [System.Management.Automation.ActionPreference]
	}
	if (-not $PSBoundParameters.ContainsKey('Debug'))
	{
		$DebugPreference = $PSCmdlet.GetVariableValue('DebugPreference') -as [System.Management.Automation.ActionPreference]
	}

	$fail = -not (($Value -is [System.Boolean]) -and $Value)

	if ($VerbosePreference -or $fail)
	{
		$message = 'Assertion {0}: {1}, file {2}, line {3}' -f
		@(
			$(if ($fail) {'failed'} else {'passed'}),
			$MyInvocation.Line.Trim(),
			$MyInvocation.ScriptName,
			$MyInvocation.ScriptLineNumber
		)

		Write-Verbose -Message $message

		if ($fail)
		{
			Write-Debug -Message $message
			throw New-Object -TypeName 'System.Exception' -ArgumentList @($message)
		}
	}
}

# take ownership of a file
Function Set-Ownership ($file)
{
# The "takeown.exe" file should already exist in Win7 - Win10 
	try
	{
		& takeown /f $file
#		Write-Output "---"
	}
	catch
	{
		Write-Output "Failed to take ownership of $file"
	}
}

# change permission of a file
Function Set-Permissions ($file)
{
# disable execute access for the Administrators
if (0)
{
	$ACL = Get-Acl $file
	$AccessRule = New-Object System.Security.AccessControl.FileSystemAccessRule ("Everyone", "FullControl", "Allow")
#	$AccessRule = New-Object System.Security.AccessControl.FileSystemAccessRule ("Administrators", "Modify", "Allow")
# wow, requires no space here before '('
	$ACL.SetAccessRule($AccessRule)
	$ACL | Set-Acl $file
}
if (1)
{
#	$fi = New-Object System.IO.FileInfo($exe)
	$fi = [System.IO.FileInfo]$exe
	$security = $fi.GetAccessControl()
    $security.SetAccessRuleProtection(0, 1)
#    $Rights = [System.Security.AccessControl.FileSystemRights]"ListDirectory, ReadData, WriteData, CreateFiles, CreateDirectories, AppendData, ReadExtendedAttributes, WriteExtendedAttributes, Traverse, ExecuteFile, DeleteSubdirectoriesAndFiles, ReadAttributes, WriteAttributes, Write, Delete, ReadPermissions, Read, ReadAndExecute, Modify, ChangePermissions, TakeOwnership, Synchronize, FullControl"
#    $Rights = [System.Security.AccessControl.FileSystemRights]"Read,Write"
#    $Rights = [System.Security.AccessControl.FileSystemRights]"Read"
    $Rights = [System.Security.AccessControl.FileSystemRights]"ExecuteFile"
# oook, so adding an "Allow" rule doesn't let us to disable some specific rights; must add "Deny" rule (which will be between present nonchangeable "Allow" rules) to achieve that
# note that this replaces the (possibly) existing rule, but doesn't touch the initial pack of three "Allow" rules which are for "SYSTEM", "Administrators" and "<some user>" users
# well, when adding this rule for "Administrator", the exe is not accessible for execution for both - for Administrator and for a user, but when doing it with SYSTEM account, it isn't available for execution only for Administrator, but the owner user can run it
# and for "SYSTEM" "Read" "Deny", both the user and Administrator can read the file
# if set for a user "Read" "Deny", both the user and Administrator can not read the file
# if set for "Administrator" "Read" "Deny", both the user and Administrator can read the file
# if set for "Administrators" "Read" "Deny", both the user and Administrator can not read the file
# if set for "SYSTEM" "Read" "Deny", both the user and Administrator can read the file
#	$AccessRule = New-Object System.Security.AccessControl.FileSystemAccessRule ($target_user, $Rights, "Allow")
	$AccessRule = New-Object System.Security.AccessControl.FileSystemAccessRule ($target_user, $Rights, "Deny")
    $security.SetAccessRule($AccessRule)
    $fi.SetAccessControl($security)
}
}

if (1)
{
$names = [Environment]::UserName + ", " + [Environment]::UserDomainName + ", " + [Environment]::MachineName
$names = $env:USERNAME
$names = [System.Security.Principal.WindowsIdentity]::GetCurrent().Name
$names = $(Get-WMIObject -class Win32_ComputerSystem | select username).username
#$names = Get-Credential UserTo.RunAs
Write-Output "user :  $names"
# well, looks like it works this way; at least it correctly reports 1 or 0 whenever or not this is a requested Administrator privilege while being a user
#Write-Output ([Security.Principal.WindowsPrincipal][Security.Principal.WindowsIdentity]::GetCurrent()).IsInRole([Security.Principal.WindowsBuiltInRole]$required_privileges)
#Read-Host "Press Enter to continue"
$has_privileges = ([Security.Principal.WindowsPrincipal][Security.Principal.WindowsIdentity]::GetCurrent()).IsInRole([Security.Principal.WindowsBuiltInRole]$required_privileges)
Write-Output "has privileges for $required_privileges :  $has_privileges"
#Write-Output "current user :  $names"
#Break
}
# bad - it is always the name of the currently active desktop's user
# but gives "SYSTEM" when scheduling this script for SYSTEM account
$user_name = [Environment]::UserName
Write-Output "user is `"$user_name`""
if (0)
{
# bad - it is always the name of the currently active desktop's user
$user_name = $env:USERNAME
Write-Output "user is `"$user_name`""
# bad - it is always the name of the currently active desktop's user
# but gives "NT AUTHORITY\SYSTEM" when scheduling this script for SYSTEM account
$user_name = [System.Security.Principal.WindowsIdentity]::GetCurrent().Name
Write-Output "user is `"$user_name`""
# bad - it is always the name of the currently active desktop's user
$user_name = $(Get-WMIObject -class Win32_ComputerSystem | select username).username
Write-Output "user is `"$user_name`""
}
if ($user_name -ne $required_privileges)
{
    Write-Output "user is `"$user_name`" and not `"$required_privileges`""
#    Read-Host "Press Enter to continue"
#    Break
}

$is_file_present = Test-Path $exe;

if (! $is_file_present)
{
	Write-Output "target executable `"$exe`" is not present"
	Read-Host "Press Enter to continue"
	Break
}

if (0)
{
    $item = Get-Item -LiteralPath $exe
	Write-Output $item.PSIsContainer
#	Write-Output $item.Parent
	Write-Output $item.Directory
	Write-Output "---"
    Break
}

## well, no need to take ownership to Administrator - it already is
## (and if try to, the result returned by "takeown.exe" is "ERROR: Access is denied.")
# the current ownership of this file is "Administrators"
#Set-Ownership $exe
Set-Permissions $exe

Write-Output "done"
#Read-Host "Press Enter to continue"
#Break

