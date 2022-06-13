import 'package:easy_table/src/experimental/content_area_id.dart';
import 'package:easy_table/src/experimental/scroll_bar_exp.dart';
import 'package:easy_table/src/experimental/layout_child_key.dart';
import 'package:easy_table/src/experimental/layout_child_type.dart';
import 'package:easy_table/src/experimental/table_corner.dart';
import 'package:easy_table/src/experimental/table_layout_exp.dart';
import 'package:easy_table/src/experimental/table_layout_parent_data_exp.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';

class LayoutChild extends ParentDataWidget<TableLayoutParentDataExp> {
  factory LayoutChild.header(
      {required ContentAreaId contentAreaId,
      required int column,
      required Widget child}) {
    return LayoutChild._(
        type: LayoutChildType.header,
        contentAreaId: contentAreaId,
        row: null,
        column: column,
        child: child);
  }

  factory LayoutChild.cell(
      {required ContentAreaId contentAreaId,
      required int row,
      required int column,
      required Widget child}) {
    return LayoutChild._(
        type: LayoutChildType.cell,
        contentAreaId: contentAreaId,
        row: row,
        column: column,
        child: child);
  }

  factory LayoutChild.bottomCorner() {
    return LayoutChild._(
        type: LayoutChildType.bottomCorner,
        contentAreaId: null,
        row: null,
        column: null,
        child: const TableCorner(top: false));
  }

  factory LayoutChild.topCorner() {
    return LayoutChild._(
        type: LayoutChildType.topCorner,
        contentAreaId: null,
        row: null,
        column: null,
        child: const TableCorner(top: true));
  }

  factory LayoutChild.horizontalScrollbar(
      {required ContentAreaId contentAreaId,
      required EasyTableScrollBarExp child}) {
    return LayoutChild._(
        type: LayoutChildType.horizontalScrollbar,
        contentAreaId: contentAreaId,
        row: null,
        column: null,
        child: child);
  }

  factory LayoutChild.verticalScrollbar({required Widget child}) {
    return LayoutChild._(
        type: LayoutChildType.verticalScrollbar,
        contentAreaId: null,
        row: null,
        column: null,
        child: child);
  }

  LayoutChild._({
    required LayoutChildType type,
    required ContentAreaId? contentAreaId,
    required int? row,
    required int? column,
    required Widget child,
  }) : super(
            key: LayoutChildKey(
                type: type,
                contentAreaId: contentAreaId,
                row: row,
                column: column),
            child: child);

  @override
  void applyParentData(RenderObject renderObject) {
    assert(renderObject.parentData is TableLayoutParentDataExp);
    final TableLayoutParentDataExp parentData =
        renderObject.parentData! as TableLayoutParentDataExp;
    LayoutChildKey layoutChildKey = key as LayoutChildKey;
    if (parentData.key != layoutChildKey) {
      parentData.key = layoutChildKey;
      final AbstractNode? targetParent = renderObject.parent;
      if (targetParent is RenderObject) {
        targetParent.markNeedsLayout();
      }
    }
  }

  @override
  Type get debugTypicalAncestorWidgetClass => TableLayoutExp;

  @override
  void debugFillProperties(DiagnosticPropertiesBuilder properties) {
    super.debugFillProperties(properties);
    LayoutChildKey layoutChildKey = key as LayoutChildKey;
    properties.add(DiagnosticsProperty<Object>('type', layoutChildKey.type));
    properties.add(DiagnosticsProperty<Object>(
        'contentAreaId', layoutChildKey.contentAreaId));
    properties.add(DiagnosticsProperty<Object>('row', layoutChildKey.row));
    properties
        .add(DiagnosticsProperty<Object>('column', layoutChildKey.column));
  }
}
