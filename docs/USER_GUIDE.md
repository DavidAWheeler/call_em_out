# Like spicy My Computer for Nautilus

This is like spicy My Computer for Nautilus: a respectful personal fork of [My Computer for Nautilus](https://github.com/yannmasoch/nautilus-my-computer). It keeps the original Computer panel and Column View, then makes selected interactions more practical for a personal desktop. It does not add the original Column View or replace Nautilus.

## Current improvements

Column View has model-backed Ctrl-click toggles, Shift-click and Shift-arrow ranges, Ctrl+A, multi-file drag sources, native copy/move/link negotiation, folder hover navigation, refresh-safe selection, group-aware Move to Trash, and a capped preview width. The extension continues to use Nautilus and GIO for file operations.

The original project remains the reference for installation, upstream behavior, translations, and general architecture. Native Grid and List views remain the fallback when a behavior is not yet reliable in this fork.

## Shortcuts and interaction

`Ctrl+3` selects Column View. `Left` and `Right` move between columns; vertical arrows move within a column; `Shift` extends a range; `Ctrl+A` selects all; `Enter` opens the current item; `Backspace` requests the parent; `Ctrl+C`, `Ctrl+X`, and `Ctrl+V` copy, cut, and paste; `F2` renames; `Delete` moves the selected group to Trash.

Dragging a selected group to a native folder uses the destination's normal action negotiation. Ctrl requests copy, Shift requests move, and Ctrl+Shift requests a link where supported. Hovering over a folder is intended to open that folder's next column after a short delay.

## Known limits

Back-button viewport animation and native filesystem-search hand-off still
need live Nautilus polish. Trash columns, preview metadata, and restore/delete
actions are wired, but desktop drag-out may reject a raw `trash:///` URI. A
Nautilus update can change the private widgets this extension integrates with.

See [FEATURE_MATRIX.md](FEATURE_MATRIX.md) for percentages, current behavior, known bugs, next work, and the intended finish line for each feature.
