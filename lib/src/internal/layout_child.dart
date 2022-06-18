import 'package:easy_table/src/internal/header.dart';
import 'package:easy_table/src/internal/layout_child_id.dart';
import 'package:easy_table/src/internal/row_callbacks.dart';
import 'package:easy_table/src/internal/rows_builder.dart';
import 'package:easy_table/src/internal/table_layout_parent_data.dart';
import 'package:easy_table/src/internal/table_layout.dart';
import 'package:easy_table/src/internal/table_layout_settings.dart';
import 'package:easy_table/src/internal/table_corner.dart';
import 'package:easy_table/src/internal/table_scrollbar.dart';
import 'package:easy_table/src/model.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:meta/meta.dart';

@internal
class LayoutChild<ROW> extends ParentDataWidget<TableLayoutParentData> {
  factory LayoutChild.header(
      {required TableLayoutSettings<ROW> layoutSettings,
      required EasyTableModel<ROW>? model,
      required bool resizable,
      required bool multiSortEnabled}) {
    return LayoutChild._(
        id: LayoutChildId.header,
        child: model != null
            ? Header(
                layoutSettings: layoutSettings,
                model: model,
                resizable: resizable,
                multiSortEnabled: multiSortEnabled)
            : Container());
  }

  factory LayoutChild.rows(
      {required EasyTableModel<ROW>? model,
      required TableLayoutSettings<ROW> layoutSettings,
      required bool scrolling,
      required RowCallbacks<ROW> rowCallbacks}) {
    return LayoutChild._(
        id: LayoutChildId.rows,
        child: RowsBuilder<ROW>(
            model: model,
            layoutSettings: layoutSettings,
            rowCallbacks: rowCallbacks,
            scrolling: scrolling));
  }

  factory LayoutChild.bottomCorner() {
    return LayoutChild._(
        id: LayoutChildId.bottomCorner, child: const TableCorner(top: false));
  }

  factory LayoutChild.topCorner() {
    return LayoutChild._(
        id: LayoutChildId.topCorner, child: const TableCorner(top: true));
  }

  factory LayoutChild.leftPinnedHorizontalScrollbar(TableScrollbar scrollbar) {
    return LayoutChild._(
        id: LayoutChildId.leftPinnedHorizontalScrollbar, child: scrollbar);
  }

  factory LayoutChild.unpinnedHorizontalScrollbar(TableScrollbar scrollbar) {
    return LayoutChild._(
        id: LayoutChildId.unpinnedHorizontalScrollbar, child: scrollbar);
  }

  factory LayoutChild.verticalScrollbar({required Widget child}) {
    return LayoutChild._(id: LayoutChildId.verticalScrollbar, child: child);
  }

  LayoutChild._({
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
