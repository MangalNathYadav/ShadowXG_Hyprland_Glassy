#!/bin/bash
# shadowxg_rice - Uninstaller & Configuration Restorer (v3.0)

RED='\033[0;31m'
GREEN='\033[0;32m'
BLUE='\033[0;34m'
CYAN='\033[0;36m'
NC='\033[0m'

BACKUP_DIR="$HOME/.config/shadowxg_rice_backup"
RICE_DIR="$HOME/.config/shadowxg_rice"

echo -e "${RED}========================================${NC}"
echo -e "${RED}    UNINSTALLING SHADOWXG RICE   ${NC}"
echo -e "${RED}========================================${NC}"

if [ ! -d "$BACKUP_DIR" ]; then
    echo -e "${RED}[!] Error: Backup directory not found at $BACKUP_DIR${NC}"
    echo -e "${RED}The uninstaller cannot restore your original configs safely.${NC}"
    read -p "Do you want to continue with cleanup only? (y/n): " confirm
    if [[ ! "$confirm" =~ ^[Yy]$ ]]; then
        exit 1
    fi
else
    echo -e "${CYAN}[*] Restoring original configurations from backup...${NC}"
    
    # Restore directories
    for dir in waybar swaync fastfetch kitty rofi; do
        if [ -d "$BACKUP_DIR/$dir" ]; then
            echo -e "${BLUE}  -> Restoring ~/.config/$dir...${NC}"
            rm -rf "$HOME/.config/$dir"
            cp -rf "$BACKUP_DIR/$dir" "$HOME/.config/"
        fi
    done
fi

echo -e "${CYAN}[*] Cleaning up rice management files...${NC}"
rm -f ~/set_theme.sh
rm -f ~/ThemeSelect.sh
rm -f ~/uninstall_rice.sh
rm -rf "$RICE_DIR"
rm -f "$HOME/.config/rofi/config-themes.rasi"

# Restore Keybinds
KEYBINDS_FILE="$HOME/.config/hypr/configs/Keybinds.conf"
[ -f "$KEYBINDS_FILE" ] || KEYBINDS_FILE="$HOME/.config/hypr/hyprland.conf"

if [ -f "$KEYBINDS_FILE" ]; then
    echo -e "${CYAN}[*] Reverting keybindings in $KEYBINDS_FILE...${NC}"
    sed -i '/ThemeSelect.sh/d' "$KEYBINDS_FILE"
fi

# Reload
echo -e "${BLUE}[*] Reloading Waybar...${NC}"
killall waybar 2>/dev/null; waybar & disown
swaync-client -rs 2>/dev/null

echo -e "${GREEN}========================================${NC}"
echo -e "${GREEN}  UNINSTALL COMPLETE - SYSTEM RESTORED  ${NC}"
echo -e "${RED}  Wait for Waybar to restart...${NC}"
echo -e "${GREEN}========================================${NC}"
