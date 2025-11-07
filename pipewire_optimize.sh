#!/bin/bash
# ----------------------------------------------------------
# PipeWire Optimization Script for Linux Mint / Ubuntu
# Applies best performance, stability, and quality settings
# Especially tuned for USB headsets with mic + LED indicators
# ----------------------------------------------------------

# Must be run as root
if [ "$EUID" -ne 0 ]; then
  echo "❌ Please run as root (sudo bash pipewire_optimize.sh)"
  exit 1
fi

echo "🔧 Starting PipeWire optimization..."

# === BACKUP CONFIGS ===
echo "📦 Backing up existing configs..."
mkdir -p /etc/pipewire/backup
cp -r /etc/pipewire/*.conf /etc/pipewire/backup/ 2>/dev/null || true

# === PERFORMANCE TWEAKS ===
echo "⚙️ Applying performance settings..."
mkdir -p /etc/pipewire/pipewire.conf.d

cat <<'EOF' > /etc/pipewire/pipewire.conf.d/99-performance.conf
# High-performance PipeWire tuning for Linux Mint / Ubuntu
context.properties = {
    default.clock.rate          = 48000
    default.clock.quantum       = 1024
    default.clock.min-quantum   = 512
    default.clock.max-quantum   = 2048
    default.clock.allowed-rates = [ 44100 48000 96000 ]
    resample.quality            = 10
    core.daemonize              = true
}
context.modules = [
    { name = libpipewire-module-rt }
    { name = libpipewire-module-protocol-native }
    { name = libpipewire-module-protocol-pulse }
]
EOF

# === ENABLE ECHO CANCELLATION ===
echo "🎙️ Enabling echo cancellation and noise suppression..."
mkdir -p ~/.config/pipewire/pipewire-pulse.conf.d

cat <<'EOF' > ~/.config/pipewire/pipewire-pulse.conf.d/echo-cancel.conf
# Microphone echo cancellation, noise suppression & AGC
context.modules = [
    { name = libpipewire-module-echo-cancel
        args = {
            aec.args = {
                webrtc.echo-cancellation = true
                webrtc.noise-suppression = true
                webrtc.automatic-gain-control = true
            }
        }
    }
]
EOF

# === DISABLE PULSEAUDIO ===
echo "🔒 Masking PulseAudio services..."
systemctl mask --now pulseaudio.service pulseaudio.socket 2>/dev/null || true

# === INSTALL HELVUM (optional GUI) ===
echo "🖥️ Installing Helvum (optional PipeWire graph tool)..."
apt install -y helvum

# === RESTART PIPEWIRE SERVICES ===
echo "♻️ Restarting PipeWire..."
systemctl --user restart pipewire pipewire-pulse wireplumber 2>/dev/null || true

echo "✅ PipeWire optimization complete!"
echo "💡 Reboot recommended to apply all changes."
echo "Run 'pw-top' or 'pactl info' to verify PipeWire is active."
