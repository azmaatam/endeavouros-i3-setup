# EndeavourOS i3 Setup

My personal, portable configuration for EndeavourOS Linux with the i3 window manager.

This repository contains desktop configuration files, utility scripts, package lists, and helper scripts for setting up a similar environment after a fresh installation.

## Features

- **i3** — window manager, keybindings, and i3blocks configuration.
- **Polybar** — status bar and supporting scripts.
- **Picom** — compositor configuration.
- **Rofi** — application launcher and themes.
- **Kitty** — terminal configuration.
- **Package lists** — separate base, desktop, and optional packages.
- **Backup helper** — backs up existing configurations before installation.
- **Wallpaper helper** — selects a random wallpaper from a local directory.

## Repository Structure

```text
.
├── .config/
│   ├── i3/
│   │   ├── config
│   │   ├── i3blocks.conf
│   │   ├── keybindings
│   │   └── scripts/
│   ├── kitty/
│   ├── picom/
│   ├── polybar/
│   └── rofi/
├── optional/
│   └── i3-google-drive-bindings
├── packages/
│   ├── base.txt
│   ├── desktop.txt
│   └── optional.txt
├── scripts/
│   ├── backup-configs.sh
│   ├── install-dotfiles.sh
│   └── install-packages.sh
└── README.md
```

## Requirements

- EndeavourOS or a compatible Arch Linux installation.
- An X11 session with i3.
- `git` and the tools required by the selected scripts.
- `sudo` access for package installation.

The configuration is designed around my own setup. Hardware, display names, audio devices, installed applications, and available commands may differ on other machines.

## Installation

### 1. Clone the repository

```bash
git clone <YOUR_REPOSITORY_URL>
cd endeavouros-i3-setup
```

Replace `<YOUR_REPOSITORY_URL>` with the URL of your GitHub repository.

### 2. Check required packages

The package installer defaults to check mode and does not install anything:

```bash
./scripts/install-packages.sh --check
```

To install required packages:

```bash
./scripts/install-packages.sh --install
```

Optional packages are separate and can be included using the installer's supported option:

```bash
./scripts/install-packages.sh --install --include-optional
```

Review the package lists before installing. Optional software may not be appropriate for every system.

### 3. Preview dotfile installation

Always preview the changes first:

```bash
./scripts/install-dotfiles.sh --dry-run
```

The installer is designed to add missing files without overwriting existing paths. Existing configurations may therefore remain different from the versions in this repository.

To proceed after reviewing the preview:

```bash
./scripts/install-dotfiles.sh --install
```

The installer asks for confirmation and runs the backup helper before copying files.

### 4. Review and test

After installation, review the resulting configuration before reloading i3 or restarting desktop components.

Some settings may require manual adjustment for your hardware, applications, and preferences.

## Backups

The backup helper stores copies of existing configurations under:

```text
~/.local/state/endeavouros-i3-setup/backups/
```

Run it manually when needed:

```bash
./scripts/backup-configs.sh
```

Keep important backups until you have verified that the new configuration works as expected.

## Wallpapers

The wallpaper helper looks for image files in:

```text
~/Pictures/Wallpapers/
```

You can override the directory for a particular invocation:

```bash
WALLPAPER_DIR="$HOME/Pictures/MyWallpapers" \
  ./.config/i3/scripts/wallpaper
```

Wallpaper images are not included in this repository.

## Optional Google Drive Bindings

The file `optional/i3-google-drive-bindings` contains optional i3 keybindings for user-provided Google Drive mount and unmount scripts.

Those helper scripts are not included. Only enable the bindings after creating and verifying the required scripts in `~/.local/bin/`.

## Security and Privacy

- Do not commit API keys, passwords, tokens, private configuration files, or credentials.
- Review changes before committing or pushing.
- Personal files, local backups, and wallpaper collections should remain outside the repository.
- Review scripts before executing them, especially scripts that use `sudo` or modify system settings.

## License

No license has been specified yet. Unless a license is added, reuse and redistribution are not automatically granted.
