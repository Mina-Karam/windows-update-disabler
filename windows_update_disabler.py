import customtkinter as ctk
from tkinter import messagebox
import subprocess
import os
import sys
import logging

# Set up logging
logging.basicConfig(
    filename="windows_update_disabler.log",  # Log file name
    level=logging.INFO,  # Log level (INFO, DEBUG, WARNING, ERROR, CRITICAL)
    format="%(asctime)s - %(levelname)s - %(message)s",  # Log format
)

# Set CustomTkinter theme and appearance
ctk.set_appearance_mode("System")  # "System", "Dark", or "Light"
ctk.set_default_color_theme("blue")  # "blue", "green", "dark-blue", etc.

# Function to get the path to the bundled batch scripts
def get_script_path(script_name):
    if getattr(sys, 'frozen', False):
        # Running in a PyInstaller bundle
        base_path = sys._MEIPASS
    else:
        # Running in a normal Python environment
        base_path = os.path.dirname(os.path.abspath(__file__))
    return os.path.join(base_path, script_name)

# Paths to your batch scripts
DISABLE_UPDATES_SCRIPT = get_script_path("disable_updates.bat")
ENABLE_UPDATES_SCRIPT = get_script_path("enable_updates.bat")
USE_UPDATE_SERVICE_SCRIPT = get_script_path("use_update_service.bat")

# Function to run a batch script and check for errors
def run_script(script_path):
    if os.path.exists(script_path):
        try:
            # Run the script and capture the output
            startupinfo = subprocess.STARTUPINFO()
            startupinfo.dwFlags |= subprocess.STARTF_USESHOWWINDOW
            startupinfo.wShowWindow = subprocess.SW_HIDE
            
            result = subprocess.run(
                [script_path],
                shell=True,
                check=True,
                stdout=subprocess.PIPE,
                stderr=subprocess.PIPE,
                text=True,
                startupinfo=startupinfo,
                creationflags=subprocess.CREATE_NO_WINDOW
            )
            # Log the script execution
            logging.info(f"Script executed successfully: {script_path}")
            logging.info(f"Output: {result.stdout}")
            return True, result.stdout
        except subprocess.CalledProcessError as e:
            # Log the error
            logging.error(f"Script failed: {script_path}")
            logging.error(f"Error: {e.stderr}")
            return False, e.stderr
    else:
        # Log that the script was not found
        logging.error(f"Script not found: {script_path}")
        return False, f"Script not found: {script_path}"

# Function to disable updates
def handle_disable_updates():
    logging.info("Attempting to disable updates...")
    success, output = run_script(DISABLE_UPDATES_SCRIPT)
    if success:
        logging.info("Updates disabled successfully.")
        # messagebox.showinfo("Success", "Windows Updates Disabled\nAutomatic Windows updates have been turned off.")
    else:
        logging.error(f"Failed to disable updates: {output}")
        messagebox.showerror("Error", f"Failed to disable updates:\n{output}")

# Function to enable updates
def handle_enable_updates():
    logging.info("Attempting to enable updates...")
    success, output = run_script(ENABLE_UPDATES_SCRIPT)
    if success:
        logging.info("Updates enabled successfully.")
        # messagebox.showinfo("Success", "Windows Updates Enabled\nAutomatic Windows updates have been turned on.")
    else:
        logging.error(f"Failed to enable updates: {output}")
        messagebox.showerror("Error", f"Failed to enable updates:\n{output}")

# Function to use the update service
def handle_use_update_service():
    logging.info("Attempting to use the update service...")
    success, output = run_script(USE_UPDATE_SERVICE_SCRIPT)
    if success:
        logging.info("Update service used successfully.")
        # messagebox.showinfo("Success", "Checking for Windows Updates\nWindows Update service is now checking for new updates.")
    else:
        logging.error(f"Failed to use update service: {output}")
        messagebox.showerror("Error", f"Failed to use update service:\n{output}")

# Create the main window
root = ctk.CTk()
root.title("Windows Update Disabler")
root.geometry("400x300")

# Center the window on the screen
window_width = 400
window_height = 300
screen_width = root.winfo_screenwidth()
screen_height = root.winfo_screenheight()
x = (screen_width - window_width) // 2
y = (screen_height - window_height) // 2
root.geometry(f"{window_width}x{window_height}+{x}+{y}")

# Create and place the widgets
label = ctk.CTkLabel(root, text="Windows Update Disabler", font=("Arial", 20))
label.pack(pady=20)

description = ctk.CTkLabel(root, text="Control Windows Update Services", font=("Arial", 14))
description.pack(pady=10)

# Disable Updates Button
disable_button = ctk.CTkButton(
    root,
    text="Disable Updates",
    command=handle_disable_updates,
    fg_color="red",
    hover_color="darkred",
    font=("Arial", 12)
)
disable_button.pack(pady=10, fill="x", padx=20)

# Enable Updates Button
enable_button = ctk.CTkButton(
    root,
    text="Enable Updates",
    command=handle_enable_updates,
    fg_color="green",
    hover_color="darkgreen",
    font=("Arial", 12)
)
enable_button.pack(pady=10, fill="x", padx=20)

# Use Update Service Button
use_service_button = ctk.CTkButton(
    root,
    text="Use Update Service",
    command=handle_use_update_service,
    fg_color="gray",
    hover_color="darkgray",
    font=("Arial", 12)
)
use_service_button.pack(pady=10, fill="x", padx=20)

# Run the CustomTkinter event loop
root.mainloop()