# check if has administrator privileges
If (0)
{
If (-NOT ([Security.Principal.WindowsPrincipal] [Security.Principal.WindowsIdentity]::GetCurrent()).IsInRole(`
	[Security.Principal.WindowsBuiltInRole] “Administrator”))
{
	Write-Warning “You do not have Administrator rights to run this script!`nPlease re-run this script as an Administrator!”
	Read-Host "Press Enter to continue"
	Break
}
}
Else
{
#requires -version 4.0
#requires –runasadministrator
}

Write-Host "Hello, world"
Read-Host "Press Enter to continue"
