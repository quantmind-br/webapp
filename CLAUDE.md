# CLAUDE.md

This file provides guidance to Claude Code (claude.ai/code) when working with code in this repository.

## Overview

This repository contains a Web App Manager toolkit for Linux systems. It creates and manages Progressive Web Apps (PWAs) as native desktop applications using Chromium-based browsers. Web apps are installed as `.desktop` files that launch the user's default browser in app mode, integrating with the system's application launcher and taskbar.

## Architecture

### Core Scripts

- **webapp**: Interactive TUI menu-driven interface using `gum` for all operations (install, launch, list, remove)
- **webapp-install**: Standalone script to install a new web app (interactive or command-line)
- **webapp-launch**: Browser launcher that detects the default Chromium-based browser and launches it in app mode
- **webapp-list**: Display all installed web apps with their URLs and icon status
- **webapp-remove**: Remove one or more web apps (interactive or command-line)
- **install.sh**: Installer that copies all scripts to `~/scripts/` directory

### Integration Points

**Desktop Environment Integration:**
- Creates `.desktop` files in `~/.local/share/applications/`
- Stores icons in `~/.local/share/applications/icons/`
- Generates `StartupWMClass` based on URL for window manager grouping
- Updates the desktop database after install/remove operations

**Waybar Integration:**
- Automatically updates `~/.config/waybar/modules.json` when installing apps
- Adds `app_ids-mapping` entries to display proper app names in taskbar
- Maps Chromium's WMClass format (`chrome-domain__path-Default`) to friendly names

**Browser Compatibility:**
- Supports: Chrome, Brave, Edge, Opera, Vivaldi, Helium
- Falls back to Chromium if default browser is not Chromium-based
- Uses `xdg-settings` to detect the default browser
- Launches via `uwsm-app` wrapper with `--app=` flag for PWA mode

### Data Flow

1. **Installation**: User provides name, URL, and icon → Script downloads/copies icon → Creates `.desktop` file with generated `StartupWMClass` → Updates waybar config → Registers with desktop database
2. **Launch**: Script detects default browser → Finds browser executable → Launches with `--app=URL` flag
3. **Listing**: Scans `.desktop` files for webapp-launch pattern → Extracts metadata → Displays formatted output
4. **Removal**: Deletes `.desktop` file and associated icon → Updates desktop database

### Key Design Patterns

**WMClass Generation:**
The `StartupWMClass` is critical for window manager integration. It follows Chromium's naming pattern:
- Protocol removed: `https://example.com/path` → `example.com/path`
- Trailing slash removed
- All slashes converted to double underscores: `example.com/path` → `example.com__path`
- Prefixed with `chrome-` and suffixed with `-Default`: `chrome-example.com__path-Default`

**Web App Detection:**
Web apps are identified by their `Exec` line matching patterns:
- `webapp-launch`
- `omarchy-launch-webapp` (legacy)
- `omarchy-webapp-handler` (legacy)

**Icon Handling:**
Supports three icon sources:
1. HTTP/HTTPS URL: Downloads to local icon directory
2. Local file path: Copies to icon directory
3. Existing icon name: References file already in icon directory

## Common Development Tasks

### Testing Scripts Locally

Test without installing to `~/scripts/`:
```bash
./webapp                    # Test interactive menu
./webapp-install            # Test interactive install
./webapp-list               # Test listing
./webapp-remove             # Test interactive removal
```

Test with command-line arguments:
```bash
./webapp-install "App Name" "https://example.com" "https://example.com/icon.png"
./webapp-remove "App Name"
```

### Debugging Desktop Integration

Check installed apps:
```bash
ls -la ~/.local/share/applications/*.desktop
grep -l "webapp-launch" ~/.local/share/applications/*.desktop
```

View desktop file contents:
```bash
cat ~/.local/share/applications/"App Name.desktop"
```

Test desktop file launch:
```bash
gtk-launch "App Name.desktop"
```

Refresh desktop database:
```bash
update-desktop-database ~/.local/share/applications/
```

### Debugging Waybar Integration

Check waybar config:
```bash
cat ~/.config/waybar/modules.json | grep -A 10 "app_ids-mapping"
```

Restart waybar:
```bash
~/.config/waybar/launch.sh
```

### Installation

Install scripts to `~/scripts/`:
```bash
./install.sh
```

Ensure `~/scripts` is in PATH by adding to `~/.bashrc` or `~/.zshrc`:
```bash
export PATH="$HOME/scripts:$PATH"
```

## Dependencies

**Required:**
- `gum`: TUI components for interactive prompts (https://github.com/charmbracelet/gum)
- `curl`: For downloading icons
- `sed`, `grep`, `find`: For text processing and file searching
- Chromium-based browser (Chrome, Brave, Chromium, etc.)
- `xdg-settings`: For detecting default browser
- `uwsm-app`: Wayland session manager app launcher
- `gtk-launch`: For launching desktop files

**Optional:**
- Waybar: For taskbar integration
- Desktop environment with `.desktop` file support

## Notes for AI Assistants

- The scripts use bash string manipulation heavily (`sed`, `grep`, regex)
- Icon paths must be absolute paths, not relative
- Desktop files require specific formatting and executable permissions
- The `StartupWMClass` calculation is critical for proper window grouping
- Legacy app detection patterns (`omarchy-*`) must be preserved for backward compatibility
- All user-facing output uses ANSI color codes for formatting
- Error handling should check for file existence, curl success, and proper permissions
