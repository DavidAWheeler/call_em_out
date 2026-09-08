# Upstream issue and feature handoff

`call_em_out` is an extension over Nautilus's private GTK widget tree. This
document maps the upstream requests that shaped the fork to the code that
implements them, so a future maintainer can reproduce a fix without guessing.

## Column View interaction work

- **Keyboard navigation — [#91](https://github.com/yannmasoch/nautilus-my-computer/issues/91):** start in `column_view.py` at `_on_key_pressed`, `_move_column_selection`, `_focus_child_column`, and `_open_selection`. Window-level capture and shortcut routing are in `main.py` (`_on_window_key_capture`). Preserve `focused_index` as the source of truth for arrows, Backspace, and Enter. Run `tests/test_column_interactions.py` after changing it.
- **Multi-selection — [#178](https://github.com/yannmasoch/nautilus-my-computer/issues/178):** selection anchors and range semantics are in `widgets.py` (`MyComputerColumn`) and pointer dispatch is in `column_view.py` (`_on_row_pressed`, `_on_row_released`). Drag snapshots must restore both the selection and preview when a drag is cancelled.
- **Drag and drop — [#154](https://github.com/yannmasoch/nautilus-my-computer/issues/154):** destination hit testing and action choice are `_on_column_drop_motion`, `_on_column_drop`, and `_perform_drop` in `column_view.py`; row and blank-space targets are `MyComputerColumnRow`/`MyComputerColumn` in `widgets.py`. Same-filesystem drops default to MOVE, remote drops to COPY, and the cursor action must match the operation sent to Nautilus.
- **Text/config previews — [#155](https://github.com/yannmasoch/nautilus-my-computer/issues/155):** preview detection and rendering are `MyComputerPreviewColumn._is_text_preview_type`, `_load_text_preview`, and `_load_html_preview` in `widgets.py`. Keep HTML parsing read-only and bounded.
- **Default Column View — [#102](https://github.com/yannmasoch/nautilus-my-computer/issues/102):** preference and startup routing are in `nautilus_prefs.py` and `column_view.py` (`_maybe_auto_elect_column_view`, `reset`, and slot synchronization). Virtual locations must continue to fall back to native Nautilus views when the extension cannot represent them.
- **Persistent drive/partition ordering — [#81](https://github.com/yannmasoch/nautilus-my-computer/issues/81):** card ordering and persistence are in `my_computer_view.py` and `nautilus_prefs.py`. Keep the ordering key stable when adding or removing a device.

## Fork-specific fixes that overlap upstream behavior

- **Selection, preview, and horizontal visibility:** `column_view.py` owns
  `focused_index`, `_align_to_viewport_pos`, `_sync_column_selections`, and
  `_restore_drag_selection`. If a new navigation path changes the blue row,
  update those state transitions together; changing only the scroll animation
  leaves keyboard focus behind.
- **Non-destructive directory updates:** `widgets.py` coalesces membership
  events and updates rows in place when URI/name/order are unchanged. Do not
  replace the whole model for a metadata-only event; that causes the visible
  blanking and focus loss this fork was created to remove.
- **Default applications and archive members:** MIME opening is centralized in
  `widgets._open_file_with_default_app` and archive browsing/materialization is
  in `column_view.py` (`_browse_archive`, `_open_archive_member`). Keep archive
  members in a private temporary file before handing them to the desktop MIME
  handler.

## Safe change procedure

1. Read the relevant row above, then inspect the current implementation and
   its regression tests before changing a signal or action name.
2. Add a focused regression test for the state transition (selection, URI,
   action, or model identity), rather than a screenshot-only assertion.
3. Run `python3 -m py_compile nautilus-my-computer.py nautilus_my_computer/*.py`,
   `DISPLAY=:97 python3 -m unittest discover -s tests -q`, `git diff --check`,
   and `sh -n install.sh`.
4. Fetch upstream and compare the changed functions before merging. Preserve
   fork-only behavior such as Recent/Trash Column View, archive member
   materialization, and non-destructive refreshes. Never replace the fork's
   `main` wholesale with upstream `main`.

## Menu ownership decisions

The hamburger is the application-level entry point, so it now contains New
Folder and a context-aware View submenu. The pathbar three-dot button is kept
as the current-folder menu: GNOME's breadcrumb pattern uses that affordance
for actions on the folder being shown (bookmark, paste, properties, and
similar operations). Do not remove it merely because some entries overlap;
future changes should reduce duplication only when the native menu exposes a
clear, supported way to distinguish global actions from current-folder
actions.

Requests deliberately deferred in this fork include Finder tags (#157), date
grouping (#142), per-folder view profiles/application icons (#179),
capacity-dependent disk colors (#129), separate XDG sidebar sections (#164),
and address completion on `computer:///` (#85). These require product or
private-Nautilus work beyond the Column View interaction layer.
