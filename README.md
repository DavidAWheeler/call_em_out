# call_em_out

`call_em_out` is a ramshackle attempt to improve the Column View work started by the person who made the plugin we forked: [My Computer for Nautilus](https://github.com/yannmasoch/nautilus-my-computer). The original author deserves credit for the extension, its Computer view, and the Column View foundation. This is a personal set of usability experiments on top of that work.

## Install

Clone this fork, enter its folder, and run:

```sh
./install.sh
nautilus --quit
```

Open Files again. The installer puts the extension in your user data directory; it does not require copying files by hand.

## What's working

- Search results, nested folders, and previews share the ordinary column
  layout: drill right, keep the parent trail, and preview after the last folder.
- **Go to Containing Folder** slides the destination in from the right, keeps
  the prior trail mounted, and selects the file from either Search or Recent.
- More dependable Ctrl/Shift multi-selection, including selection that survives refreshes.
- Multi-file drag and drop: local moves by default, remote/NAS transfers copy,
  Ctrl copies, and Shift moves.
- Direct folder-row drops plus hover navigation into deeper folders.
- Faster live refresh after file operations and external changes.
- A real Trash Column View with metadata, Restore, Delete Permanently, and
  destination-aware drag-out.
- Header search with live Column View results and file-result previews.
- Plain-text previews, with bounded reads that keep older machines responsive.
- Sliding Back navigation, including Back inside Search, keeps the next
  column peeking on deck; bookmark jumps reset stale scroll, and resizing
  reveals hidden columns before stretching the preview.

The fork does not replace Nautilus or claim to be a new file manager. It keeps
native Grid and List views available.

## What needs work

The desktop shell can still choose to show its own drop-action menu for a
cross-application Trash drag; folder drops inside Nautilus are move-only.
Search scope is intentionally bounded, and Recent remains dependent on the
underlying `recent:///` provider's metadata. Pinned folders can be reordered
by dragging; physical drive ordering remains owned by Nautilus. Private widget
names can also change between releases.

## What's next

The next useful targets are deeper Recent actions, searchable scope controls,
user-controlled drive ordering if Nautilus exposes a stable API, and
compatibility probes for private-header changes.

Install and usage information is in [docs/USER_GUIDE.md](docs/USER_GUIDE.md). The detailed status is in [docs/FEATURE_MATRIX.md](docs/FEATURE_MATRIX.md).

## Development

```sh
sh -n install.sh
python3 -m py_compile nautilus-my-computer.py nautilus_my_computer/*.py
git diff --check
```

This fork is distributed under the MIT License. See [LICENSE](LICENSE).
