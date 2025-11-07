#!/bin/bash
# ----------------------------------------------------------
# PipeWire Installation Script for Linux Mint / Ubuntu
# Replaces PulseAudio completely and configures PipeWire
# with USB headset & Bluetooth support
# ----------------------------------------------------------

# Must be run as root
if [ "$EUID" -ne 0 ]; then
  echo "❌ Please run this script as root (use: sudo ./install_pipewire_default.sh)"
  exit 1
fi

USER_NAME="${SUDO_USER:-$USER}"

echo "🔄 Updating package lists..."
apt update -y

echo "📦 Installing PipeWire and dependencies..."
apt install -y pipewire pipewire-audio-client-libraries \
  libspa-0.2-bluetooth wireplumber pipewire-pulse alsa-utils \
  pavucontrol pulseaudio-utils

echo "🚫 Disabling and removing PulseAudio..."
sudo -u "$USER_NAME" bash -c '
  systemctl --user --now disable pulseaudio.service pulseaudio.socket 2>/dev/null || true
  systemctl --user --now stop pulseaudio.service pulseaudio.socket 2>/dev/null || true
'
apt purge -y pulseaudio
apt autoremove -y

echo "⚙️ Enabling PipeWire services safely..."
loginctl enable-linger "$USER_NAME" 2>/dev/null || true

sudo -u "$USER_NAME" bash -c '
  systemctl --user --now enable pipewire.service pipewire-pulse.service wireplumber.service 2>/dev/null || true
  systemctl --user --now start pipewire.service pipewire-pulse.service wireplumber.service 2>/dev/null || true
'

echo "🔐 Locking PipeWire as default audio server..."
mkdir -p /etc/xdg/autostart
cat <<EOF > /etc/xdg/autostart/pipewire.desktop
[Desktop Entry]
Type=Application
Exec=/usr/bin/pipewire
Hidden=false
NoDisplay=false
X-GNOME-Autostart-enabled=true
Name=PipeWire Audio Server
EOF

cat <<EOF > /etc/xdg/autostart/pipewire-pulse.desktop
[Desktop Entry]
Type=Application
Exec=/usr/bin/pipewire-pulse
Hidden=false
NoDisplay=false
X-GNOME-Autostart-enabled=true
Name=PipeWire Pulse Replacement
EOF

echo "🎧 Configuring ALSA & USB headset rules..."
cat <<EOF > /etc/modprobe.d/alsa-base.conf
# Use PipeWire for all USB audio
options snd_usb_audio index=0
EOF

# Reload ALSA
echo "🔊 Reloading ALSA and audio subsystems..."
alsa force-reload || true
pactl unload-module module-udev-detect 2>/dev/null || true
pactl load-module module-udev-detect 2>/dev/null || true

echo "✅ PipeWire installation complete!"
echo "➡️ Reboot your system to finalize setup."
echo "You can verify with: pactl info | grep 'Server Name'"
echo "It should show: 'Server Name: PipeWire (PulseAudio Replacement)'"
