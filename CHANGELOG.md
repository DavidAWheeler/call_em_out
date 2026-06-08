# Changelog

All notable changes to this project are documented here.

---

## [0.4.4]
### Fixed
- Installer (`install.sh`) now POSIX `sh` compliant, fixes `curl | sh` failing on systems where `/bin/sh` is `dash` (e.g. Debian, Ubuntu)

## [0.4.3]
### UX
- Fixed a brief flicker of the file view when navigating to Computer

## [0.4.2]
### UX
- Panel now opens in ~20-65ms instead of ~500-600ms

## [0.4.1]
### Internationalization
- Updated Arabic translations (credit @e6ad2020)
- Updated French translations

## [0.4.0]
### Added
- Italian, Spanish, Catalan and Portuguese translations (credit @unaibenidorm)
- Non-interactive installer with `curl | sh`, `VERSION` and `BRANCH` env vars (credit @sour-source)

### Fixed
- Disk cards not updating when drives are connected or disconnected
- Disk cards not updating during active file transfers
- Level bar gradient not rendering on Ubuntu 22.04 LTS and other GTK 4.6.x systems
- Crash on startup when Nautilus opens directly to a folder (credit @e6ad2020, PR #10)
- Navigation crash on pathbar (credit @unaibenidorm, @e6ad2020, issue #11)

## [0.3.1]
### Fixed
- Crash on startup when `~/Templates` is non-empty (issue #4)
- Level bar gradient direction incorrect in RTL languages (credit @e6ad2020)

### Internationalization
- Arabic translation for Disc Images group (credit @e6ad2020)

## [0.3.0]
### Added
- Native Computer button in the left sidebar, replacing the bookmark approach
- Right-click context menu on the Computer sidebar button (Open, Open in New Tab, Open in New Window, Settings)
- Computer sidebar button highlights when Computer view is active

### Removed
- Bookmark-based sidebar entry and all related code

## [0.2.1]
### Fixed
- Installer now aborts cleanly when a release is missing (credit @sour-source)
- Missing icon for mounted ISO images (credit @sour-source)

## [0.2.0]
### Added
- Internationalization support (i18n)
- Arabic translations (credit @e6ad2020)
- French translations

### Fixed
- Nautilus inherits terminal locale on restart instead of GNOME session locale
