rem a crutch to start a powershell script

rem Administrator gets "system32" CWD; lets restore the current one
rem setlocal enableextensions
cd /d "%~dp0"

rem our file name
rem echo %~n0

rem temporarily enable script execution
rem "-Force" is to disable prompts (we get no prompt here, thus no need to use it)
rem powershell -command "& {Set-ExecutionPolicy -Scope LocalMachine Unrestricted -Force}"
rem good, it works, but this process will exit right after execution of this command will end, so this allowance will not be kept for the next command
rem powershell -command "& {Set-ExecutionPolicy -Scope Process Unrestricted}"
rem if %errorlevel% neq 0 pause
rem powershell .\1.ps1
rem if %errorlevel% neq 0 pause
rem powershell -command "Set-ExecutionPolicy -Scope Process Unrestricted"; ".\1.ps1"
powershell -command "Set-ExecutionPolicy -Scope Process Unrestricted"; ".\%~n0.ps1"
if %errorlevel% neq 0 pause
pause
