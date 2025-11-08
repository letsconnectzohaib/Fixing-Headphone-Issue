#!/bin/bash
# Complete setup for USB headset mic sync and auto-start on Linux Mint / Debian

# --- 1. Update system ---
sudo apt update
sudo apt install -y pipewire pipewire-audio-client-libraries wireplumber \
    libspa-0.2-bluetooth pulseaudio-utils evtest

# --- 2. Disable PulseAudio and enable PipeWire ---
systemctl --user --now disable pulseaudio.service pulseaudio.socket
systemctl --user --now enable pipewire pipewire-pulse wireplumber

echo "PipeWire enabled and PulseAudio disabled."

# --- 3. Create mic sync script ---
SYNC_SCRIPT="$HOME/headset-mic-sync.sh"

cat > "$SYNC_SCRIPT" << 'EOF'
#!/bin/bash
# Script to keep USB headset mic mute/unmute in sync with button presses

# Find the headset input device automatically
DEVICE=$(evtest --list-devices | grep -i "C-Media\|Unitek" -A1 | tail -n1 | awk -F: '{print $1}' | tr -d ' ')
if [ -z "$DEVICE" ]; then
    echo "Headset input device not found. Please check 'evtest --list-devices'."
    exit 1
fi

echo "Using headset device: $DEVICE"

# Monitor KEY_MICMUTE events and toggle mic mute in PipeWire
sudo evtest /dev/input/event$DEVICE --grab | \
while read line; do
    if echo "$line" | grep -q "KEY_MICMUTE"; then
        pactl set-source-mute @DEFAULT_SOURCE@ toggle
        echo "$(date '+%H:%M:%S') - Toggled mic mute"
    fi
done
EOF

chmod +x "$SYNC_SCRIPT"
echo "Mic sync script created at $SYNC_SCRIPT"

# --- 4. Create autostart entry ---
AUTOSTART_DIR="$HOME/.config/autostart"
mkdir -p "$AUTOSTART_DIR"

cat > "$AUTOSTART_DIR/headset-mic-sync.desktop" << EOF
[Desktop Entry]
Type=Application
Exec=$SYNC_SCRIPT
Hidden=false
NoDisplay=false
X-GNOME-Autostart-enabled=true
Name=Headset Mic Sync
Comment=Keeps USB headset mic state synced with button
EOF

echo "Autostart entry created: $AUTOSTART_DIR/headset-mic-sync.desktop"

# --- 5. Start script immediately ---
nohup "$SYNC_SCRIPT" >/dev/null 2>&1 &

echo "Setup complete! Mic sync daemon is running and will auto-start on login."
