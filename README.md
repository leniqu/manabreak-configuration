# 🌌 Manabreak Quickshell Configuration

My personal **Quickshell** configuration tailored for **Gentoo Linux** running the **Hyprland** compositor. 
The entire desktop shell and UI elements are written completely in **QML**.

## ✨ Features & Structure
* 📊 `shell.qml` — The core setup containing the main top bar component.
* ⚓ `dock.qml` — Minimalist dock component for application management.
* 🚀 `launcher_bottom.qml` & `launcher/` — Fast, accessible application runner.
* 🧩 `components/` — Modular layout including:
  * `Clock.qml` & `Weather.qml` — Time, date, and weather widgets.
  * `Wifi.qml` — Network status.
  * `Workspaces.qml` — Hyprland workspace switcher.
  * `SysActions.qml` — Power menu (shutdown, reboot, logout).
  * `Theme.qml` — Centralized color schemes and styles.

## 🛠️ Requirements
Ensure you have the following packages installed on your Gentoo system:
* `quickshell` (along with required Qt/QML dependencies)
* `Hyprland` WM

## 🚀 Installation & Usage

1. Clone this repository directly into your Quickshell configuration path:
   ```bash
   mkdir -p ~/.config/quickshell
   git clone https://github.com ~/.config/quickshell
   ```

2. Run the shell configuration to test it:
   ```bash
   quickshell --config ~/.config/quickshell
   ```

## 📄 License
This project is open-source and available under the MIT License.
