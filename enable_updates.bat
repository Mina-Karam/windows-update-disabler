:: Author: Mina Karam
:: Purpose: Re-enable Windows auto updates and undo all changes by 'disable updates.bat'
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

:: Enable update-related services
:: Set the startup type of each service to its default value
sc config wuauserv start= auto
sc config UsoSvc start= auto
sc config uhssvc start= delayed-auto

:: Restore renamed DLL files
:: Loop through each DLL file, take ownership, grant permissions, rename it back, and restore ownership
for %%i in (WaaSMedicSvc, wuaueng) do (
    :: Check if the backup file exists
    if exist "C:\Windows\System32\%%i_DISABLED.dll" (
        :: Take ownership of the backup file
        takeown /f C:\Windows\System32\%%i_DISABLED.dll

        :: Grant full control to the current user
        icacls C:\Windows\System32\%%i_DISABLED.dll /grant *S-1-1-0:F

        :: Rename the file back to its original name
        rename C:\Windows\System32\%%i_DISABLED.dll %%i.dll

        :: Restore ownership to the TrustedInstaller service
        icacls C:\Windows\System32\%%i.dll /setowner "NT SERVICE\TrustedInstaller"

        :: Remove full control from the current user
        icacls C:\Windows\System32\%%i.dll /remove *S-1-1-0
    ) else (
        echo Backup file not found: C:\Windows\System32\%%i_DISABLED.dll
    )
)

:: Update registry to re-enable Windows Update
:: Set the "Start" value of the WaaSMedicSvc service to 3 (Automatic)
reg add "HKLM\SYSTEM\CurrentControlSet\Services\WaaSMedicSvc" /v Start /t REG_DWORD /d 3 /f

:: Set the "FailureActions" value of the WaaSMedicSvc service to its default value
reg add "HKLM\SYSTEM\CurrentControlSet\Services\WaaSMedicSvc" /v FailureActions /t REG_BINARY /d 840300000000000000000000030000001400000001000000c0d4010001000000e09304000000000000000000 /f

:: Delete the "NoAutoUpdate" registry value to re-enable automatic updates
reg delete "HKLM\Software\Policies\Microsoft\Windows\WindowsUpdate\AU" /v "NoAutoUpdate" /f

:: Enable all update-related scheduled tasks
:: Use PowerShell to enable scheduled tasks related to Windows Update
powershell -command "Get-ScheduledTask -TaskPath '\Microsoft\Windows\InstallService\*' | Enable-ScheduledTask; Get-ScheduledTask -TaskPath '\Microsoft\Windows\UpdateOrchestrator\*' | Enable-ScheduledTask; Get-ScheduledTask -TaskPath '\Microsoft\Windows\UpdateAssistant\*' | Enable-ScheduledTask; Get-ScheduledTask -TaskPath '\Microsoft\Windows\WaaSMedic\*' | Enable-ScheduledTask; Get-ScheduledTask -TaskPath '\Microsoft\Windows\WindowsUpdate\*' | Enable-ScheduledTask; Get-ScheduledTask -TaskPath '\Microsoft\WindowsUpdate\*' | Enable-ScheduledTask"

:: Notify the user that the script has finished
echo Finished
