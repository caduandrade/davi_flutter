import 'package:easy_table/src/experimental/column_pin.dart';
import 'package:easy_table/src/experimental/layout_v2/layout_child_key_v2.dart';
import 'package:easy_table/src/experimental/layout_v2/layout_child_type_v2.dart';
import 'package:easy_table/src/experimental/table_corner.dart';
import 'package:easy_table/src/experimental/layout_v2/table_layout_v2.dart';
import 'package:easy_table/src/experimental/layout_v2/table_layout_parent_data_v2.dart';
import 'package:easy_table/src/experimental/table_scrollbar.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';

class LayoutChildV2 extends ParentDataWidget<TableLayoutParentDataV2> {
  factory LayoutChildV2.header(
      {required ColumnPin contentAreaId,
      required int column,
      required Widget child}) {
    return LayoutChildV2._(
        type: LayoutChildTypeV2.header,
        contentAreaId: contentAreaId,
        row: null,
        column: column,
        child: child);
  }

  factory LayoutChildV2.cell(
      {required ColumnPin contentAreaId,
      required int row,
      required int column,
      required Widget child}) {
    return LayoutChildV2._(
        type: LayoutChildTypeV2.cell,
        contentAreaId: contentAreaId,
        row: row,
        column: column,
        child: child);
  }

  factory LayoutChildV2.bottomCorner() {
    return LayoutChildV2._(
        type: LayoutChildTypeV2.bottomCorner,
        contentAreaId: null,
        row: null,
        column: null,
        child: const TableCorner(top: false));
  }

  factory LayoutChildV2.topCorner() {
    return LayoutChildV2._(
        type: LayoutChildTypeV2.topCorner,
        contentAreaId: null,
        row: null,
        column: null,
        child: const TableCorner(top: true));
  }

  factory LayoutChildV2.horizontalScrollbar(
      {required ColumnPin contentAreaId,
      required TableScrollbar child}) {
    return LayoutChildV2._(
        type: LayoutChildTypeV2.horizontalScrollbar,
        contentAreaId: contentAreaId,
        row: null,
        column: null,
        child: child);
  }

  factory LayoutChildV2.verticalScrollbar({required Widget child}) {
    return LayoutChildV2._(
        type: LayoutChildTypeV2.verticalScrollbar,
        contentAreaId: null,
        row: null,
        column: null,
        child: child);
  }

  LayoutChildV2._({
    required LayoutChildTypeV2 type,
    required ColumnPin? contentAreaId,
    required int? row,
    required int? column,
    required Widget child,
  }) : super(
            key: LayoutChildKeyV2(
                type: type,
                contentAreaId: contentAreaId,
                row: row,
                column: column),
            child: child);

  @override
  void applyParentData(RenderObject renderObject) {
    assert(renderObject.parentData is TableLayoutParentDataV2);
    final TableLayoutParentDataV2 parentData =
        renderObject.parentData! as TableLayoutParentDataV2;
    LayoutChildKeyV2 layoutChildKey = key as LayoutChildKeyV2;
    if (parentData.key != layoutChildKey) {
      parentData.key = layoutChildKey;
      final AbstractNode? targetParent = renderObject.parent;
      if (targetParent is RenderObject) {
        targetParent.markNeedsLayout();
      }
    }
  }

  @override
  Type get debugTypicalAncestorWidgetClass => TableLayoutV2;

  @override
  void debugFillProperties(DiagnosticPropertiesBuilder properties) {
    super.debugFillProperties(properties);
    LayoutChildKeyV2 layoutChildKey = key as LayoutChildKeyV2;
    properties.add(DiagnosticsProperty<Object>('type', layoutChildKey.type));
    properties.add(DiagnosticsProperty<Object>(
        'contentAreaId', layoutChildKey.contentAreaId));
    properties.add(DiagnosticsProperty<Object>('row', layoutChildKey.row));
    properties
        .add(DiagnosticsProperty<Object>('column', layoutChildKey.column));
  }
}
