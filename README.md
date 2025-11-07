# Install PipeWire as Default Audio System 🔊

A simple shell script to automate the installation and configuration of PipeWire as the default audio system on Linux Mint and Ubuntu systems. This replaces PulseAudio with PipeWire for improved audio performance, Bluetooth support, and USB audio handling.

## Features ⚙️

- Installs PipeWire and essential dependencies (Pulse replacement, WirePlumber, Bluetooth, USB audio)
- Completely disables and removes PulseAudio
- Enables PipeWire system-wide as the default audio service
- Sets up autostart entries to maintain PipeWire as default
- Reloads ALSA and PulseAudio modules for immediate activation

## Prerequisites 📋

- **Operating System**: Ubuntu 20.04+ or Linux Mint 20+
- **Privileges**: Root access (sudo) required for system modifications
- **Internet Connection**: Required for package downloads
- **Backup**: Consider backing up any custom audio configurations

## Usage 🚀

1. **Download the script**:
   ```bash
   wget https://example.com/install_pipewire_default.sh  # Replace with actual URL
   ```

2. **Make it executable**:
   ```bash
   chmod +x install_pipewire_default.sh
   ```

3. **Run with sudo**:
   ```bash
   sudo ./install_pipewire_default.sh
   ```

The script will handle all installation and configuration steps automatically. It may take several minutes to complete.

## Verification ✅

After running the script, verify PipeWire is active:

1. **Check PipeWire services**:
   ```bash
   systemctl --user status pipewire pipewire-pulse wireplumber
   ```

2. **Verify audio devices**:
   ```bash
   pactl info
   ```
   Should show PipeWire as the server.

3. **Test audio**:
   Play a sound file or use a media player to confirm audio output.

## Troubleshooting 🔧

### No Sound After Installation
- **Reboot the system**: `sudo reboot`
- Some audio applications may need restarting.

### PipeWire Not Starting
- Check for errors: `journalctl --user -u pipewire`
- Ensure no PulseAudio remnants: `ps aux | grep pulse`

### Bluetooth Audio Issues
- Restart Bluetooth service: `sudo systemctl restart bluetooth`
- Pair devices again if necessary.

### USB Audio Not Working
- Reload ALSA: `sudo alsa force-reload`
- Check device detection: `aplay -l`

### Rollback to PulseAudio
If issues persist, reinstall PulseAudio:
```bash
sudo apt update
sudo apt install pulseaudio pulseaudio-utils
sudo systemctl --user disable pipewire pipewire-pulse
sudo systemctl --user enable pulseaudio
```

## Customization Notes 🎛️

For advanced users:

- **Modify autostart**: Edit `/etc/xdg/autostart/pipewire.desktop` to customize startup behavior.
- **Config files**: PipeWire configs are in `~/.config/pipewire/` or `/etc/pipewire/`.
- **Additional modules**: Install extra PipeWire modules via `apt` if needed.
- **System-wide vs user**: The script enables system-wide; for user-only, modify service files.

## Example Output 📄

```
🔊 Installing PipeWire and dependencies...
✅ PipeWire installed successfully
🔇 Disabling PulseAudio...
✅ PulseAudio disabled and removed
⚙️ Enabling PipeWire services...
✅ PipeWire set as default audio system
🔄 Reloading audio modules...
🎉 Installation complete! Please reboot for full effect.
```

## License 📜

This project is licensed under the MIT License - see the LICENSE file for details.

## Contributing 🤝

Feel free to submit issues or pull requests for improvements.
