# ✨ ShadowXG Hyprland Glassy (v3.2)

A premium, highly-customizable, and "glassy" Hyprland layout designed for a seamless, one-click experience. This repository contains the complete "Universal Rice Setup" with automated installation, uninstallation, and a curated library of high-quality anime themes.

![Theme Preview](./shadowxg_rice/assets/themes/Gojo/wallpaper.jpg)

## 🖼️ Premium Theme Gallery

Experience the premium glassy aesthetic with our curated themes. Each theme comes with its own matching Fastfetch logo, notification background, and Wallust color palette.

| **Gojo Satoru** | **Jinhsi (WuWa)** | **Muichiro Tokito** |
| :---: | :---: | :---: |
| ![Gojo](./shadowxg_rice/assets/screenshots/theme1.jpg) | ![Jinhsi](./shadowxg_rice/assets/screenshots/theme2.png) | ![Muichiro](./shadowxg_rice/assets/screenshots/theme3.png) |
| **Dark Samurai** | **Shadow Dragon** | **Stealth Glass** |
| ![Samurai](./shadowxg_rice/assets/screenshots/theme4.png) | ![Dragon](./shadowxg_rice/assets/screenshots/theme5.png) | ![Stealth](./shadowxg_rice/assets/screenshots/theme6.png) |

> [!TIP]
> Press `SUPER + T` to open the graphical theme selector and switch between all **45+ unique themes** instantly!

---

## 📦 Core Features

- **🚀 One-Click Setup**: Automated installer that handles dependencies, path resolution, and system configuration.
- **🎨 45+ Curated Themes**: High-resolution anime wallpapers (Gojo, Naruto, Sasuke, Shorekeeper, etc.) with matching assets.
- **🎥 Live Wallpaper Engine**: Native support for animated desktop backgrounds using `mpvpaper`.
- **📟 Dynamic Fastfetch**: Terminal logo automatically "picks the address" of your theme's image and updates in real-time.
- **🔔 Integrated Notifications**: SwayNC backgrounds and icons perfectly synced with your active theme.
- **🪟 Glass Aesthetics**: Pre-configured Kitty terminal with frosted-glass blur and premium syntax highlighting.
- **🛡️ Safe & Portable**: Uses absolute path resolution with `${HOME}` expansion. No more hardcoded paths!
- **🔙 Easy Restore**: A dedicated `uninstall_rice.sh` script to revert all changes and restore your previous config.

---

## ⚡ Quick Start

### 1. Installation
Run the following command in your terminal to begin the setup. The installer will guide you and create a backup of your existing configurations.

```bash
git clone https://github.com/MangalNathYadav/ShadowXG_Hyprland_Glassy.git
cd ShadowXG_Hyprland_Glassy/shadowxg_rice
bash one-click-setup.sh
```

### 2. Usage
- **Switch Theme**: `SUPER + T` (Opens Rofi menu with previews).
- **Reload System**: All settings apply instantly!
- **Custom Wallpapers**: Check the [Theme Management Guide](./shadowxg_rice/README.md#🧩-custom-theme-guide) to add your own images.

---

## 🛠️ Uninstallation & Backup

We respect your workspace. During installation, your original configs are automatically backed up to:
`~/.config/shadowxg_rice_backup`

To completely revert the rice and restore your original setup, simply run:
```bash
bash ~/uninstall_rice.sh
```

---

## 📦 Requirements
- **OS**: Arch Linux (Recommended)
- **Wayland Environment**: Hyprland
- **Core Tools**: `swww`, `wallust`, `fastfetch`, `rofi-wayland`, `swaync`, `kitty`.
- **Optional**: `mpvpaper` (For Live Wallpapers - Installer will attempt to install this via `yay`/`paru`).

---

## 🙏 Credits
Developed with ❤️ by **ShadowXG**. 
If you like this rice, please consider giving a ⭐ to the repository!
