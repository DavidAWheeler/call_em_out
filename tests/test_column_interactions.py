"""Regression checks using GTK's actual selection model and drag providers.

Run with a GTK display: python3 -m unittest discover -s tests -v
"""

import unittest
from types import SimpleNamespace
from unittest.mock import Mock, patch

from nautilus_my_computer.column_view import _ColumnViewHost
from nautilus_my_computer.widgets import (
    Gdk,
    Gio,
    GLib,
    Gtk,
    MyComputerColumn,
    MyComputerColumnRow,
    MyComputerPreviewColumn,
    _HTMLReaderParser,
    _ColumnRowItem,
)


class ColumnInteractions(unittest.TestCase):
    def setUp(self):
        Gtk.init()
        with patch.object(MyComputerColumn, "_load"):
            self.column = MyComputerColumn(None, "file:///tmp", Mock())
        for i in range(6):
            self.column._store.append(_ColumnRowItem(f"file:///tmp/{i}", str(i), False))

    def selected(self):
        return [item.display_name for item in self.column.selected_items()]

    def test_text_preview_recognizes_plain_text_and_config_formats(self):
        detect = MyComputerPreviewColumn._is_text_preview_type
        self.assertTrue(detect("text/plain", "notes.txt"))
        self.assertTrue(detect("application/octet-stream", "theme.kdl"))
        self.assertTrue(detect("application/json", "settings.data"))
        self.assertFalse(detect("application/pdf", "document.pdf"))

    def test_html_reader_preserves_structure_and_discards_active_content(self):
        parser = _HTMLReaderParser()
        parser.feed(
            "<head><style>bad</style></head><h1>Heading</h1><p>Hello "
            "<strong>reader</strong>.</p><ul><li>One</li><li>Two</li></ul>"
            "<script>also_bad()</script>"
        )
        rendered = "".join(text for _style, text in parser.runs)
        self.assertIn("Heading", rendered)
        self.assertIn("Hello reader.", rendered)
        self.assertIn("• One", rendered)
        self.assertNotIn("bad", rendered)
        self.assertEqual(
            MyComputerPreviewColumn._is_html_preview_type("text/html", "index.html"), True
        )

    def test_control_drop_requests_copy_for_combined_offer(self):
        device = Mock()
        device.get_modifier_state.return_value = Gdk.ModifierType.CONTROL_MASK
        drop = Mock()
        drop.get_device.return_value = device
        drop.get_actions.return_value = Gdk.DragAction.COPY | Gdk.DragAction.MOVE
        target = Mock()
        target.get_current_drop.return_value = drop
        self.assertEqual(_ColumnViewHost._on_column_drop_motion(None, target, 0, 0), Gdk.DragAction.COPY)

    def test_search_back_preserves_columns_and_steps_to_computer(self):
        host = _ColumnViewHost.__new__(_ColumnViewHost)
        host.columns = [Mock(), Mock(), Mock()]
        host.search_result_column = host.columns[0]
        host._history_index = host.focused_index = 2
        host.preview_column = SimpleNamespace(file_uri=None)
        host._finish_location_transition = Mock()
        host._cancel_row_commit = Mock()
        host._apply_focused_column_style = Mock()
        host._focus_column_when_mapped = Mock()
        host._align_to_viewport_pos = Mock()
        host._update_back_button = Mock()
        host.search_toggle = Mock()
        host.search_toggle.get_active.return_value = False
        host._ext = Mock()
        host._win = Mock()
        self.assertTrue(host._back_in_columns())
        self.assertEqual(host.focused_index, 1)
        self.assertEqual(len(host.columns), 3)
        host._align_to_viewport_pos.assert_called_with(host.columns[1], 24)
        host._back_in_columns()
        self.assertEqual(host.focused_index, 0)
        host._back_in_columns()
        host._ext._navigate_current_in_place.assert_called_once_with("computer:///", host._win)

    def test_search_result_uses_real_uri_and_normal_multiselection(self):
        self.column.set_search_results([
            ("first", "file:///tmp/one/first", False),
            ("folder", "file:///tmp/two/folder", True),
        ])
        self.column.select_index(0)
        self.column.select_for_pointer(1, ctrl=True)
        self.assertEqual([i.uri for i in self.column.selected_items()],
                         ["file:///tmp/one/first", "file:///tmp/two/folder"])

    def test_recent_alias_resolves_to_underlying_file(self):
        self.column.folder_uri = "recent:///"
        self.column._ext = SimpleNamespace(_nautilus_prefs=SimpleNamespace(
            hidden_files=lambda: False, sort_directories_first=lambda: False))
        info = Gio.FileInfo()
        info.set_name("opaque-recent-id")
        info.set_display_name("report.txt")
        info.set_file_type(Gio.FileType.REGULAR)
        info.set_icon(Gio.ThemedIcon.new("text-x-generic"))
        info.set_content_type("text/plain")
        info.set_attribute_string("standard::target-uri", "file:///tmp/reports/report.txt")
        self.column._populate_rows([info], {})
        self.column.select_index(0)
        self.assertEqual(self.column.selected_item().uri, "file:///tmp/reports/report.txt")
        self.column.destroy_enumeration()

    def test_control_click_adds_and_removes_without_clearing_others(self):
        self.column.select_index(0)
        self.column.select_for_pointer(3, ctrl=True)
        self.assertEqual(self.selected(), ["0", "3"])
        self.column.select_for_pointer(0, ctrl=True)
        self.assertEqual(self.selected(), ["3"])
        self.column.select_for_pointer(3, ctrl=True)
        self.assertEqual(self.selected(), [])

    def test_shift_click_uses_keyboard_anchor_and_shrinks_range(self):
        self.column.select_index(1)
        self.column.select_for_pointer(4, shift=True)
        self.assertEqual(self.selected(), ["1", "2", "3", "4"])
        self.column.select_for_pointer(2, shift=True)
        self.assertEqual(self.selected(), ["1", "2"])
        self.assertEqual(self.column.selected_index(), 2)

    def test_control_shift_adds_range(self):
        self.column.select_index(0)
        self.column.select_for_pointer(3, ctrl=True)
        self.column.select_for_pointer(5, ctrl=True, shift=True)
        self.assertEqual(self.selected(), ["0", "3", "4", "5"])

    def test_shift_arrow_cancels_delayed_navigation_even_at_boundary(self):
        host = SimpleNamespace(_cancel_row_commit=Mock(), _arm_row_commit=Mock())
        self.column.select_index(4)
        _ColumnViewHost._move_column_selection(host, self.column, Gdk.KEY_Down, extend=True)
        self.assertEqual(self.selected(), ["4", "5"])
        _ColumnViewHost._move_column_selection(host, self.column, Gdk.KEY_Down, extend=True)
        self.assertEqual(self.selected(), ["4", "5"])
        self.assertEqual(host._cancel_row_commit.call_count, 2)
        host._arm_row_commit.assert_not_called()

    def test_plain_press_keeps_group_for_drag(self):
        self.column.select_index(0)
        self.column.select_for_pointer(2, ctrl=True)
        row = SimpleNamespace(uri="file:///tmp/0")
        gesture = Mock()
        gesture.get_current_button.return_value = Gdk.BUTTON_PRIMARY
        gesture.get_current_event_state.return_value = Gdk.ModifierType(0)
        host = SimpleNamespace(_cancel_row_commit=Mock())
        _ColumnViewHost._on_row_pressed(host, gesture, 1, 1, 1, self.column, row)
        self.assertEqual(self.selected(), ["0", "2"])
        gesture.set_state.assert_not_called()

    def test_cancelled_drag_restores_previous_selection(self):
        host = _ColumnViewHost.__new__(_ColumnViewHost)
        host.columns = [self.column]
        host._sync_column_selections = Mock()
        host._apply_focused_column_style = Mock()
        self.column.select_index(1)
        snapshot = (self.column, ["file:///tmp/1"], "file:///tmp/1", 1)
        self.column.select_index(4)
        host._restore_drag_selection(snapshot)
        self.assertEqual(self.column.selected_item().uri, "file:///tmp/1")
        host._sync_column_selections.assert_called_once_with()

    def test_path_sync_clears_failed_drag_highlight(self):
        host = _ColumnViewHost.__new__(_ColumnViewHost)
        child = MyComputerColumn.__new__(MyComputerColumn)
        # Use the real model/selection machinery without starting I/O.
        Gtk.ScrolledWindow.__init__(child)
        child._store = Gio.ListStore(item_type=_ColumnRowItem)
        child._selection = Gtk.MultiSelection(model=child._store)
        child._cursor_index = None
        child._selection_anchor = None
        child.folder_uri = "file:///tmp/Downloads"
        child._store.append(_ColumnRowItem("file:///tmp/Downloads/a", "a", False))
        parent = self.column
        parent.folder_uri = "file:///tmp"
        parent.select_index(2)  # stale failed-drag highlight (not Downloads)
        parent._store.append(_ColumnRowItem("file:///tmp/Downloads", "Downloads", True))
        # Put the committed child target at the end of the parent model.
        host.columns = [parent, child]
        host.preview_column = SimpleNamespace(file_uri=None)
        host._sync_column_selections()
        self.assertEqual(parent.selected_item().uri, "file:///tmp/Downloads")
        self.assertEqual(parent.selected_items(), [parent.selected_item()])

    def test_modifier_click_moves_keyboard_focus_to_its_column(self):
        host = SimpleNamespace(
            _cancel_row_commit=Mock(),
            columns=[object(), self.column],
            focused_index=0,
            _apply_focused_column_style=Mock(),
        )
        gesture = Mock()
        gesture.get_current_button.return_value = Gdk.BUTTON_PRIMARY
        gesture.get_current_event_state.return_value = Gdk.ModifierType.CONTROL_MASK
        _ColumnViewHost._on_row_pressed(
            host, gesture, 1, 1, 1, self.column, SimpleNamespace(uri="file:///tmp/2")
        )
        self.assertEqual(host.focused_index, 1)
        self.assertEqual(self.selected(), ["2"])

    def test_reload_preserves_selection_and_anchor_by_uri_after_sort(self):
        self.column._ext = SimpleNamespace(
            _nautilus_prefs=SimpleNamespace(
                hidden_files=lambda: False, sort_directories_first=lambda: False
            )
        )
        self.column.select_index(1)
        self.column.select_for_pointer(4, ctrl=True)
        with patch.object(MyComputerColumn, "_load"):
            self.column.reload()
            self.column.reload()  # A second settings change while loading.
        infos = []
        for name in ["0", "1", "3", "4", "5"]:
            info = Gio.FileInfo()
            info.set_name(name)
            info.set_display_name(name)
            info.set_file_type(Gio.FileType.REGULAR)
            info.set_icon(Gio.ThemedIcon.new("text-x-generic"))
            info.set_content_type("text/plain")
            infos.append(info)
        self.column._sort = ("name", True)
        self.column._populate_rows(infos, {})
        self.assertEqual(self.selected(), ["4", "1"])
        self.assertEqual(self.column.selected_item().display_name, "4")
        self.column.select_for_pointer(3, shift=True)
        self.assertEqual(self.selected(), ["4", "3", "1"])

    def test_loading_sibling_does_not_clear_existing_selection(self):
        self.column.select_index(0)
        self.column.select_for_pointer(3, ctrl=True)
        with patch.object(MyComputerColumn, "_load"):
            sibling = MyComputerColumn(None, "file:///tmp/other", Mock())
        host = SimpleNamespace(
            columns=[self.column, sibling],
            preview_column=SimpleNamespace(file_uri=None),
            _apply_focused_column_style=Mock(),
            _set_cut_rows=Mock(),
            _pending_child_focus=None,
        )
        _ColumnViewHost._on_column_loaded(host, sibling)
        self.assertEqual(self.selected(), ["0", "3"])

    def test_column_drop_uses_native_move_without_clearing_clipboard(self):
        host = SimpleNamespace(_paste_uris_into_folder=Mock())
        target = SimpleNamespace(_mc_drop_action=Gdk.DragAction.MOVE)
        value = Gdk.FileList.new_from_list([Gio.File.new_for_uri("file:///elsewhere/a")])
        self.assertTrue(_ColumnViewHost._on_column_drop(host, target, value, 0, 0, self.column))
        host._paste_uris_into_folder.assert_called_once_with(
            ["file:///elsewhere/a"], "file:///tmp", cut=True, clear_clipboard=False
        )

    def test_column_drop_rejects_folder_into_itself_or_descendant(self):
        host = SimpleNamespace(_paste_uris_into_folder=Mock())
        target = SimpleNamespace(_mc_drop_action=Gdk.DragAction.COPY)
        for uri in ["file:///tmp", "file:///"]:
            value = Gdk.FileList.new_from_list([Gio.File.new_for_uri(uri)])
            self.assertFalse(
                _ColumnViewHost._on_column_drop(host, target, value, 0, 0, self.column)
            )
        host._paste_uris_into_folder.assert_not_called()

    def test_link_modifier_is_rejected_for_column_destination(self):
        target = Mock()
        target.get_current_drop.return_value.get_device.return_value = None
        target.get_current_event_state.return_value = (
            Gdk.ModifierType.CONTROL_MASK | Gdk.ModifierType.SHIFT_MASK
        )
        target.get_current_drop.return_value.get_actions.return_value = (
            Gdk.DragAction.COPY | Gdk.DragAction.MOVE | Gdk.DragAction.LINK
        )
        self.assertEqual(_ColumnViewHost._on_column_drop_motion(None, target, 0, 0), 0)

    def test_control_a_selects_all_without_navigating(self):
        host = SimpleNamespace(_focused_column=lambda: self.column, _cancel_row_commit=Mock())
        self.assertTrue(
            _ColumnViewHost._on_key_pressed(host, None, Gdk.KEY_a, 0, Gdk.ModifierType.CONTROL_MASK)
        )
        self.assertEqual(self.selected(), [str(i) for i in range(6)])
        self.assertEqual(self.column.selected_index(), 0)

    def test_backend_move_offer_is_honored_without_modifier_event(self):
        target = Mock()
        target.get_current_drop.return_value.get_device.return_value = None
        target.get_current_event_state.return_value = Gdk.ModifierType(0)
        target.get_current_drop.return_value.get_actions.return_value = Gdk.DragAction.MOVE
        self.assertEqual(
            _ColumnViewHost._on_column_drop_motion(None, target, 0, 0), Gdk.DragAction.MOVE
        )

    def drag_uris(self, index):
        row = MyComputerColumnRow()
        row._column = self.column
        row.item = self.column._store.get_item(index)
        provider = row._on_drag_prepare(None, 0, 0)
        clipboard = Gdk.Display.get_default().get_clipboard()
        clipboard.set_content(provider)
        results = []

        def ready(source, result):
            results.append([f.get_uri() for f in source.read_value_finish(result).get_files()])

        clipboard.read_value_async(Gdk.FileList, GLib.PRIORITY_DEFAULT, None, ready)
        while not results:
            GLib.MainContext.default().iteration(True)
        clipboard.set_content(None)
        self.assertFalse(provider.ref_formats().contain_mime_type("x-special/gnome-copied-files"))
        return results[0]

    def test_drag_exports_every_selected_file(self):
        self.column.select_index(0)
        self.column.select_for_pointer(4, ctrl=True)
        self.assertEqual(self.drag_uris(0), ["file:///tmp/0", "file:///tmp/4"])

    def test_drag_of_unselected_row_does_not_export_stale_selection(self):
        self.column.select_index(0)
        self.assertEqual(self.drag_uris(2), ["file:///tmp/2"])


if __name__ == "__main__":
    unittest.main()
