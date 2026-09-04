# My Computer for Nautilus

This fork adds a Computer view and a Miller-style Column View to GNOME Files
(Nautilus). The fork is called `call_em_out`.

The Column View is implemented as a Python Nautilus extension. It does not
replace the Nautilus executable or include a patched Nautilus source tree.
Because Nautilus does not provide a public API for custom views, the extension
integrates with some internal Nautilus widgets and actions. A Nautilus update
can therefore require compatibility work here.

## Install

On a system with `curl`:

```sh
curl -fsSL https://raw.githubusercontent.com/DavidAWheeler/call_em_out/main/install.sh | sh
```

The installer detects the package manager, installs the Nautilus Python
binding when needed, installs the extension under the user's home directory,
compiles the GSettings schema, and restarts Nautilus.

To install from a checkout instead:

```sh
git clone https://github.com/DavidAWheeler/call_em_out.git
cd call_em_out
./install.sh
```

To remove the extension:

```sh
curl -fsSL https://raw.githubusercontent.com/DavidAWheeler/call_em_out/main/install.sh | sh -s -- --uninstall
```

The installer may use `sudo` to install a system package. The extension and
its settings are otherwise installed for the current user.

## Column View

Press `Ctrl+3`, or choose Column in the view-mode switcher. Selecting a folder
opens its contents in the next column. The open path remains visible across
the window. A preview column appears at the right when a file is selected.

The view supports:

- mouse navigation and single-click folder drill-down;
- keyboard navigation with Left, Right, Up, Down, Home, End, Page Up, and
  Page Down;
- Enter to open the current item and Backspace to move to its parent;
- Shift+Up/Down/Home/End/Page Up/Page Down range selection;
- resizable folder columns;
- sorting by name, modified time, size, or type;
- opening files, new tabs, and new windows;
- rename, move to Trash, copy, cut, paste, and copy/move to another
  destination;
- create folder and create document from template actions;
- bookmark and unbookmark actions;
- a context menu for rows and column backgrounds.

The extension uses Nautilus/GIO file operations for file changes where those
operations are available. Native Grid and List views remain available in the
same window.

## Computer view

The Computer view lists storage grouped as:

- System
- On this Computer
- Removable
- Disc
- Network

It includes mount, unmount, eject, usage, and open-with actions where the
underlying volume supports them. Groups can be shown, hidden, or merged.

Preferred Folders can be pinned and reordered. The sidebar can be customized,
and symbolic icons can be assigned to bookmarks. Settings control startup on
Computer, system-partition visibility, sidebar locations, Preferred Folders,
and usage-bar colors.

## Keyboard behavior

The Column View owns its keyboard focus while it is active. Clicking a row
explicitly returns focus to that column before navigation, which is important
because recycled ListView rows are not focus targets themselves.

Regular vertical arrows move the current item and update the Miller path after
a short debounce. Shift plus a vertical navigation key changes only the
selection range; it does not drill into a folder or rebuild the path until a
regular navigation or activation is requested.

The current selection is stored in the GTK selection model, while the cursor
and range anchor are tracked separately. This keeps selection working when a
large folder scrolls rows in and out of the recycled ListView.

## Current limits

- Column View drag-and-drop is not implemented yet.
- Column View uses one global sort setting rather than a per-folder sort.
- Rename and paste still target the current cursor item rather than every
  selected item; copy, cut, and Delete use the selected range.
- Compatibility depends on Nautilus's internal widget structure and may vary
  between distributions and releases.

These limits are kept explicit so the project does not promise behavior that
has not been tested.

## Development

Run the basic checks from the repository root:

```sh
sh -n install.sh
python3 -m py_compile nautilus-my-computer.py nautilus_my_computer/*.py
git diff --check
```

For Column View changes, test an empty folder, a large folder, a folder with
files and subfolders, a path several levels deep, mouse-to-keyboard handoff,
Left/Right navigation, Shift+arrow range selection, scrolling, rename, and
navigation after a column has been trimmed.

## License

This project is distributed under the MIT License. See [LICENSE](LICENSE).
