# uses parts of script by 2015-08-11 Bob@BobHodges.net, which had purpose to replace Notepad with Notepad++ on Windows 10
# 2016-03-10 - 2016-03-20
# modified by Alexander Ilyin
# now its purpose is to replace Notepad with Notepad2
# more precisely it copies Notepad2 into "Program Files" folder and replaces "Notepad.exe" with a symbolic link, and not with Notepad2 itself
# this is because Notepad2 has a configuration file being at its exe, and we less likely would want to have a mess with few different configuration files

# algo
# *ok, the algo has changed a bit; when it was "C:temp\calc.lnk" all three - "calc", "calc.exe", "calc.lnk" were working, but with "Notepad.exe" this thing somehow doesn't work
# so have to use "Notepad.exe" name instead for the symbolic link (and this perhaps is the correct way, because those ".lnk" files were actually a files, and we shouldn't overtake their names)
# 1) check if Notepad2 is present in "Program Files" folder
# 1.1) if present - silently continue (this is because either we probably already copied it, or otherwise it could be that the user has installed Notepad2 himself; thus we only would bother a user with a question dialog about what to do further, so lets not do it)
# (yet if need to update the folder with its content a user needs to delete the destination folder)
# 1.2) if not present - check for the presense of Notepad2 in our folder
# 1.2.1) if present - copy it
# 1.2.2) if not present - stop and report about it - we could not deal with this situation
# next steps are being performed for every known entry of "Notepad.exe" (them are 3)
# 2) check if entry is present
# 2.1) if entry is present
# 2.1.1) if entry is a symbolic link - change its ownership and permissions (because we don't know who created it) and delete it
# 2.1.2) if entry is a file - change its ownership and permissions and rename this source file to its backup name
# 3) create a symbolic link

# check if now has administrator privileges
#requires -version 4.0
#requires –runasadministrator

# Paths to various required files
#$Notepads = "$($env:systemroot)\Notepad.exe","$($env:systemroot)\System32\Notepad.exe","$($env:systemroot)\SysWOW64\Notepad.exe"
#$Notepad_filename = "Notepad.exe"
$Notepad_filename = "Notepad"
$Notepad_folders = "$($env:systemroot)","$($env:systemroot)\System32","$($env:systemroot)\SysWOW64"
# *no redirector is used anymore
#$Redirector = ".................."
$Folder_name = "Notepad2"
# folder with Notepad2, containing its exe and configuration files
$Notepad2_src = ".\$Folder_name"
$Notepad2_src_exe = "$Notepad2_src\notepad2.exe"
# target folder of Notepad2, where to put it
#$Notepad2_dest = Resolve-Path "$($env:systemdrive)\Program Files (x86)\$Folder_name"
$Notepad2_dest = "$($env:systemdrive)\Program Files (x86)\$Folder_name"
$Notepad2_dest_exe = "$Notepad2_dest\Notepad2.exe"
# Notepad 2 has no DLLs
#$Notepad2DLL = Resolve-Path "$($env:systemdrive)\Program Files*\Notepad++\SciLexer.dll"
# but has a settings file
$Notepad2_dest_ini = "$Notepad2_dest\Notepad2.ini"

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

# Function to take ownership of the notepad files.
Function Set-Ownership ($file)
{
# The "takeown.exe" file should already exist in Win7 - Win10 
	try
	{
		& takeown /f $file
	}
	catch
	{
		Write-Output "Failed to take ownership of $file"
	}
}

# This function gives us permission to change the "notepad.exe" files.
Function Set-Permissions ($file)
{
	$ACL = Get-Acl $file
	$AccessRule = New-Object System.Security.AccessControl.FileSystemAccessRule ("Everyone", "FullControl", "Allow")
# wow, requires no space here before '('
	$ACL.SetAccessRule($AccessRule)
	$ACL | Set-Acl $file
}

# *it returns 1 if both the file ("Notepad.exe") and a symbolic link ("Notepad.lnk") are present simultaneously
function Test-ReparsePoint ([string]$path)
{
	$file = Get-Item $path -Force -ea 0
	return [bool]($file.Attributes -band [IO.FileAttributes]::ReparsePoint)
}

