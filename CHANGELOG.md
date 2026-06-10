# Changelog

All notable changes to this project are documented here.

---

## v0.5.2
### UX
- Reduced vertical spacing between group labels and their disk cards in the Computer view

### Fixed
- Computer sidebar row icon and label now align with native Nautilus rows (Home, Recent, etc.)

### Maintenance
- Sidebar design values (icon gap, row inset padding) moved to the centralized CSS block

---

## v0.5.1
### UX
- Settings page labels and descriptions improved across all sections
- Visibility section now includes a description explaining Visible, Merged, and Hidden
- "Show system partitions" toggle moved to the bottom of the Visibility group
- "Disk Usage Color" renamed to "Usage Bar Color" with a short description
- Group names simplified to location-style: Removable, Disc, Network (was: Removable Devices, Disc Images, Network Volumes)
- "On this Computer" removed from visibility controls - it is always visible as the merge target

---

## v0.5.0
### Added
- New "System" group separating root, boot, EFI, and swap from regular drives
- Per-group visibility control: each group can be Visible, Merged into "On this computer", or Hidden
- "Show system partitions" toggle to include boot and EFI entries in the System group (default off)
- Sort-by-type ordering in the merged "On this computer" view: System first, then local drives, then removable, disc, network
- `DiskGroup` dataclass encapsulating group logic and state

### Changed
- Five groups total: System, On this computer, Removable Devices, Disc Images, Network Volumes
- Settings: replaced `hide-system-partitions` with `show-system-partitions` (inverted, same default behavior)

### Fixed
- USB drives running a Linux system (iso9660 filesystem) now correctly appear in Removable Devices instead of Disc Images
- Loop-mounted ISO images continue to appear in Disc Images regardless of mount path

---

## v0.4.6
### Fixed
- Installer `--branch` and `--version` are now independent axes, not mutually exclusive
- Bad branch falls back to `main`, bad version falls back to latest tag - no hard errors
- Version resolution now uses git tags instead of GitHub Releases, so tags always resolve
- Install type section always shows `Source`, `Branch`, and `Version` lines
- Local installs show current branch and version from the local file, not arg values

## v0.4.5
### Fixed
- Installer fully POSIX compliant - removed all `local` keyword usage
- Installer uses CLI flags (`--version=`, `--branch=`) instead of env vars, which do not survive `curl | sh` pipes
- `--version` and `--branch` validated as mutually exclusive
- `--branch` probed early, fails hard on unknown branch name
- `apt` package detection uses `dpkg-query` to avoid false positives on partially-removed packages
- GitHub API fallback to `main` now prints a visible warning instead of silently proceeding
- Installer skips `sudo` when already running as root
- `--version`/`--branch` flags produce a warning on local installs instead of silently doing nothing

### Maintenance
- Extracted `SCHEMA_ID`, `GETTEXT_DOMAIN`, `PYCACHE_GLOB` constants - all derived names have a single source of truth

## v0.4.4
### Fixed
- Installer (`install.sh`) now POSIX `sh` compliant, fixes `curl | sh` failing on systems where `/bin/sh` is `dash` (e.g. Debian, Ubuntu)

## v0.4.3
### UX
- Fixed a brief flicker of the file view when navigating to Computer

## v0.4.2
### UX
- Panel now opens in ~20-65ms instead of ~500-600ms

## v0.4.1
### Internationalization
- Updated Arabic translations (credit @e6ad2020)
- Updated French translations

## v0.4.0
### Added
- Italian, Spanish, Catalan and Portuguese translations (credit @unaibenidorm)
- Non-interactive installer with `curl | sh`, `VERSION` and `BRANCH` env vars (credit @sour-source)

### Fixed
- Disk cards not updating when drives are connected or disconnected
- Disk cards not updating during active file transfers
- Level bar gradient not rendering on Ubuntu 22.04 LTS and other GTK 4.6.x systems
- Crash on startup when Nautilus opens directly to a folder (credit @e6ad2020, PR #10)
- Navigation crash on pathbar (credit @unaibenidorm, @e6ad2020, issue #11)

## v0.3.1
### Fixed
- Crash on startup when `~/Templates` is non-empty (issue #4)
- Level bar gradient direction incorrect in RTL languages (credit @e6ad2020)

### Internationalization
- Arabic translation for Disc Images group (credit @e6ad2020)

## v0.3.0
### Added
- Native Computer button in the left sidebar, replacing the bookmark approach
- Right-click context menu on the Computer sidebar button (Open, Open in New Tab, Open in New Window, Settings)
- Computer sidebar button highlights when Computer view is active

### Removed
- Bookmark-based sidebar entry and all related code

## v0.2.1
### Fixed
- Installer now aborts cleanly when a release is missing (credit @sour-source)
- Missing icon for mounted ISO images (credit @sour-source)

## v0.2.0
### Added
- Internationalization support (i18n)
- Arabic translations (credit @e6ad2020)
- French translations

### Fixed
- Nautilus inherits terminal locale on restart instead of GNOME session locale
