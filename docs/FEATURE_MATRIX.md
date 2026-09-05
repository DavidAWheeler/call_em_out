# Fork feature matrix

`call_em_out` is like spicy My Computer for Nautilus: a personal fork of the [original project](https://github.com/yannmasoch/nautilus-my-computer). The percentages below describe this fork's progress toward a comfortable personal workflow. They do not rate the original project.

| Area | Progress | Current functionality | Current bugs | Next up | Reach goal |
| --- | ---: | --- | --- | --- | --- |
| Arrow navigation | 95% | Left/Right and vertical movement, ranges, smooth Back scrolling, retained child columns | Very long chains still depend on GTK animation timing | Stress long and rapidly changing chains | Arrow, Back, path bar, and sidebar feel identical |
| Keyboard shortcuts | 95% | Ctrl+A/C/X/V/F, Ctrl+1/2/3, F2, Delete, Enter, Backspace | Link creation has no Column View shortcut | Decide whether link creation belongs in this personal fork | No swallowed or duplicated shortcuts |
| Copy / paste | 95% | Multi-item copy/cut/paste uses Nautilus operations and monitored refresh | Permission-escalation UX remains Nautilus/GIO dependent | Exercise protected destinations | Native parity |
| Drag and drop | 92% | Multi-file sources, local-move default, remote-copy default, direct folder rows, hover-open, Trash drag-out | Cancelling a materialized Trash drag can leave its file in the user cache | Restore cancelled staging files to Trash | Native semantics everywhere |
| Multi-selection | 95% | Ctrl toggle, Shift ranges, Ctrl+Shift ranges, Ctrl+A, refresh-safe anchors, group Trash | Accessibility announcements not audited | Manual AT-SPI review | Native parity |
| Search | 90% | Header toggle, Ctrl+F on/off, live result column, Enter submission, folder traversal, file preview and Go to Folder; Computer searches Home and `/mnt` | Bounded to four levels and 200 matches; no explicit worker cancellation | Add cancellation and configurable scope | Fast complete search with native-quality scope controls |
| Recent columns | 55% | Recent bookmark enumerates and previews items through the Miller host | Folder activation and file operations still depend on Nautilus' `recent:///` provider | Add a dedicated Recent result column with native rename/copy/move/delete actions | Full Recent parity |
| Focus when navigating back | 95% | Back scrolls to the ancestor while retaining the deeper branch and correct current column | Rapid mixed Back/path-bar input needs more stress testing | Add a navigation-fuzz harness | Deterministic focus and scroll |
| Column View default | 90% | Persistent default, Ctrl+3, and forced Column View for Trash | Unsupported Nautilus virtual locations still fall back | Audit every GVfs scheme | Safe default with native fallback |
| Instant updates | 92% | Monitor events clear stale rows immediately; generation guards prevent old enumerations from duplicating content | Very high event storms still coalesce through one idle callback | Stress rename/move storms | Every displayed change appears immediately |
| Responsive resizing | 90% | Preview is capped; growing the window reduces horizontal offset to reveal hidden columns | Theme-dependent pane handles can affect exact geometry | Test more themes and scale factors | Resizing always prioritizes columns |
| Trash Column View | 92% | Real columns, immediate removal, drag-in/out, normal-URI staging, modified/Trash/original metadata, red permanent delete, green Restore | Cancelled drag staging cleanup remains | Restore staged items when a drag is cancelled | Consistent Trash navigation and operations |
| Header layout | 95% | Search follows Forward, bounded input replaces the path surface, View Options has a sort glyph, hamburger sits beside window controls | Private Nautilus widget names can change between releases | Add version-specific probes | Stable layout across supported Nautilus versions |
| Duplicate/blank view prevention | 95% | Enumeration generations and atomic model replacement prevent duplicates; bookmark resets clear stale horizontal offsets | Event-storm coverage is finite | Add repeated external-operation soak test | No duplicate rows or hidden blank viewport |

The fork remains an extension over Nautilus's private widget tree. No Nautilus source is claimed or bundled here; upstream attribution stays with the original project.
