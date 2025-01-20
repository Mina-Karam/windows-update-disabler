:: Author: Mina Karam
:: Purpose: Completely disable Windows Update
:: Requirements: PsExec is required to get system privileges - it should be in this directory

:: Elevate to administrator if not already running as admin
if not "%1"=="admin" (
    powershell start -verb runas '%0' admin
    exit /b
)

:: Elevate to system privileges using PsExec if not already running as system
if not "%2"=="system" (
    powershell . '%~dp0\PsExec.exe' /accepteula -i -s -d '%0' admin system
    exit /b
)

:: Disable update-related services
:: Loop through each service and stop it, disable it, and configure it to not restart on failure
for %%i in (wuauserv, UsoSvc, uhssvc, WaaSMedicSvc) do (
    echo Disabling service: %%i
    net stop %%i
    sc config %%i start= disabled
    sc failure %%i reset= 0 actions= ""
)

:: Rename critical DLL files to disable update functionality
:: Loop through each DLL file, take ownership, grant permissions, rename it, and restore ownership
for %%i in (WaaSMedicSvc, wuaueng) do (
    echo Renaming DLL file: %%i.dll
    :: Check if the file exists
    if exist "C:\Windows\System32\%%i.dll" (
        :: Take ownership of the file
        takeown /f C:\Windows\System32\%%i.dll

        :: Grant full control to the current user
        icacls C:\Windows\System32\%%i.dll /grant *S-1-1-0:F

        :: Rename the file to disable it (append "_DISABLED" to the filename)
        rename C:\Windows\System32\%%i.dll %%i_DISABLED.dll

        :: Restore ownership to the TrustedInstaller service
        icacls C:\Windows\System32\%%i_DISABLED.dll /setowner "NT SERVICE\TrustedInstaller"

        :: Remove full control from the current user
        icacls C:\Windows\System32\%%i_DISABLED.dll /remove *S-1-1-0
    ) else (
        echo File not found: C:\Windows\System32\%%i.dll
    )
)

:: Update registry to disable Windows Update
:: Set the "Start" value of the WaaSMedicSvc service to 4 (Disabled)
echo Updating registry: Disabling WaaSMedicSvc
reg add "HKLM\SYSTEM\CurrentControlSet\Services\WaaSMedicSvc" /v Start /t REG_DWORD /d 4 /f

:: Set the "FailureActions" value of the WaaSMedicSvc service to prevent it from restarting on failure
echo Updating registry: Setting FailureActions for WaaSMedicSvc
reg add "HKLM\SYSTEM\CurrentControlSet\Services\WaaSMedicSvc" /v FailureActions /t REG_BINARY /d 000000000000000000000000030000001400000000000000c0d4010000000000e09304000000000000000000 /f

:: Set the "NoAutoUpdate" value to 1 to disable automatic updates
echo Updating registry: Disabling automatic updates
reg add "HKLM\Software\Policies\Microsoft\Windows\WindowsUpdate\AU" /v NoAutoUpdate /t REG_DWORD /d 1 /f

:: Delete downloaded update files
echo Deleting downloaded update files
erase /f /s /q c:\windows\softwaredistribution\*.*
rmdir /s /q c:\windows\softwaredistribution

:: Disable all update-related scheduled tasks
echo Disabling update-related scheduled tasks
powershell -command "Get-ScheduledTask -TaskPath '\Microsoft\Windows\InstallService\*' | Disable-ScheduledTask; Get-ScheduledTask -TaskPath '\Microsoft\Windows\UpdateOrchestrator\*' | Disable-ScheduledTask; Get-ScheduledTask -TaskPath '\Microsoft\Windows\UpdateAssistant\*' | Disable-ScheduledTask; Get-ScheduledTask -TaskPath '\Microsoft\Windows\WaaSMedic\*' | Disable-ScheduledTask; Get-ScheduledTask -TaskPath '\Microsoft\Windows\WindowsUpdate\*' | Disable-ScheduledTask; Get-ScheduledTask -TaskPath '\Microsoft\WindowsUpdate\*' | Disable-ScheduledTask"

:: Notify the user that the script has finished
echo Finished
