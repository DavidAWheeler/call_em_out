# Roadmap

This roadmap reflects planned fixes, features, and improvements. It is subject to change as the project evolves.

---


## v0.2.0 - Internationalization i18n
- feat: i18n architecture with gettext support
- feat: Arabic translations (credit @e6ad2020)
- feat: French translations
- fix: Nautilus inherits terminal locale on restart instead of GNOME session locale

## v0.2.1 - Bug fixes
- fix: installer does not abort on missing release (credit @sour-source)
- fix: missing icon for mounted ISO images (credit @sour-source)

## v0.3.0 - Native sidebar entry
- feat: native Computer button at the top of the left sidebar, replacing the bookmark approach
- feat: right-click context menu on Computer sidebar row (Open, Open in New Tab, Open in New Window, Settings)
- fix: Computer sidebar button selected when Computer view is active
- chore: remove old bookmark and bookmark-related code
- chore: remove Restore Bookmark button from preferences
- refactor: remove dead code (hamburger menu helpers, orphaned functions)

## v0.3.1 - Bug fixes
- fix: startup crash when ~/Templates is non-empty (issue #4)
- fix: RTL gradient direction now resolved by CSS engine via `:dir()` instead of Python-level locale detection (credit @e6ad2020)
- i18n: Arabic translation for Disc Images group (credit @e6ad2020)

## v0.4.0 - Stability & installer
- feat: add Italian, Spanish, Catalan and Portuguese translations (credit @unaibenidorm)
- fix: disk cards not always updating during file transfers
- fix: disk cards not updating when drives are connected or disconnected
- fix: gradient color mode not rendering on GTK 4.6.x (Ubuntu 22.04 LTS and similar)
- fix: startup segfault when Nautilus opens directly to a target directory (credit @e6ad2020, PR #10)
- fix: navigation crash caused by persistent pathbar signal connections (issue #11, credit @unaibenidorm, @e6ad2020)
- refactor: replace `Gtk.Stack` with `Gtk.Overlay` for panel injection
- chore: non-interactive installer with curl | sh interface and VERSION/BRANCH env vars (credit @sour-source)

## v0.5.0 - Disk group system *(in progress)*
- feat: configurable System disk group available in Settings
- refactor: disk group class objects
- UX: reduce space between group label and cards
- UX: adjust top margin of Computer button

## Upcoming
Contributions, suggestions or languages welcome via Issues.
