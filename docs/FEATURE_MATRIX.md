# Fork feature matrix

`call_em_out` is a ramshackle personal fork of the [original project](https://github.com/yannmasoch/nautilus-my-computer), aimed at making its Column View more comfortable. The labels below describe confidence in everyday use; they are not false precision about percentage complete.

### Core Column View

| Area | Confidence | What works | Open edge |
| --- | --- | --- | --- |
| Arrow navigation | Active refinement | Left/Right and vertical movement, ranges, smooth Back scrolling, retained child columns; the blue row is the arrow-key origin after clicks, cancelled drags, and containing-folder jumps | Very long chains still depend on GTK animation timing |
| Keyboard shortcuts | Solid | Ctrl+A/C/X/V/F, Ctrl+1/2/3, F2, Delete, Enter, Backspace | Link creation has no Column View shortcut |
| Copy / paste | Solid | Multi-item copy/cut/paste uses Nautilus operations and monitored refresh | Permission escalation remains Nautilus/GIO dependent |
| Drag and drop | Active refinement | Multi-file sources, local/NAS move default, remote copy default, direct folder rows, hover-open, Trash drag-out, and selection/preview restoration on cancel | Cancelled Trash staging cleanup remains |
| Multi-selection | Solid | Ctrl toggle, Shift ranges, Ctrl+Shift ranges, Ctrl+A, refresh-safe anchors, group Trash | Accessibility announcements are not audited |
| Preview content and opening | Active refinement | Filename-first previews, text/config/HTML/image/PDF support, full paths, MIME-default opening, and private archive-member materialization | PDF rendering still depends on the installed thumbnailer |

### Navigation and workspace integration

| Area | Confidence | What works | Open edge |
| --- | --- | --- | --- |
| Search | Active refinement | Results and nested folders share the Miller chain; hidden entries follow Show Hidden Files; previews show full paths; the header field keeps the path bar width while toggled | Search is bounded to four levels and 200 matches |
| Recent columns | Developing | Recent aliases resolve to actual file URIs; previews show full paths; Go to Containing Folder is verified live | Complete file-operation coverage remains to be tested |
| Focus when navigating back | Active refinement | Back and Backspace walk Search/Recent columns before leaving the special root; normal Back scrolls to the ancestor while retaining an on-deck branch | Rapid mixed Back/path-bar input needs more stress testing |
| Column View default | Active refinement | Persistent default, Ctrl+3, and forced Column View for Trash | Unsupported virtual locations fall back to native views |
| Header layout | Active refinement | Search follows Forward, bounded input replaces the path surface, View Options has a sort glyph, hamburger sits beside window controls | Private Nautilus widget names can change |
| Startup and Home routing | Active refinement | Startup redirect handoff, explicit sidebar re-rooting, horizontal reset, and cold-start reconciliation | Still relies on Nautilus's private sidebar row model |

### Reliability and polish

| Area | Confidence | What works | Open edge |
| --- | --- | --- | --- |
| Instant updates | Active refinement | Metadata updates stay in place; creates, deletes, and renames refresh without blanking; generation guards prevent duplicates | Very high event storms still coalesce through one delayed callback |
| Responsive resizing | Active refinement | Preview stays at a predictable utility width; growing the window reveals hidden columns | Theme-dependent pane handles affect exact geometry |
| Trash Column View | Active refinement | Real columns, immediate removal, drag-in/out, URI staging, metadata, red permanent delete, green Restore | Cancelled drag staging cleanup remains |
| Card ordering | Developing | Pinned folders are drag-reorderable; drive and partition ordering persists | Drive cards do not yet drag-reorder |
| Duplicate/blank view prevention | Active refinement | Enumeration generations and atomic model replacement prevent duplicates; bookmark resets clear stale offsets | Event-storm coverage is finite |

The confidence labels mean: **Solid** is stable in the tested path; **Active
refinement** means the main path works with known edge cases; **Developing**
means the feature is useful but still needs meaningful coverage.

The fork remains an extension over Nautilus's private widget tree. No Nautilus
source is claimed or bundled here; upstream attribution stays with the original
project.

## Upstream request review

The request-to-code map and the steps for safely extending it live in
[`docs/UPSTREAM_HANDOFF.md`](UPSTREAM_HANDOFF.md). Keep this matrix focused on
what a user can do; use the handoff when tracing an upstream issue or deciding
where a new fix belongs.
