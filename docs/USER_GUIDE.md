# My Computer for Nautilus

`call_em_out` adds a Computer panel and a Miller-style Column View to GNOME
Files without replacing the Nautilus executable. It is beta software: the
native grid and list views remain the best choice for drag-and-drop and complex
multi-selection until those Column View features land.

## Install on Ubuntu/Debian

The simplest source install downloads the fork, installs the distro's Nautilus
Python binding if needed, compiles the schema, and restarts Nautilus:

```bash
curl -fsSL https://raw.githubusercontent.com/DavidAWheeler/call_em_out/main/install.sh | sh
```

For an auditable local install:

```bash
git clone https://github.com/DavidAWheeler/call_em_out.git
cd call_em_out
./install.sh
```

The installer is user-local for the extension and schema. It may use `sudo`
only to install the required system package, such as `python3-nautilus`.

To install a specific ref:

```bash
curl -fsSL https://raw.githubusercontent.com/DavidAWheeler/call_em_out/main/install.sh | sh -s -- --version=v0.13.2
```

## Start using Column View

1. Open GNOME Files.
2. Press `Ctrl+3`, or choose the Column segment in the view-mode switcher.
3. Select a folder in a column to open its contents in the next column.
4. Use `Left` and `Right` to move between columns and `Up`/`Down` to move
   within a column.
5. Press `Enter` to open the focused folder or file.
6. Press `Backspace` to move to the parent location.

Column widths can be adjusted by dragging the divider between folder columns.
The trailing preview column shows the selected path's preview when available.

## File actions

Right-click a row for the available actions. The Column View currently
supports opening, opening in a new tab/window, rename, move to Trash, copy,
cut, paste into a folder, copy/move to another destination, bookmark toggling,
and properties. On a column background, the menu can also create a folder,
create a document from a template, paste, or open a terminal.

Useful shortcuts include:

| Shortcut | Action |
| --- | --- |
| `Ctrl+3` | Switch to Column View |
| `F2` | Rename the focused item |
| `Delete` | Move the focused item to Trash |
| `Ctrl+C` / `Ctrl+X` | Copy / cut the focused item |
| `Ctrl+V` | Paste into the focused folder |
| `Ctrl+Shift+N` | Create a folder in the focused column |
| `Enter` | Open the focused item |
| `Backspace` | Navigate to the parent |

For drag-and-drop or selecting several unrelated files, switch temporarily to
native Grid or List View. This limitation is tracked in the feature matrix so
users can see exactly what is and is not implemented.

## Computer panel

Choose **Computer** in the sidebar to see storage grouped by type. Right-click
the Computer sidebar entry for settings. You can show, hide, or merge groups;
control sidebar locations; configure Preferred Folders; choose a usage-bar
color; and opt to start Files on Computer.

Preferred Folders can be pinned from a folder's menu and reordered by dragging.
Bookmark icons can be changed from a bookmark's context menu.

## Troubleshooting

Restart the host after an upgrade:

```bash
nautilus -q
```

Then reopen GNOME Files. If Column View is absent, verify the binding and
extension directory:

```bash
dpkg -l python3-nautilus 2>/dev/null || rpm -q python3-nautilus 2>/dev/null || true
ls "$HOME/.local/share/nautilus-python/extensions"
```

Nautilus versions below 50 may have reduced functionality. Because the plugin
integrates with private Nautilus widget structures, a distro-patched Nautilus
may need a compatibility update even when its version number looks supported.
Please include the distro, Nautilus version, desktop session, and the output of
`nautilus --version` in a bug report.

## Remove it

```bash
curl -fsSL https://raw.githubusercontent.com/DavidAWheeler/call_em_out/main/install.sh | sh -s -- --uninstall
```

This removes the extension and its schema/settings. It does not remove files,
bookmarks, or user data managed by Nautilus.

## Development expectations

Before calling a Column View feature complete, test mouse navigation, keyboard
navigation, a large folder, an empty folder, a slow/network folder, a recycled
row after scrolling, a renamed item, and navigation back through a trimmed
chain. Compare behavior against native Grid/List View and record the Nautilus
version used.
