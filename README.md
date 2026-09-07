```text
   ____      _ _                        _    ___                  _
  / ___|__ _| | | ___ _ __ ___    ___ | |_ / _ \ _   _| |_         |
 | |   / _` | | |/ _ \ '_ ` _ \  / _ \| __| | | | | | | __|        |
 | |__| (_| | | |  __/ | | | | ||  __/| |_| |_| | |_| | |_         |
  \____\__,_|_|_|\___|_| |_| |_| \___|\__|\___/ \__,_|\__|        |

                 C A L L _ E M _ O U T
        Customized Columns for My Computer for Nautilus

                    .-----.       .-----.
                 .-'  |  | \_____/ |  |  '-.
                /     |  |    _    |  |     \
               |      |  |   / \   |  |      |
               |      |  |  /   \  |  |      |
               |      |  |_/_____|_|  |      |
            ___|______|_______________|______|___
           /_______________________________________\
```

`call_em_out` is a ramshackle attempt to improve the Column View work started by the person who made the plugin we forked: [My Computer for Nautilus](https://github.com/yannmasoch/nautilus-my-computer). The original author deserves credit for the extension, its Computer view, and the Column View foundation. This is a personal set of usability experiments on top of that work.

## Install

Copy and paste:

```sh
git clone https://github.com/DavidAWheeler/call_em_out.git
cd call_em_out
./install.sh
nautilus --quit
```

Open Files again. The installer puts the extension in your user data directory; it does not require copying files by hand.

## What's working

### Browse and navigate

- Search results, nested folders, Recent, and previews use one column layout:
  drill right, keep the parent trail, and preview after the last folder.
- **Go to Containing Folder** slides the destination in from the right,
  selects the file, and returns the pane to ordinary folder browsing.
- Arrow keys begin from the blue selection: the last clicked row, keyboard
  move, restored cancelled-drag selection, or containing-folder destination.
- Sliding Back navigation, including Back inside Search, keeps the next
  column peeking on deck. Bookmark jumps reset stale scroll, and resizing
  reveals hidden columns before stretching the preview.
- Sidebar bookmarks always become the first Column View column, including a
  repeated click on the current location.

### Open and preview

- Files open through the desktop's MIME-default application. Archive members
  open there too: when GVFS cannot give the application a local archive path,
  the selected member is privately materialized first.
- Plain-text, config/code, and safe reader-style HTML previews have the
  filename above a bordered document surface, readable PDF thumbnails, and
  full-path location details.
- Header search uses a stable-width field and live Column View results with
  file-result previews.

### Work with files

- More dependable Ctrl/Shift multi-selection, including selection that
  survives refreshes.
- Multi-file drag and drop: local and mounted-NAS moves by default, genuinely
  remote transfers copy, Ctrl copies, and Shift moves.
- Direct folder-row drops plus hover navigation into deeper folders.
- Faster live refresh after file operations and external changes.
- A real Trash Column View with metadata, Restore, Delete Permanently, and
  destination-aware drag-out.

The fork does not replace Nautilus or claim to be a new file manager. It keeps
native Grid and List views available.

## What needs work

The desktop shell can still choose to show its own drop-action menu for a
cross-application Trash drag; folder drops inside Nautilus are move-only.
Search scope is intentionally bounded, and Recent remains dependent on the
underlying `recent:///` provider's metadata. Pinned folders reorder by drag;
drive and partition cards reorder from their context menus. Private Nautilus
widget names can change between releases.

## What's next

The next useful targets are deeper Recent actions, searchable scope controls,
and compatibility probes for private-header changes.

Install and usage information is in [docs/USER_GUIDE.md](docs/USER_GUIDE.md). The detailed status is in [docs/FEATURE_MATRIX.md](docs/FEATURE_MATRIX.md).

## Development

```sh
sh -n install.sh
python3 -m py_compile nautilus-my-computer.py nautilus_my_computer/*.py
git diff --check
```

This fork is distributed under the MIT License. See [LICENSE](LICENSE).
