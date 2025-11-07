# PipeWire Optimization Script 🔧

A comprehensive shell script to fine-tune PipeWire for optimal performance, stability, and audio quality on Linux Mint and Ubuntu systems. Specifically optimized for USB headsets with microphones and LED indicators, this script enhances echo cancellation, noise suppression, and automatic gain control while minimizing latency.

## Overview 🎯

The `pipewire_optimize.sh` script applies advanced configuration tweaks to your existing PipeWire installation, ensuring smooth audio handling for modern USB devices. It focuses on performance enhancements without compromising system stability.

## Requirements 📋

- **PipeWire**: Must be installed and running (use `install_pipewire_default.sh` if not already set up)
- **Operating System**: Ubuntu 20.04+ or Linux Mint 20+
- **Privileges**: Root access required (sudo)
- **Dependencies**: WebRTC audio processing modules (installed automatically)

## Installation & Usage 🚀

1. **Download the script**:
   ```bash
   wget https://example.com/pipewire_optimize.sh  # Replace with actual URL
   ```

2. **Make executable**:
   ```bash
   chmod +x pipewire_optimize.sh
   ```

3. **Run as root**:
   ```bash
   sudo bash pipewire_optimize.sh
   ```

The script will automatically apply optimizations and restart services. A reboot is recommended for full effect.

## What Each Tweak Does 🛠️

### Performance Settings ⚡
- **Clock Rate**: Sets default to 48kHz for high-quality audio
- **Quantum**: Adjusts buffer sizes (512-2048) for low latency
- **Resample Quality**: Maximum quality (10) for clear audio conversion
- **Real-time Module**: Enables RT priority for reduced audio glitches

### Audio Processing 🎙️
- **Echo Cancellation**: Removes microphone feedback using WebRTC
- **Noise Suppression**: Filters background noise for clearer calls
- **Automatic Gain Control**: Dynamically adjusts mic levels

### System Integration 🔒
- **PulseAudio Masking**: Prevents service conflicts by disabling PulseAudio
- **Helvum GUI**: Optional installation of PipeWire's graphical patchbay tool

## Verification ✅

After running, confirm optimizations:

1. **Check PipeWire status**:
   ```bash
   pactl info
   ```
   Should show PipeWire as active server.

2. **Monitor performance**:
   ```bash
   pw-top
   ```
   View real-time audio metrics and latency.

3. **Test audio quality**:
   - Play music and make a test call
   - Check for reduced echo and noise

## Troubleshooting 🔧

### Audio Not Working
- **Restart services**: `systemctl --user restart pipewire pipewire-pulse`
- **Check logs**: `journalctl --user -u pipewire | tail -20`

### High Latency
- **Adjust quantum**: Edit `/etc/pipewire/pipewire.conf.d/99-performance.conf`
- **Lower min-quantum** to 256 (advanced users only)

### USB Device Issues
- **Reload ALSA**: `sudo alsa force-reload`
- **Check device**: `lsusb` and `aplay -l`

### WebRTC Modules Failing
- **Install dependencies**: `sudo apt install pipewire-audio-client-libraries`
- **Update PipeWire**: Ensure latest version is installed

## Reverting Changes ↩️

To undo optimizations:

1. **Restore backups**:
   ```bash
   sudo cp /etc/pipewire/backup/*.conf /etc/pipewire/
   ```

2. **Unmask PulseAudio**:
   ```bash
   sudo systemctl unmask pulseaudio.service pulseaudio.socket
   ```

3. **Restart services**:
   ```bash
   systemctl --user restart pipewire pipewire-pulse
   sudo systemctl restart pulseaudio
   ```

4. **Reboot** to fully revert.

## Example Output 📄

```
🔧 Starting PipeWire optimization...
📦 Backing up existing configs...
⚙️ Applying performance settings...
🎙️ Enabling echo cancellation and noise suppression...
🔒 Masking PulseAudio services...
🖥️ Installing Helvum...
♻️ Restarting PipeWire...
✅ PipeWire optimization complete!
💡 Reboot recommended to apply all changes.
```

## License 📜

This project is licensed under the MIT License - see the LICENSE file for details.

## Contributing 🤝

Suggestions and improvements are welcome via issues or pull requests!
