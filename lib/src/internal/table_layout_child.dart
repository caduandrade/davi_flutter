import 'package:davi/src/internal/header_widget.dart';
import 'package:davi/src/internal/layout_child_id.dart';
import 'package:davi/src/internal/new/column_notifier.dart';
import 'package:davi/src/internal/new/hover_notifier.dart';
import 'package:davi/src/internal/new/table_content.dart';
import 'package:davi/src/internal/row_callbacks.dart';
import 'package:davi/src/internal/scroll_offsets.dart';
import 'package:davi/src/internal/table_corner.dart';
import 'package:davi/src/internal/table_layout.dart';
import 'package:davi/src/internal/table_layout_parent_data.dart';
import 'package:davi/src/internal/table_layout_settings.dart';
import 'package:davi/src/internal/table_scrollbar.dart';
import 'package:davi/src/trailing_widget_listener.dart';
import 'package:davi/src/last_visible_row_listener.dart';
import 'package:davi/src/model.dart';
import 'package:davi/src/row_color.dart';
import 'package:davi/src/row_cursor_builder.dart';
import 'package:davi/src/row_hover_listener.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:meta/meta.dart';

@internal
class TableLayoutChild<DATA> extends ParentDataWidget<TableLayoutParentData> {
  factory TableLayoutChild.header(
      {required TableLayoutSettings layoutSettings,
      required DaviModel<DATA>? model,
      required bool resizable,
      required HorizontalScrollOffsets horizontalScrollOffsets,
      required bool tapToSortEnabled,
        required ColumnNotifier columnNotifier,
        required HoverNotifier hoverNotifier}) {
    return TableLayoutChild._(
        id: LayoutChildId.header,
        child: model != null
            ? HeaderWidget(
                layoutSettings: layoutSettings,
                model: model,
                horizontalScrollOffsets: horizontalScrollOffsets,
                resizable: resizable,
                tapToSortEnabled: tapToSortEnabled,
        hoverNotifier: hoverNotifier,
        columnNotifier: columnNotifier)
            : Container());
  }

  factory TableLayoutChild.cells({required DaviModel<DATA>? model,
    required TableLayoutSettings layoutSettings,
    required bool scrolling,
    required HorizontalScrollOffsets horizontalScrollOffsets,
    required ScrollController verticalScrollController,
    required OnRowHoverListener? onHover,
    required RowCallbacks<DATA> rowCallbacks,
    required DaviRowColor<DATA>? rowColor,
    required RowCursorBuilder<DATA>? rowCursorBuilder,
    required Widget? trailingWidget,
    required TrailingWidgetListener onTrailingWidget,
    required LastVisibleRowListener onLastVisibleRow,
  required HoverNotifier hoverIndex,
    required bool focusable,
    required FocusNode focusNode}) {
    return TableLayoutChild._(
        id: LayoutChildId.cells,
        child: TableContent(focusNode: focusNode,focusable: focusable,rowCallbacks: rowCallbacks,
        onTrailingWidget: onTrailingWidget,onLastVisibleRow: onLastVisibleRow,trailingWidget: trailingWidget,
        hoverNotifier: hoverIndex,scrolling: scrolling,rowCursorBuilder: rowCursorBuilder,
        model: model, layoutSettings: layoutSettings,horizontalScrollOffsets: horizontalScrollOffsets,
        verticalScrollController: verticalScrollController,
        onHover: onHover)
    );
  }

  factory TableLayoutChild.bottomCorner() {
    return TableLayoutChild._(
        id: LayoutChildId.bottomCorner, child: const TableCorner(top: false));
  }

  factory TableLayoutChild.topCorner() {
    return TableLayoutChild._(
        id: LayoutChildId.topCorner, child: const TableCorner(top: true));
  }

  factory TableLayoutChild.leftPinnedHorizontalScrollbar(Widget scrollbar) {
    return TableLayoutChild._(
        id: LayoutChildId.leftPinnedHorizontalScrollbar, child: scrollbar);
  }

  factory TableLayoutChild.unpinnedHorizontalScrollbar(
      TableScrollbar scrollbar) {
    return TableLayoutChild._(
        id: LayoutChildId.unpinnedHorizontalScrollbar, child: scrollbar);
  }

  factory TableLayoutChild.verticalScrollbar({required Widget child}) {
    return TableLayoutChild._(
        id: LayoutChildId.verticalScrollbar, child: child);
  }

  TableLayoutChild._({
    required this.id,
    required Widget child,
  }) : super(key: ValueKey<LayoutChildId>(id), child: child);

  final LayoutChildId id;

  @override
  void applyParentData(RenderObject renderObject) {
    assert(renderObject.parentData is TableLayoutParentData);
    final TableLayoutParentData parentData =
        renderObject.parentData! as TableLayoutParentData;
    if (id != parentData.id) {
      parentData.id = id;
      renderObject.parent?.markNeedsLayout();
    }
  }

  @override
  Type get debugTypicalAncestorWidgetClass => TableLayout;

  @override
  void debugFillProperties(DiagnosticPropertiesBuilder properties) {
    super.debugFillProperties(properties);
    properties.add(DiagnosticsProperty<Object>('id', id));
  }
}
