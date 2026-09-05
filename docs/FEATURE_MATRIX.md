# Fork feature matrix

`call_em_out` is like spicy My Computer for Nautilus: a personal fork of the [original project](https://github.com/yannmasoch/nautilus-my-computer). The percentages below describe this fork's progress toward a comfortable personal workflow. They do not rate the original project.

| Area | Progress | Current functionality | Current bugs | Next up | Reach goal |
| --- | ---: | --- | --- | --- | --- |
| Arrow navigation | 85% | Left/Right and vertical movement, ranges, focus restoration | Back-button viewport can still snap | Route Back through animated target-column scrolling | Arrow, Back, path bar, and sidebar feel identical |
| Keyboard shortcuts | 80% | Ctrl+A/C/X/V, Ctrl+1/2/3, F2, Delete, Enter, Backspace | Ctrl+F ownership is inconsistent | Make native search activation explicit | No swallowed or duplicated shortcuts |
| Copy / paste | 90% | GTK FileList, cut state, multi-item operations, refresh monitoring | Some context actions remain single-target | Finish unusual destination cases | Native parity |
| Drag and drop | 85% | Multi-file sources, native modifiers, folder targets, hover-open scaffolding | Trash and some nested hover paths need desktop acceptance | Verify every Trash and deep-folder path | Native semantics everywhere |
| Multi-selection | 90% | Ctrl toggle, Shift ranges, Ctrl+Shift ranges, Ctrl+A, refresh-safe anchors | Accessibility announcements not audited | Manual AT-SPI review | Native parity |
| Search | 60% | Computer card filtering is live; Ctrl+F toggles it; Enter keeps the typed query | Native filesystem search still depends on Nautilus's private search page and its toolbar wiring | Finish native search hand-off and result rendering | Button/Ctrl+F toggle search reliably; Enter submits the query unless a suggestion is explicitly chosen |
| Focus when navigating back | 70% | Focus is restored after many rebuilds | Native Back can leave the viewport at the wrong horizontal position | Preserve deeper columns and animate the target left | Deterministic focus and scroll |
| Column View default | 75% | Persistent default setting and Ctrl+3 activation | Special locations, especially Trash, are incomplete | Finish supported special locations | Safe default with native fallback |
| Instant updates | 75% | Directory monitors refresh visible columns and preserve selection | Some notification paths still use a short coalescing delay | Test external rename/move storms | Every displayed change appears immediately |
| Responsive resizing | 75% | Preview width is capped and scroll state is retained | Many-column resize needs more desktop testing | Reveal obscured columns before preview growth | Resizing always prioritizes columns |
| Trash Column View | 35% | Trash can use the shared column host; preview metadata and restore/permanent-delete actions are wired | Desktop drag-out can still reject raw `trash:///` URIs; special-location behavior needs live Nautilus testing | Add a destination-aware Trash drag provider and finish special-location polish | Consistent Trash navigation and operations |

The fork remains an extension over Nautilus's private widget tree. No Nautilus source is claimed or bundled here; upstream attribution stays with the original project.
