#!/bin/bash
# ----------------------------------------------------------
# Restore PulseAudio Script (User-Level)
# Enables PulseAudio as the default audio system for the current user
# Disables PipeWire user services and restores PulseAudio functionality
# Run as regular user (no sudo required for most commands)
# ----------------------------------------------------------

echo "🔄 Restoring PulseAudio as user audio system..."

# === CHECK IF RUNNING AS ROOT ===
if [ "$EUID" -eq 0 ]; then
  echo "❌ Please run this script as a regular user, not root/sudo."
  echo "💡 This script configures user-level audio services."
  exit 1
fi

# === UNMASK PULSEAUDIO (may require sudo if masked) ===
echo "🔓 Unmasking PulseAudio services..."
if command -v sudo >/dev/null 2>&1; then
  sudo systemctl unmask pulseaudio.service pulseaudio.socket 2>/dev/null || echo "⚠️ Unmasking may have failed - try running with sudo if issues persist."
else
  echo "⚠️ sudo not available. You may need to manually unmask PulseAudio services as root."
fi

# === DISABLE PIPEWIRE USER SERVICES ===
echo "🔇 Disabling PipeWire user services..."
systemctl --user disable pipewire pipewire-pulse wireplumber 2>/dev/null || true
systemctl --user stop pipewire pipewire-pulse wireplumber 2>/dev/null || true

# === ENABLE AND START PULSEAUDIO ===
echo "🔊 Enabling and starting PulseAudio..."
systemctl --user enable pulseaudio pulseaudio.socket
systemctl --user start pulseaudio pulseaudio.socket

# === VERIFY PULSEAUDIO IS RUNNING ===
echo "✅ Checking PulseAudio status..."
if systemctl --user is-active --quiet pulseaudio; then
  echo "🎉 PulseAudio is now active and running!"
  echo "💡 You may need to restart audio applications or log out/in for full effect."
else
  echo "⚠️ PulseAudio may not be running. Check with: systemctl --user status pulseaudio"
fi

# === OPTIONAL: RESTART AUDIO APPLICATIONS ===
echo "🔄 Restarting audio-related processes..."
pkill -HUP pulseaudio 2>/dev/null || true

echo "✅ PulseAudio restoration complete!"
echo "Run 'pactl info' to verify PulseAudio is the active server."
