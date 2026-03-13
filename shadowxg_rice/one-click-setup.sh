#!/bin/bash
# ShadowXG Glass Rice - Universal One Click Setup (v3.2)
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"

RED='\033[0;31m'
GREEN='\033[0;32m'
BLUE='\033[0;34m'
CYAN='\033[0;36m'
NC='\033[0m'

echo -e "${BLUE}========================================${NC}"
echo -e "${GREEN}    SHADOWXG GLASS RICE SETUP   ${NC}"
echo -e "${BLUE}========================================${NC}"

# Check Dependencies
echo -e "${CYAN}[*] Checking dependencies...${NC}"
DEPS=("swww" "wallust" "fastfetch" "rofi" "swaync" "kitty")
MISSING_DEPS=()

for dep in "${DEPS[@]}"; do
    if ! command -v "$dep" >/dev/null 2>&1; then
        MISSING_DEPS+=("$dep")
    fi
done

if [ ${#MISSING_DEPS[@]} -ne 0 ]; then
    echo -e "${RED}[!] Warning: Missing core dependencies: ${MISSING_DEPS[*]}${NC}"
    echo -e "${RED}Please install them for the rice to function correctly.${NC}"
fi

# Live Wallpaper Support Check
if ! command -v mpvpaper >/dev/null 2>&1; then
    echo -e "${BLUE}[i] Note: 'mpvpaper' is not installed.${NC}"
    echo -e "${CYAN}    Install it (e.g., 'yay -S mpvpaper') to enable Live Wallpapers!${NC}"
fi

# Backup existing configs to a consistent location
TIMESTAMP=$(date +%Y%m%d_%H%M%S)
BACKUP_DIR="$HOME/.config/shadowxg_rice_backup"
mkdir -p "$BACKUP_DIR"
echo -e "${BLUE}[*] Backing up current configs to $BACKUP_DIR...${NC}"

# Internal backup for the uninstaller to use
for dir in waybar swaync fastfetch kitty rofi; do
    if [ -d "$HOME/.config/$dir" ] && [ ! -L "$HOME/.config/$dir" ]; then
        # Only backup if it's not already a symlink from our rice
        cp -rf "$HOME/.config/$dir" "$BACKUP_DIR/" 2>/dev/null
    fi
done

# Deploy shadowxg_rice core files
echo -e "${BLUE}[*] Deploying shadowxg_rice core files...${NC}"
RICE_CONF_DIR="$HOME/.config/shadowxg_rice"
mkdir -p "$RICE_CONF_DIR" || { echo -e "${RED}[!] Failed to create $RICE_CONF_DIR${NC}"; exit 1; }
# Clear existing assets to avoid theme accumulation from duplicate/old folders
rm -rf "$RICE_CONF_DIR/assets"
cp -rf "$SCRIPT_DIR/assets" "$RICE_CONF_DIR/"
cp -f "$SCRIPT_DIR/set_theme.sh" "$RICE_CONF_DIR/"
cp -f "$SCRIPT_DIR/ThemeSelect.sh" "$RICE_CONF_DIR/"
cp -f "$SCRIPT_DIR/uninstall_rice.sh" "$RICE_CONF_DIR/"
cp -f "$SCRIPT_DIR/config-themes.rasi" "$RICE_CONF_DIR/"
chmod +x "$RICE_CONF_DIR/"*.sh
touch "$RICE_CONF_DIR/external_themes.txt" # Create theme registration file

# Deploy Rofi configs
echo -e "${CYAN}[*] Deploying Rofi theme configs...${NC}"
mkdir -p ~/.config/rofi
cp -f "$RICE_CONF_DIR/config-themes.rasi" ~/.config/rofi/config-themes.rasi

# Link scripts to home for convenience
echo -e "${CYAN}[*] Linking management scripts to $HOME...${NC}"
ln -sf "$RICE_CONF_DIR/set_theme.sh" ~/set_theme.sh
ln -sf "$RICE_CONF_DIR/ThemeSelect.sh" ~/ThemeSelect.sh
ln -sf "$RICE_CONF_DIR/uninstall_rice.sh" ~/uninstall_rice.sh
chmod +x "$RICE_CONF_DIR/set_theme.sh" "$RICE_CONF_DIR/ThemeSelect.sh" "$RICE_CONF_DIR/uninstall_rice.sh"

# Handle AUR Dependencies (mpvpaper for Live Wallpapers)
if ! command -v mpvpaper >/dev/null 2>&1; then
    echo -e "${CYAN}[*] mpvpaper not found. Checking for AUR helpers...${NC}"
    if command -v yay >/dev/null 2>&1; then
        echo -e "${BLUE}[*] Installing mpvpaper via yay...${NC}"
        yay -S --noconfirm mpvpaper
    elif command -v paru >/dev/null 2>&1; then
        echo -e "${BLUE}[*] Installing mpvpaper via paru...${NC}"
        paru -S --noconfirm mpvpaper
    else
        echo -e "${RED}[!] No AUR helper found. Please install 'mpvpaper' manually for live wallpaper support.${NC}"
    fi
fi

# Sync other configs (Fastfetch, SwayNC, Kitty)
# Clean target dirs first to avoid remnants from failed previous runs
mkdir -p ~/.config/swaync ~/.config/fastfetch ~/.config/kitty
cp -rf "$SCRIPT_DIR/swaync/"* ~/.config/swaync/ 2>/dev/null
cp -rf "$SCRIPT_DIR/fastfetch/"* ~/.config/fastfetch/ 2>/dev/null
cp -f "$SCRIPT_DIR/kitty/kitty.conf" ~/.config/kitty/kitty.conf 2>/dev/null

# Expand ${HOME} to absolute paths in configs for reliability
echo -e "${CYAN}[*] Optimizing configuration path resolution...${NC}"
REAL_HOME=$(eval echo ~$USER)
for dir in fastfetch swaync waybar kitty; do
    if [ -d "$HOME/.config/$dir" ]; then
        # Only process text-based config files to avoid errors with binary images/icons
        find "$HOME/.config/$dir" -type f \( -name "*.jsonc" -o -name "*.json" -o -name "*.conf" -o -name "*.css" -o -name "*.rasi" \) > /tmp/rice_text_files.txt
        while read -r file; do
            sed -i "s|\${HOME}|$REAL_HOME|g" "$file" 2>/dev/null
            sed -i "s|~|$REAL_HOME|g" "$file" 2>/dev/null
        done < /tmp/rice_text_files.txt
        rm -f /tmp/rice_text_files.txt
    fi
done

# Standardize .zshrc to use the central Fastfetch config for theme sync
if [ -f "$HOME/.zshrc" ]; then
    sed -i 's|fastfetch -c .*|fastfetch -c $HOME/.config/fastfetch/config.jsonc|g' "$HOME/.zshrc"
fi

# Add Keybinding for Theme Selection (SUPER+T)
KEYBINDS_FILE="$HOME/.config/hypr/configs/Keybinds.conf"
[ -f "$KEYBINDS_FILE" ] || KEYBINDS_FILE="$HOME/.config/hypr/hyprland.conf"

if [ -f "$KEYBINDS_FILE" ]; then
    echo -e "${CYAN}[*] Updating keybindings in $KEYBINDS_FILE...${NC}"
    # Remove old binding if it exists and add the new one pointing to the rice config dir
    sed -i '/ThemeSelect.sh/d' "$KEYBINDS_FILE"
    echo 'bindd = $mainMod, T, Theme selection menu, exec, ~/.config/shadowxg_rice/ThemeSelect.sh' >> "$KEYBINDS_FILE"
fi

# Apply default theme (Muichiro_Tokito)
echo -e "${CYAN}[*] Applying default Muichiro_Tokito theme...${NC}"
"$RICE_CONF_DIR/set_theme.sh" Muichiro_Tokito || "$RICE_CONF_DIR/set_theme.sh" 1

# Reload Services
echo -e "${BLUE}[*] Reloading services...${NC}"
killall waybar 2>/dev/null
waybar >/dev/null 2>&1 & disown
swaync-client -rs >/dev/null 2>&1
hyprctl reload >/dev/null 2>&1

echo -e "${GREEN}========================================${NC}"
echo -e "${GREEN}  RICE APPLIED SUCCESSFULLY! (v3.2) ${NC}"
echo -e "${BLUE}========================================${NC}"
