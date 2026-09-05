# Like spicy My Computer for Nautilus

`call_em_out` is like spicy My Computer for Nautilus: a personal fork of [My Computer for Nautilus](https://github.com/yannmasoch/nautilus-my-computer). The original project and its author deserve the credit for the extension and its Computer view. This fork keeps that foundation and experiments with a more usable Column View for one desktop setup.

## What this fork changes

- More dependable Ctrl/Shift multi-selection, including selection that survives refreshes.
- Multi-file drag and drop: local moves by default, remote/NAS transfers copy,
  Ctrl copies, and Shift moves.
- Direct folder-row drops plus hover navigation into deeper folders.
- Faster live refresh after file operations and external changes.
- A real Trash Column View with metadata, Restore, Delete Permanently, and
  destination-aware drag-out.
- Header search with live Column View results and file-result previews.
- Sliding Back navigation, safer bookmark jumps, and resize behavior that
  reveals hidden columns before stretching the preview.

The fork does not replace Nautilus or claim to be a new file manager. It makes
the original extension spicier for one personal workflow and keeps native Grid
and List views available. The header integration depends on Nautilus internals
and may need adjustment after Nautilus updates.

Install and usage information is in [docs/USER_GUIDE.md](docs/USER_GUIDE.md). The detailed status is in [docs/FEATURE_MATRIX.md](docs/FEATURE_MATRIX.md).

## Development

```sh
sh -n install.sh
python3 -m py_compile nautilus-my-computer.py nautilus_my_computer/*.py
git diff --check
```

This fork is distributed under the MIT License. See [LICENSE](LICENSE).
