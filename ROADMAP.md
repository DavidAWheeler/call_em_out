# Roadmap

Planned fixes, features, and improvements. Subject to change as the project evolves.

---

## Currently
- i18n: update translations for the new sidebar visibility settings
- review and merge pending PRs:
  - #34 fix: don't show Unmount on EFI/system partitions
  - #33 fix: correct zypper package name for openSUSE installer
  - #32 i18n: German translations (supersedes #25)
  - #20 i18n: Korean translations

## Next up
- fix: disk cards update on connect
- fix: update disk bar after file transfer
- fix: compatibility with Zorin OS
- fix: `install.sh` picks `apt` over `dnf` on Fedora when apt/dpkg are present (#27)
- fix: misaligned sidebar icon and text (#22)
- fix: stray Computer icon next to the first tab's title (#29)
- fix: respect Nautilus's "single-click to open" setting on disk cards (#28)

## On the horizon
- feat: drag-and-drop and copy/paste support on disk cards
- feat: keyboard shortcut to jump to Computer view
- feat: progress indicator during mount/unmount
- feat: pin custom folders and other locations (Trash, Starred, etc.) alongside Computer (#30)

## Considering
- feat: custom symbolic icons for user bookmarks (#23)
  extension; tracking in case scope ever broadens
- KDE Dolphin port (#21)

Contributions, suggestions, and translations welcome via Issues.
