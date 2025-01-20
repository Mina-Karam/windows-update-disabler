# Windows Update Disabler

⚡ A simple, one-click solution to permanently disable automatic Windows updates without leaving background processes running.

> [!WARNING]  
> **Before running this script, ensure that Windows is fully updated and not currently installing or downloading updates!** Interrupting an update process could corrupt your Windows installation.

---

## How to Use

### Quick Start

1. **Download:**
   - Download the latest release from the [Releases](https://github.com/Mina-Karam/windows-update-disabler/releases) page
   - Extract the ZIP file to a location of your choice

2. **Check for Active Updates:**
   - Go to **Settings > Update & Security > Windows Update** and ensure no updates are being installed or downloaded.

3. **Run the Application:**
   - Launch `windows_update_disabler.exe`
   - Click "Disable Updates" to disable automatic Windows updates
   - Click "Enable Updates" to re-enable automatic updates
   - Click "Use Update Service" to temporarily enable the update service

---

## How to Update Manually

Regular updates are essential for security. To update manually:

1. **Enable Updates:**
   - Launch the application and click "Enable Updates"

2. **Install Updates:**
   - Go to **Settings > Update & Security > Windows Update** and install available updates.

3. **Disable Updates Again:**
   - After updating, click "Disable Updates" to disable automatic updates again.

---

## Temporarily Enable the Update Service

Some applications, such as the Microsoft Store, depend on the Windows Update service. To temporarily enable the service:

1. **Enable Update Service:**
   - Click "Use Update Service" to re-enable the Windows Update Service.

2. **Use Dependent Applications:**
   - You can now use applications that require the update service.

3. **Disable Update Service Again:**
   - Once done, click "Disable Updates" to disable the update service again.

---

## What the Application Does

The application disables automatic updates by performing the following actions:

1. **Disables Windows Update Services:**
   - **Windows Update Service (wuauserv):** The core service responsible for downloading and installing updates.
   - **Update Orchestrator Service (UsoSvc):** Manages the scheduling of update installations.
   - **Windows Update Medic Service (WaaSMedicSvc):** Repairs the Windows Update service if it becomes corrupted.

2. **Disables Update-Related Scheduled Tasks:**
   - Prevents Windows from running tasks that check for or install updates automatically.

3. **Modifies Registry Settings:**
   - Updates registry keys to disable automatic updates and prevent services from restarting.

4. **Renames Critical DLL Files:**
   - Renames essential DLL files (e.g., `wuaueng.dll`) to prevent the update services from functioning.

5. **Uses PsExec for System-Level Privileges:**
   - Some services and tasks are protected and require system-level privileges to modify. PsExec is used to bypass these restrictions.

---

## Building from Source

To build the executable from source:

1. **Install Requirements:**
   ```bash
   pip install -r requirements.txt
   ```

2. **Build with PyInstaller:**
   ```bash
   pyinstaller --onefile --windowed --add-data "disable_updates.bat;." --add-data "enable_updates.bat;." --add-data "use_update_service.bat;." --add-data "PsExec.exe;." --add-data "LICENSE;." --version-file version.txt --icon=icon.ico windows_update_disabler.py
   ```

3. **Find the Executable:**
   - The built executable will be in the `dist` directory

---

## Technical Details

### **1. Elevate to Admin**
- The application automatically requests administrator privileges when needed.

### **2. Disable Services**
- The application stops and disables the following services:
  - **wuauserv**: Windows Update Service.
  - **UsoSvc**: Update Orchestrator Service.
  - **WaaSMedicSvc**: Windows Update Medic Service.

### **3. Rename DLL Files**
- Critical DLL files are renamed to disable their functionality:
  - Takes ownership of the files
  - Grants necessary permissions
  - Renames the files
  - Restores original ownership

### **4. Modify Registry**
- Registry keys are updated to disable automatic updates
- Service configurations are modified to prevent automatic restarts

### **5. Disable Scheduled Tasks**
- All Windows Update related scheduled tasks are disabled

### **6. User Interface**
- Simple, intuitive interface with three main buttons:
  - Disable Updates
  - Enable Updates
  - Use Update Service

---

## Notes
- The application includes all necessary components (PsExec, batch scripts) in a single executable
- Always ensure your system is fully updated before disabling updates
- The application requires administrator privileges to function properly
