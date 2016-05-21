rem check administrator privileges
net session >nul 2>&1
if %errorLevel% neq 0 (
    echo Failure: Administrator privileges are required.
    pause
    exit
)

rem pity there is no way to configure a power scheme without priorly enabling it (although can export an existing one into a file, but the file format is binary)
rem set "High performance" scheme as current
powercfg.exe -setactive 8c5e7fda-e8bf-4a96-9a85-a6e23a8c635c
if %errorlevel% neq 0 pause
powercfg.exe -change -monitor-timeout-ac 30
rem there was some problem in WinXP, so the disk never actually went to sleep
powercfg.exe -change -disk-timeout-ac 60
powercfg.exe -change -standby-timeout-ac 0
powercfg.exe -change -hibernate-timeout-ac 0
rem settings below require administrator privileges
powercfg.exe -hibernate off
rem disable password on wake
powercfg.exe -setacvalueindex 8c5e7fda-e8bf-4a96-9a85-a6e23a8c635c fea3413e-7e05-4911-9a71-700331f1c294 0e796bdb-100d-47d6-a2d5-f7d2daa51f51 0
rem disable power button
powercfg.exe -setacvalueindex 8c5e7fda-e8bf-4a96-9a85-a6e23a8c635c 4f971e89-eebd-4455-a8de-9e59040e7347 7648efa3-dd9c-4e3e-b566-50f929386280 0
rem disable sleep button
powercfg.exe -setacvalueindex 8c5e7fda-e8bf-4a96-9a85-a6e23a8c635c 4f971e89-eebd-4455-a8de-9e59040e7347 96996bc0-ad50-47ec-923b-6f41874dd9eb 0
rem pause
if %errorlevel% neq 0 pause
