#!/usr/bin/env bash
# Theme Selection Script for shadowxg_rice

RICE_DIR="$HOME/.config/shadowxg_rice"
THEMES_DIR="$RICE_DIR/assets/themes"
ROFI_THEME="$HOME/.config/rofi/config-themes.rasi"
SET_THEME_SCRIPT="$RICE_DIR/set_theme.sh"
EXTERNAL_FILE="$RICE_DIR/external_themes.txt"

# Check if rofi is already running
if pidof rofi >/dev/null; then
  pkill rofi
fi

# Build arrays for selection
theme_names=()
theme_targets=()
theme_icons=()

# 1. Internal Themes
if [ -d "$THEMES_DIR" ]; then
    for theme_path in "$THEMES_DIR"/*/; do
        if [ -d "$theme_path" ]; then
            name=$(basename "$theme_path")
            theme_names+=("$name")
            theme_targets+=("$name") # set_theme.sh handles internal names
            
            wallpaper="$theme_path/wallpaper.jpg"
            [ -f "$wallpaper" ] || wallpaper="$theme_path/wallpaper.png"
            theme_icons+=("$wallpaper")
        fi
    done
fi

# 2. External Themes
if [ -f "$EXTERNAL_FILE" ]; then
    while IFS= read -r ext_path || [ -n "$ext_path" ]; do
        # Trim whitespace
        ext_path=$(echo "$ext_path" | xargs)
        if [ -d "$ext_path" ]; then
            name=$(basename "$ext_path")
            theme_names+=("$name (Ext)")
            theme_targets+=("$ext_path") # Full path for external
            
            wallpaper="$ext_path/wallpaper.jpg"
            [ -f "$wallpaper" ] || wallpaper="$ext_path/wallpaper.png"
            [ -f "$wallpaper" ] || wallpaper="/usr/share/backgrounds/default.png"
            theme_icons+=("$wallpaper")
        fi
    done < "$EXTERNAL_FILE"
fi

# Function to list themes for Rofi
menu() {
  for i in "${!theme_names[@]}"; do
    printf "%s\x00icon\x1f%s\n" "${theme_names[$i]}" "${theme_icons[$i]}"
  done
}

# Rofi command - using '-format i' to get the numeric index
rofi_command="rofi -i -show -dmenu -format i -config $ROFI_THEME"

# Run Rofi and get selection index
index=$(menu | $rofi_command)

if [[ -n "$index" ]]; then
    target="${theme_targets[$index]}"
    display_name="${theme_names[$index]}"

    echo "Selected Index: $index"
    echo "Applying Theme: $target"
    
    "$SET_THEME_SCRIPT" "$target"
    notify-send "Theme Applied" "Switched to theme: $display_name" -i "$HOME/.config/swaync/icons/theme.png"
else
    echo "No theme selected."
fi