$is_src_file_present = Test-Path $Notepad2_src_exe;
$is_dest_folder_present = Test-Path $Notepad2_dest;

if ($is_dest_folder_present)
{
# do nothing
# we don't ask in this situation
}
else
# the destination folder is not present
{
	if ($is_src_file_present)
	{
# put Notepad2 into "Program Files" folder
		Copy-Item -Path $Notepad2_src -Destination $Notepad2_dest -recurse
	}
	else
	{
		Write-Output "Notepad2 executable is not found"
		Read-Host "Press Enter to continue"
		Break
	}
}

# ensure that target file exists
$is_dest_file_present = Test-Path $Notepad2_dest_exe -PathType Leaf
A ($is_dest_file_present)

# replace-executables:
# Loops through each notepad path.
Foreach ($Notepad_folder in $Notepad_folders)
{
	$Notepad = "$Notepad_folder\$Notepad_filename.exe"
	$Notepad_back = "$Notepad.bak"
	$Notepad_ini = "$Notepad_folder\$Notepad_filename.ini"

	$is_present = Test-Path $Notepad
	if ($is_present)
	{
# should be a file, not a folder
		A (Test-Path $Notepad -PathType Leaf)
		$is_reparse_point = Test-ReparsePoint $Notepad
		if ($is_reparse_point)
# a symbolic link
		{
			Set-Ownership $Notepad
			Set-Permissions $Notepad
# this doesn't delete the target exe even in the case when this symbolic link is named as ".exe" and not as ".lnk"
# not as I heard it would delete the target exe (though I heard it deletes the folder it is pointed to with its content http://kristofmattei.be/2012/12/15/powershell-remove-item-and-symbolic-links/ and http://superuser.com/questions/167076/how-can-i-delete-a-symbolic-link )
			Remove-Item $Notepad
		}
		else
# a file
		{
			$is_backup_present = Test-Path $Notepad_back
			$do_backup = 1
# it might be some other script which made a backup but didn't replace the exe with a symbolic link (we normally don't get into such a left-on-half-way situation)
			if ($is_backup_present)
# we have to ask a user about this situation
			{
				Write-Output "the backup file `"$Notepad_back`" is already present"
				Write-Output "do you want to overwrite it ?"
				do { $answer = Read-Host "Overwrite the backup file / Skip processing this entry / Delete exe and continue create a replacing link" }
				until ("o","s","d" -ccontains $answer)
				switch ($answer)
				{
				"o"
				{
# nothing here; the variable is already set
				}
				"s"
				{
# stop processing 'switch'
					continue
				}
				"d"
				{
					$do_backup = 0
				}
				default
				{
					A(0)
#					ET
				}
				}
# *couldn't 'continue' from inside of a 'switch' statement, so have to do it now
				if ($answer -eq "s")
				{
					continue
				}
			}
			# Takes ownership of the file, then changes the NTFS permissions to allow us to rename it. 
			Set-Ownership $Notepad
			Set-Permissions $Notepad
			if ($do_backup)
			{
				Move-Item -Path $Notepad -Destination $Notepad_back -force
			}
			else
			{
				Remove-Item $Notepad
			}
		}
	}
# remove ".ini" unconditionally, whatever that entry would be
	$is_present = Test-Path $Notepad_ini
	if ($is_present)
	{
		Set-Ownership $Notepad_ini
		Set-Permissions $Notepad_ini
		Remove-Item $Notepad_ini
	}

	$is_present = Test-Path $Notepad
	A (! $is_present)

# create a symbolic link
# well, a symbolic link cannot have a working directory to be set; these were ".lnk" shortcuts which could have one
	$item = New-Item -ItemType SymbolicLink $Notepad -Value $Notepad2_dest_exe
	$item = New-Item -ItemType SymbolicLink $Notepad_ini -Value $Notepad2_dest_ini
}

#Read-Host "Press Enter to continue"
#Break

