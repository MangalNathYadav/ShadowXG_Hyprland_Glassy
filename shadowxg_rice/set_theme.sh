# set_theme.sh - Switch between shadowxg_rice themes (v3.0)
RICE_DIR="$HOME/.config/shadowxg_rice"
REPO_DIR="$RICE_DIR"
FF_DIR="$HOME/.config/fastfetch"

# Handle help flags
if [[ "$1" == "--help" ]] || [[ "$1" == "-h" ]]; then
    echo "🎨 ShadowXG Rice Theme Manager"
    echo "Usage: ./set_theme.sh [ThemeName or Index]"
    echo ""
    echo "Available themes:"
    ls -1 "$REPO_DIR/assets/themes" | nl
    exit 0
fi

# Handle input (Number or Name or Path)
INPUT="$1"
if [[ "$INPUT" =~ ^/ ]]; then
    # Direct path provided
    THEME_DIR="$INPUT"
    THEME_NAME=$(basename "$INPUT")
elif [[ "$INPUT" =~ ^[0-9]+$ ]]; then
    # Legacy: find theme by index (sorted alphabetically)
    THEME_NAME=$(ls -1 "$REPO_DIR/assets/themes" | sed -n "${INPUT}p")
    THEME_DIR="$REPO_DIR/assets/themes/$THEME_NAME"
else
    THEME_NAME="$INPUT"
    THEME_DIR="$REPO_DIR/assets/themes/$THEME_NAME"
fi

# Check if theme exists
if [ ! -d "$THEME_DIR" ] || [ -z "$THEME_NAME" ]; then
    echo "❌ Error: Theme '$THEME_NAME' not found or path '$THEME_DIR' is invalid."
    echo "Run './set_theme.sh --help' to see all available themes."
    exit 1
fi

echo "Applying Theme: $THEME_NAME..."

# 1. Wallpaper & Colors
WP="$THEME_DIR/wallpaper.jpg"
[ -f "$WP" ] || WP="$THEME_DIR/wallpaper.png"

# Handle Live Wallpapers (.mp4 exists)
LIVE_WP="$THEME_DIR/wallpaper.mp4"
if [ -f "$LIVE_WP" ]; then
    echo "🎥 Live Wallpaper detected: $THEME_NAME"
    # Kill any existing mpvpaper processes
    killall mpvpaper 2>/dev/null
    
    # Check if mpvpaper is installed
    if command -v mpvpaper >/dev/null 2>&1; then
        # swww should be cleared to show the live wallpaper behind it
        swww clear 
        # Start mpvpaper in background (looping, no audio)
        mpvpaper -o "no-audio --loop" "*" "$LIVE_WP" & disown
    else
        echo "⚠️  mpvpaper not found. Falling back to static wallpaper."
        echo "👉 Tip: Install 'mpvpaper' for a fully animated live desktop!"
    fi
else
    # Non-live wallpaper: Ensure mpvpaper is stopped
    killall mpvpaper 2>/dev/null
fi

if [ -f "$WP" ]; then
    # We always set the swww image (even for live themes as fallback/wallust)
    swww img "$WP" --transition-type grow --transition-pos 0.85,0.85 --transition-step 90
    wallust run "$WP"
fi

# 2. Terminal Logo & Fastfetch Config
# Force resolution order: terminal.png -> terminal.jpg -> terminal.PNG -> terminal.JPG -> WP
TERMINAL_IMG="$THEME_DIR/terminal.png"
[ -f "$TERMINAL_IMG" ] || TERMINAL_IMG="$THEME_DIR/terminal.jpg"
[ -f "$TERMINAL_IMG" ] || TERMINAL_IMG="$THEME_DIR/terminal.PNG"
[ -f "$TERMINAL_IMG" ] || TERMINAL_IMG="$THEME_DIR/terminal.JPG"
[ -f "$TERMINAL_IMG" ] || TERMINAL_IMG="$WP"

# Sync the logo to the location expected by fastfetch configs
if [ -f "$TERMINAL_IMG" ]; then
    mkdir -p "$FF_DIR"
    cp -vf "$TERMINAL_IMG" "$FF_DIR/theme_logo.png"
    cp -vf "$TERMINAL_IMG" "$FF_DIR/theme_logo"
else
    echo "⚠️ Warning: Terminal image not found: $TERMINAL_IMG"
fi

# 3. Notification Background & Icon
NOTIFICATION_IMG="$THEME_DIR/notification.jpg"
[ -f "$NOTIFICATION_IMG" ] || NOTIFICATION_IMG="$THEME_DIR/notification.png"
[ -f "$NOTIFICATION_IMG" ] || NOTIFICATION_IMG="$THEME_DIR/notification.PNG"
[ -f "$NOTIFICATION_IMG" ] || NOTIFICATION_IMG="$WP"

if [ -f "$NOTIFICATION_IMG" ]; then
    cp -vf "$NOTIFICATION_IMG" "$HOME/.config/swaync/notification_bg.jpg"
fi

# Sync the theme icon so notification triggers can use it
if [ -f "$TERMINAL_IMG" ]; then
    mkdir -p "$HOME/.config/swaync/icons"
    cp -vf "$TERMINAL_IMG" "$HOME/.config/swaync/icons/theme.png"
fi

if [ -f "$FF_DIR/$THEME_NAME.jsonc" ]; then
    cp -v "$FF_DIR/$THEME_NAME.jsonc" "$FF_DIR/config.jsonc"
elif [ -f "$FF_DIR/config-compact.jsonc" ]; then
    cp -v "$FF_DIR/config-compact.jsonc" "$FF_DIR/config.jsonc"
fi

# Explicitly set the logo source path in the active config.jsonc
# We use a non-greedy-like match [^"]* to avoid destroying the rest of the line
if [ -f "$FF_DIR/config.jsonc" ] && [ -f "$TERMINAL_IMG" ]; then
    REAL_TERMINAL_PATH=$(realpath "$TERMINAL_IMG")
    sed -i "s|\"source\": \"[^\"]*\"|\"source\": \"$REAL_TERMINAL_PATH\"|g" "$FF_DIR/config.jsonc"
fi

# Reload
swaync-client -rs >/dev/null 2>&1
echo "Theme '$THEME_NAME' applied successfully."
