:: Author: Mina Karam
:: Purpose: Restore renamed services and re-enable the Windows Update Service
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

:: Restore renamed DLL files
:: Loop through each DLL file, take ownership, grant permissions, rename it back, and restore ownership
for %%i in (wuaueng) do (
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
)

:: Re-enable the Windows Update Service
:: Set the startup type of the wuauserv service to "auto" (Automatic)
sc config wuauserv start= auto

:: Notify the user
echo Enabled Windows Update Service
