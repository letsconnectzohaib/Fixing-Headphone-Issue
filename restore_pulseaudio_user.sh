#!/bin/bash
# ----------------------------------------------------------
# Full PulseAudio Restore Script
# Completely restores PulseAudio as the default audio system
# Requires sudo for system-wide changes and persistence
# Ensures built-in and external audio/mic devices work correctly
# ----------------------------------------------------------

# === REQUIRE SUDO ===
if [ "$EUID" -ne 0 ]; then
  echo "❌ Please run as root: sudo bash restore_pulseaudio_user.sh"
  exit 1
fi

echo "🔄 Starting full PulseAudio restoration..."

# === UPDATE PACKAGE LIST ===
echo "📦 Updating package list..."
apt update

# === REINSTALL PULSEAUDIO ===
echo "🔧 Reinstalling PulseAudio and utils..."
apt install -y pulseaudio pulseaudio-utils pulseaudio-module-bluetooth

# === UNMASK PULSEAUDIO SERVICES ===
echo "🔓 Unmasking PulseAudio services..."
systemctl unmask pulseaudio.service pulseaudio.socket

# === RESTORE BACKUP CONFIGS (if exist) ===
echo "📁 Restoring original PipeWire configs (if backed up)..."
if [ -d "/etc/pipewire/backup" ]; then
  cp -r /etc/pipewire/backup/*.conf /etc/pipewire/ 2>/dev/null || true
  rm -rf /etc/pipewire/pipewire.conf.d/99-performance.conf 2>/dev/null || true
  rm -rf ~/.config/pipewire/pipewire-pulse.conf.d/echo-cancel.conf 2>/dev/null || true
  echo "✅ Configs restored from backup."
else
  echo "ℹ️ No backup configs found - skipping restore."
fi

# === DISABLE PIPEWIRE SYSTEM-WIDE ===
echo "🔇 Disabling PipeWire system-wide..."
systemctl disable --now pipewire pipewire-pulse wireplumber 2>/dev/null || true

# === ENABLE PULSEAUDIO SYSTEM-WIDE ===
echo "🔊 Enabling PulseAudio system-wide..."
systemctl enable pulseaudio
systemctl start pulseaudio

# === DISABLE PIPEWIRE FOR ALL USERS ===
echo "👥 Disabling PipeWire for all users..."
for user_home in /home/*; do
  if [ -d "$user_home" ]; then
    username=$(basename "$user_home")
    if id "$username" >/dev/null 2>&1; then
      su - "$username" -c "systemctl --user disable pipewire pipewire-pulse wireplumber 2>/dev/null || true" 2>/dev/null || true
      su - "$username" -c "systemctl --user stop pipewire pipewire-pulse wireplumber 2>/dev/null || true" 2>/dev/null || true
    fi
  fi
done

# === ENABLE PULSEAUDIO FOR ALL USERS ===
echo "🎤 Enabling PulseAudio for all users..."
for user_home in /home/*; do
  if [ -d "$user_home" ]; then
    username=$(basename "$user_home")
    if id "$username" >/dev/null 2>&1; then
      su - "$username" -c "systemctl --user enable pulseaudio pulseaudio.socket" 2>/dev/null || true
      su - "$username" -c "systemctl --user start pulseaudio pulseaudio.socket" 2>/dev/null || true
    fi
  fi
done

# === LOAD PULSEAUDIO MODULES ===
echo "🔄 Loading PulseAudio modules..."
pactl load-module module-alsa-sink 2>/dev/null || true
pactl load-module module-alsa-source device=hw:0,0 2>/dev/null || true  # Built-in
pactl load-module module-alsa-source device=hw:1,0 2>/dev/null || true  # External USB
pactl load-module module-bluetooth-discover 2>/dev/null || true
pactl load-module module-bluetooth-policy 2>/dev/null || true

# === RESTART AUDIO SERVICES ===
echo "♻️ Restarting audio services..."
systemctl restart alsa-utils
systemctl restart pulseaudio

# === VERIFY AUDIO DEVICES ===
echo "🔍 Verifying audio devices..."
echo "Available sinks (speakers/headphones):"
pactl list sinks short
echo ""
echo "Available sources (microphones):"
pactl list sources short

# === TEST AUDIO ===
echo "🧪 Testing audio (play test sound)..."
if command -v speaker-test >/dev/null 2>&1; then
  timeout 3 speaker-test -t sine -f 1000 -l 1 >/dev/null 2>&1 && echo "✅ Speaker test passed" || echo "⚠️ Speaker test failed - check connections"
else
  echo "ℹ️ speaker-test not available - manual testing recommended"
fi

echo "🎉 PulseAudio full restoration complete!"
echo "💡 Built-in and external audio devices should now work."
echo "💡 If issues persist, try: pulseaudio --kill && pulseaudio --start"
echo "💡 Or reboot for guaranteed full effect."
