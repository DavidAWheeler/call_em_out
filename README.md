# Like spicy My Computer for Nautilus

`call_em_out` is like spicy My Computer for Nautilus: a personal fork of [My Computer for Nautilus](https://github.com/yannmasoch/nautilus-my-computer). The original project and its author deserve the credit for the extension and its Computer view. This fork keeps that foundation and experiments with a more usable Column View for one desktop setup.

## What this fork changes

- More dependable Ctrl/Shift multi-selection, including selection that survives refreshes.
- Multi-file drag and drop with native copy, move, and link modifiers.
- Folder hover navigation while dragging.
- Faster live refresh after file operations and external changes.
- Group-aware Move to Trash and a capped preview width while resizing.
- Small focus and viewport adjustments for the personal workflow.

The fork does not replace Nautilus or claim to be a new file manager. It injects the existing Column View into Nautilus and keeps native Grid and List views available. Some behavior still depends on Nautilus internals and remains experimental.

Install and usage information is in [docs/USER_GUIDE.md](docs/USER_GUIDE.md). The detailed status is in [docs/FEATURE_MATRIX.md](docs/FEATURE_MATRIX.md).

## Development

```sh
sh -n install.sh
python3 -m py_compile nautilus-my-computer.py nautilus_my_computer/*.py
git diff --check
```

This fork is distributed under the MIT License. See [LICENSE](LICENSE).
