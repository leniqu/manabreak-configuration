# 🌌 Manabreak Quickshell Configuration

My personal **Quickshell** configuration tailored for **Gentoo Linux**, **Arch Linux**, and **Debian** running the **Hyprland** compositor. The entire desktop shell and UI elements are written completely in **QML**.

## ✨ Features & Structure
* 📊 `shell.qml` — The core setup containing the main top bar component.
* ⚓ `dock.qml` — Minimalist dock component for application management.
* 🚀 `launcher_bottom.qml` & `launcher/` — Fast, accessible application runner.
* 🧩 `components/` — Modular layouts including:
  * `Clock.qml` & `Weather.qml` — Time, date, and weather widgets.
  * `Wifi.qml` — Network status.
  * `Workspaces.qml` — Hyprland workspace switcher.
  * `SysActions.qml` — Power menu (shutdown, reboot, logout).
  * `Theme.qml` — Centralized color schemes and styles.

---

## 🚀 Automated Installation

The easiest way to install this configuration and all its required packages is to use the automated script. It will auto-detect your distribution (**Gentoo**, **Arch**, or **Debian**) and install everything for you via your system's package manager.

Run the following command in your terminal:

```bash
curl -sSL https://raw.githubusercontent.com/leniqu/manabreak-configuration/main/install.sh | bash
```

---

## 🛠️ Requirements & Manual Installation

If you prefer to review everything and install dependencies manually, make sure your system has the following components:

### Core Dependencies
* `quickshell` (along with required Qt6/QML dependencies)
* `Hyprland` (Wayland compositor)
* `glib` (system path & process handling)

### External Apps & Fonts
* `swaync` (notification daemon)
* `kitty` (default terminal used by the launcher)
* `networkmanager` (network backend for the Wi-Fi widget)
* `pywal` (dynamic color theme generator)
* `waypaper` (GUI wallpaper utility)
* **Rubik Font** (primary text font)
* **Nerd Fonts** (required for system icons)

### Manual Installation Steps:
1. Clone this repository directly inside it:
   ```bash
   git clone https://github.com/leniqu/manabreak-configuration.git ~/.config/quickshell
   ```
2. Test the setup manually:
   ```bash
   quickshell --config ~/.config/quickshell
   ```

---

## ⚙️ Autostart

To launch this shell automatically every time you log into Hyprland, add the following line to your `~/.config/hypr/hyprland.conf`:

```ini
exec-once = quickshell --config ~/.config/quickshell
```

## 📄 License
This project is open-source and available under the MIT License.

