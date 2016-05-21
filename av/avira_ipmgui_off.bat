rem a crutch to start a powershell script

rem Administrator gets "system32" CWD; lets restore the current one
rem setlocal enableextensions
cd /d "%~dp0"

rem it likely is relevant at starting a new processes, that an error "Security warning" "Run only scripts that you trust." appears
rem lets bypass it
rem powershell -command "Set-ExecutionPolicy -Scope Process Bypass"; ".\Set-LHSTokenPrivilege.ps1 -Privilege SeRestorePrivilege"
if %errorlevel% neq 0 pause
rem powershell -command "Set-ExecutionPolicy -Scope Process Bypass"; ".\Set-LHSTokenPrivilege.ps1 -Privilege SeSecurityPrivilege"
if %errorlevel% neq 0 pause

rem temporarily enable script execution
rem "-Force" is to disable prompts (we get no prompt here, thus no need to use it)
rem powershell -command "Set-ExecutionPolicy -Scope Process Unrestricted"; ".\%~n0.ps1"
powershell -command "Set-ExecutionPolicy -Scope Process Bypass"; ".\%~n0.ps1"
if %errorlevel% neq 0 pause
pause
