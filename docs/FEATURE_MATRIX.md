# Feature Matrix

This is the deliberately conservative inventory for the `call_em_out` fork.
It distinguishes behavior supplied by Nautilus itself from behavior added by
the Python extension. A check mark means the code or the native host owns the
behavior; it does not mean every distro/version has identical presentation.

## View comparison

| Capability | Grid view | List view | Column View | Owner/notes |
| --- | --- | --- | --- | --- |
| Browse folders and open files | Native | Native | Extension, using Gio/Nautilus actions | Column View is a Miller-style navigation surface. |
| Single selection | Native | Native | Extension | Selection is model-backed and survives recycled ListView rows. |
| Ctrl/Shift multi-selection | Native | Native | Not yet supported | This is a real feature gap, not just a missing shortcut. |
| Drag files to another folder | Native | Native | Not yet supported | The extension does not currently install file drag sources/drop targets for column rows. |
| Rename | Native | Native | Extension, routed through Nautilus file operations | F2 and the row context menu are supported. |
| Move to Trash/Delete | Native | Native | Extension, routed through Nautilus undo-aware operations | Delete targets the focused Column View item. |
| Copy/Cut/Paste | Native | Native | Extension bridge | Uses the standard GTK file-list clipboard and mirrors native cut state. |
| Copy/Move to destination | Native | Native | Extension | Destination selection uses the Nautilus file chooser. |
| New folder | Native | Native | Extension | Ctrl+Shift+N and the background context menu are supported. |
| New document from template | Native | Native | Extension | Available from a Column View background menu when templates exist. |
| Bookmark/unbookmark | Native | Native | Extension bridge | The row context menu toggles Nautilus bookmarks. |
| Create a bookmark from an arbitrary folder | Native | Native | Partial | Existing bookmark toggling is supported; the full native bookmark-management UI remains Nautilus-owned. |
| Sort by name, modified time, size, or type | Native | Native | Extension | Column View has a persistent global sort and follows Nautilus folder-before-file behavior. |
| Per-folder sort settings | Native | Native | Not yet supported | Column View intentionally uses one global setting today. |
| View options and zoom | Native | Native | Extension integration | The extension owns the Column View options surface and syncs native settings where possible. |
| Keyboard navigation | Native | Native | Extension | Arrows, Home/End, Page Up/Down, Enter, Backspace, and relevant Nautilus accelerators are handled. |
| Middle-click background tab | Native | Native | Extension | Column rows can open a background tab. |
| Context menu | Native | Native | Extension | Menus reuse Nautilus actions where the host exposes them. |
| Preview pane | Native | Native | Extension | The trailing preview column is rebuilt from the selected path. |
| Resizable columns | N/A | N/A | Extension | Folder-column widths can be dragged and persist while navigating the chain. |
| Persistent navigation chain | N/A | N/A | Extension | The current path remains visible as a set of columns. |

## Plugin additions outside Column View

These are part of My Computer rather than changes to Nautilus itself:

- Computer view with grouped local, removable, optical, system, and network
  storage.
- Mount, unmount, eject, usage bars, live volume refresh, and open-with actions.
- Preferred Folders, including pinning and drag-to-reorder.
- Sidebar visibility controls and custom symbolic bookmark icons.
- Startup-on-Computer preference and configurable usage-bar color/gradient.
- Light/dark theme, icon-theme, localization, and RTL integration.

## Nautilus integration boundary

Nautilus does not expose a public API for third-party custom views. The
extension therefore injects widgets into Nautilus's internal widget tree and
coordinates with the real slot location, view-mode switcher, view options, file
models, clipboard, and file-operation APIs. No patched Nautilus source is
included in this repository at this time. That means:

- The fork can be installed without replacing the system Nautilus binary.
- A Nautilus update can change internal widget names or ownership and require a
  compatibility fix.
- File operations remain delegated to Nautilus/GIO wherever possible.
- A future native Nautilus implementation could retire the injection layer;
  until then, the compatibility code is the supported integration point.

## Easy wins for the next milestone

1. Add multi-selection to the Column View model and preserve it across row
   recycling, keyboard navigation, and chain rebuilds.
2. Add file drag sources and folder drop targets, including copy/move modifier
   semantics and visual drop feedback.
3. Reuse Nautilus's per-folder sort settings instead of the current global
   Column View sort.
4. Add focused regression tests around selection, chain trimming, and a drop
   into a folder whose enumeration is still pending.

The first two items are intentionally not presented as complete until they are
implemented and manually verified against native Nautilus behavior.
