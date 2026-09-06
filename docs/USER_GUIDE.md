# call_em_out user guide

`call_em_out` is a ramshackle attempt to improve the Column View work started by the person who made the plugin we forked: [My Computer for Nautilus](https://github.com/yannmasoch/nautilus-my-computer). It keeps the original Computer panel and Column View, then adds practical experiments for a personal desktop. It does not add the original Column View or replace Nautilus.

## Install it

```sh
git clone https://github.com/DavidAWheeler/call_em_out.git
cd call_em_out
./install.sh
nautilus --quit
```

Reopen Files. The installer is user-local and can be run again after updating the checkout.

## Current improvements

Column View has model-backed Ctrl-click toggles, Shift-click and Shift-arrow
ranges, Ctrl+A, multi-file drag sources, direct folder-row drops, folder hover
navigation, refresh-safe selection, group-aware Move to Trash, and a capped
preview width. Local drag and drop moves by default; Ctrl requests copy and
Shift requests move. Explicitly remote and NAS-mounted transfers copy by
default. The extension continues to use Nautilus and GIO for file operations.

Trash opens in Column View. Selecting an item shows its modified date, Trash
date, and original location, with red **Delete Permanently** and green
**Restore** actions. Dragging out of Trash materializes a normal local file URI
and moves the item to the drop destination, avoiding desktop-shell failures on
raw `trash:///` URLs.

The search button sits directly after Back and Forward. `Ctrl+F` opens or
closes the same header field. Results appear as a live **Search results**
column. Enter runs the typed query without opening the first match. Folder
results keep the result trail visible and open their contents in adjacent
columns; file results show a preview with **Go to Containing Folder**. That
action slides the containing directory in from the right, leaves the previous
trail available for Back, collapses the old preview, and selects the file in
the destination. Changing location with a bookmark, path bar, or history
control closes search cleanly.

Search uses the same rows, selection model, resizable columns, and horizontal
scrolling as folder browsing. A preview follows the last folder column;
it does not cover the results or their children. **Go to Containing Folder**
opens the directory and selects the file. The same button works in Recent,
whose entries resolve to their actual file locations.

The original project remains the reference for installation, upstream behavior, translations, and general architecture. Native Grid and List views remain the fallback when a behavior is not yet reliable in this fork.

## Shortcuts and interaction

`Ctrl+3` selects Column View. `Left` and `Right` move between columns; vertical arrows move within a column; `Shift` extends a range; `Ctrl+A` selects all; `Enter` opens the current item; `Backspace` requests the parent; `Ctrl+C`, `Ctrl+X`, and `Ctrl+V` copy, cut, and paste; `F2` renames; `Delete` moves the selected group to Trash.

Dragging a selected group onto a folder row transfers it directly; waiting on
the row also opens the folder so deeper destinations can be chosen. Back moves
the viewport left one column at a time and leaves the deeper branch mounted
off to the right, with a small on-deck sliver visible. In Search and Recent,
Back first walks the open result columns before leaving that special root.
Clicking a bookmark hard-resets stale horizontal scroll before loading the new
location.

## Known limits

Search intentionally stops after four directory levels or 200 matches. A
Trash drag is materialized when the drag begins, so cancelling a drag can leave
the item in the extension's user cache rather than in Trash; successful drops
move it to the requested destination. Link creation is not offered by Column
View rows. A Nautilus update can change the private widgets this extension
integrates with.

See [FEATURE_MATRIX.md](FEATURE_MATRIX.md) for percentages, current behavior, known bugs, next work, and the intended finish line for each feature.
