# Fork feature matrix

`call_em_out` is a ramshackle personal fork of the [original project](https://github.com/yannmasoch/nautilus-my-computer), aimed at making its Column View more comfortable. The percentages below describe this fork's progress toward that personal workflow. They do not rate the original project.

| Area | Progress | Current functionality | Current bugs | Next up | Reach goal |
| --- | ---: | --- | --- | --- | --- |
| Arrow navigation | 95% | Left/Right and vertical movement, ranges, smooth Back scrolling, retained child columns | Very long chains still depend on GTK animation timing | Stress long and rapidly changing chains | Arrow, Back, path bar, and sidebar feel identical |
| Keyboard shortcuts | 95% | Ctrl+A/C/X/V/F, Ctrl+1/2/3, F2, Delete, Enter, Backspace | Link creation has no Column View shortcut | Decide whether link creation belongs in this personal fork | No swallowed or duplicated shortcuts |
| Copy / paste | 95% | Multi-item copy/cut/paste uses Nautilus operations and monitored refresh | Permission-escalation UX remains Nautilus/GIO dependent | Exercise protected destinations | Native parity |
| Drag and drop | 94% | Multi-file sources, local/NAS move default, genuinely remote copy default, direct folder rows, hover-open, Trash drag-out, and pre-drag selection plus preview restoration on cancel | Cancelling a materialized Trash drag can leave its file in the user cache | Restore cancelled staging files to Trash | Native semantics everywhere |
| Multi-selection | 95% | Ctrl toggle, Shift ranges, Ctrl+Shift ranges, Ctrl+A, refresh-safe anchors, group Trash | Accessibility announcements not audited | Manual AT-SPI review | Native parity |
| Search | 97% | Results and nested folders share the ordinary Miller chain; hidden entries follow Show Hidden Files with a single-query empty-result opt-in; Enter stays in search; previews show full paths | Bounded to four levels and 200 matches; native history and worker cancellation need further work | Add explicit scope controls | Fast complete search with native-quality scope controls |
| Recent columns | 78% | Recent aliases resolve to actual file URIs; previews show the full path; Go to Containing Folder is verified live | Complete file-operation coverage remains to be tested | Exercise rename, move, and stale recent entries | Full Recent parity |
| Focus when navigating back | 96% | Back and Backspace walk Search/Recent result columns before leaving the special root; normal Back scrolls to the ancestor while retaining an on-deck deeper branch | Rapid mixed Back/path-bar input needs more stress testing | Add a navigation-fuzz harness | Deterministic focus and scroll |
| Column View default | 90% | Persistent default, Ctrl+3, and forced Column View for Trash | Unsupported Nautilus virtual locations still fall back | Audit every GVfs scheme | Safe default with native fallback |
| Instant updates | 92% | Monitor events clear stale rows immediately; generation guards prevent old enumerations from duplicating content | Very high event storms still coalesce through one idle callback | Stress rename/move storms | Every displayed change appears immediately |
| Responsive resizing | 90% | Preview is capped; growing the window reduces horizontal offset to reveal hidden columns | Theme-dependent pane handles can affect exact geometry | Test more themes and scale factors | Resizing always prioritizes columns |
| Preview content | 96% | Larger filename-first layout, bordered plain-text/config/code excerpts, safe structured HTML reader view, images, 1024-tier PDF thumbnails, full paths, and bottom-pinned containing-folder action | PDF rendering still depends on the installed GNOME thumbnailer | Add optional document renderers behind a cheap capability check | Readable previews without opening a second window |
| Trash Column View | 92% | Real columns, immediate removal, drag-in/out, normal-URI staging, modified/Trash/original metadata, red permanent delete, green Restore | Cancelled drag staging cleanup remains | Restore staged items when a drag is cancelled | Consistent Trash navigation and operations |
| Header layout | 95% | Search follows Forward, bounded input replaces the path surface, View Options has a sort glyph, hamburger sits beside window controls | Private Nautilus widget names can change between releases | Add version-specific probes | Stable layout across supported Nautilus versions |
| Card ordering | 92% | Pinned folders are drag-reorderable; drive and partition cards persist context-menu ordering | Drive cards do not yet drag-reorder | Add direct card dragging if it remains unambiguous beside file drag/drop | One predictable ordering model for every Computer group |
| Duplicate/blank view prevention | 95% | Enumeration generations and atomic model replacement prevent duplicates; bookmark resets clear stale horizontal offsets | Event-storm coverage is finite | Add repeated external-operation soak test | No duplicate rows or hidden blank viewport |
| Startup and Home routing | 98% | Startup hands off its optional Computer redirect once; sidebar destinations explicitly re-root, reset horizontal scroll, and reconcile the active slot after cold-start callback races | Still relies on Nautilus's private sidebar row model | Extend the live compatibility probe across supported Nautilus versions | Home and Computer always agree with the selected sidebar row |

The fork remains an extension over Nautilus's private widget tree. No Nautilus source is claimed or bundled here; upstream attribution stays with the original project.

## Upstream request review

The open upstream requests were reviewed on 2026-09-06. The requests that
directly match this fork's Column View work are implemented here: keyboard
navigation ([#91](https://github.com/yannmasoch/nautilus-my-computer/issues/91)),
multi-selection ([#178](https://github.com/yannmasoch/nautilus-my-computer/issues/178)),
drag and drop ([#154](https://github.com/yannmasoch/nautilus-my-computer/issues/154)),
text/config previews ([#155](https://github.com/yannmasoch/nautilus-my-computer/issues/155)),
default Column View ([#102](https://github.com/yannmasoch/nautilus-my-computer/issues/102)),
and persistent drive/partition ordering
([#81](https://github.com/yannmasoch/nautilus-my-computer/issues/81)).

The remaining open requests are deliberately outside this pass. Finder tags
(#157), date grouping (#142), per-folder view profiles and application icons
(#179), capacity-dependent disk colors (#129), and separate XDG sidebar
sections (#164) are independent product features rather than gaps in the
interaction work above. Address completion on `computer:///` (#85) requires a
private Nautilus method that is not exposed to Python; guessing at that widget
state would make the startup and Home routing less reliable. Sidebar width
(#156) and Computer/Network icon sizing (#86) are presentation preferences and
need a coherent preferences design before adding more one-off settings.
