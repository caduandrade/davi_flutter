import 'package:easy_table/src/internal/header_widget.dart';
import 'package:easy_table/src/internal/layout_child_id.dart';
import 'package:easy_table/src/internal/row_callbacks.dart';
import 'package:easy_table/src/internal/rows_builder.dart';
import 'package:easy_table/src/internal/table_layout_parent_data.dart';
import 'package:easy_table/src/internal/table_layout.dart';
import 'package:easy_table/src/internal/table_layout_settings.dart';
import 'package:easy_table/src/internal/table_corner.dart';
import 'package:easy_table/src/internal/table_scrollbar.dart';
import 'package:easy_table/src/model.dart';
import 'package:easy_table/src/row_color.dart';
import 'package:easy_table/src/row_hover_listener.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:meta/meta.dart';

@internal
class TableLayoutChild<ROW> extends ParentDataWidget<TableLayoutParentData> {
  factory TableLayoutChild.header(
      {required TableLayoutSettings layoutSettings,
      required EasyTableModel<ROW>? model,
      required bool resizable,
      required bool multiSort}) {
    return TableLayoutChild._(
        id: LayoutChildId.header,
        child: model != null
            ? HeaderWidget(
                layoutSettings: layoutSettings,
                model: model,
                resizable: resizable,
                multiSort: multiSort)
            : Container());
  }

  factory TableLayoutChild.rows(
      {required EasyTableModel<ROW>? model,
      required TableLayoutSettings layoutSettings,
      required bool scrolling,
      required OnRowHoverListener? onHover,
      required RowCallbacks<ROW> rowCallbacks,
      required EasyTableRowColor<ROW>? rowColor,
      required Widget? lastRowWidget}) {
    return TableLayoutChild._(
        id: LayoutChildId.rows,
        child: RowsBuilder<ROW>(
            model: model,
            layoutSettings: layoutSettings,
            onHover: onHover,
            rowCallbacks: rowCallbacks,
            scrolling: scrolling,
            rowColor: rowColor,
            lastRowWidget: lastRowWidget));
  }

  factory TableLayoutChild.bottomCorner() {
    return TableLayoutChild._(
        id: LayoutChildId.bottomCorner, child: const TableCorner(top: false));
  }

  factory TableLayoutChild.topCorner() {
    return TableLayoutChild._(
        id: LayoutChildId.topCorner, child: const TableCorner(top: true));
  }

  factory TableLayoutChild.leftPinnedHorizontalScrollbar(
      TableScrollbar scrollbar) {
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
      final AbstractNode? targetParent = renderObject.parent;
      if (targetParent is RenderObject) {
        targetParent.markNeedsLayout();
      }
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
