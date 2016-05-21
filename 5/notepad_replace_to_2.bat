rem a crutch to start a powershell script

rem Administrator gets "system32" CWD; lets restore the current one
rem setlocal enableextensions
cd /d "%~dp0"

rem temporarily enable script execution
rem "-Force" is to disable prompts (we get no prompt here, thus no need to use it)
powershell -command "Set-ExecutionPolicy -Scope Process Unrestricted"; ".\%~n0.ps1"
if %errorlevel% neq 0 pause
