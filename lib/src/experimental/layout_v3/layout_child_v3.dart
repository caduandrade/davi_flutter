import 'package:easy_table/src/experimental/layout_v3/header_v3.dart';
import 'package:easy_table/src/experimental/layout_v3/rows/rows_v3.dart';
import 'package:easy_table/src/experimental/layout_v3/horizontal_scrollbars_layout_v3.dart';
import 'package:easy_table/src/experimental/layout_v3/layout_child_id_v3.dart';
import 'package:easy_table/src/experimental/layout_v3/table_layout_parent_data_v3.dart';
import 'package:easy_table/src/experimental/layout_v3/table_layout_v3.dart';
import 'package:easy_table/src/experimental/metrics/table_layout_settings_v3.dart';
import 'package:easy_table/src/experimental/table_corner.dart';
import 'package:easy_table/src/experimental/table_scrollbar.dart';
import 'package:easy_table/src/model.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';

class LayoutChildV3<ROW> extends ParentDataWidget<TableLayoutParentDataV3> {
  factory LayoutChildV3.header(
      {required TableLayoutSettingsV3<ROW> layoutSettings,
      required EasyTableModel<ROW>? model,
      required bool resizable,
      required bool multiSortEnabled}) {
    return LayoutChildV3._(
        id: LayoutChildIdV3.header,
        child: model != null
            ? HeaderV3(
                layoutSettings: layoutSettings,
                model: model,
                resizable: resizable,
                multiSortEnabled: multiSortEnabled)
            : Container());
  }

  factory LayoutChildV3.rows(
      {required EasyTableModel<ROW>? model,
      required TableLayoutSettingsV3<ROW> layoutSettings}) {
    return LayoutChildV3._(
        id: LayoutChildIdV3.rows,
        child: RowsV3<ROW>(model: model, layoutSettings: layoutSettings));
  }

  factory LayoutChildV3.bottomCorner() {
    return LayoutChildV3._(
        id: LayoutChildIdV3.bottomCorner, child: const TableCorner(top: false));
  }

  factory LayoutChildV3.topCorner() {
    return LayoutChildV3._(
        id: LayoutChildIdV3.topCorner, child: const TableCorner(top: true));
  }

  factory LayoutChildV3.horizontalScrollbars(List<TableScrollbar> scrollbars) {
    return LayoutChildV3._(
        id: LayoutChildIdV3.horizontalScrollbars,
        child: HorizontalScrollbarsLayoutV3(scrollbars: scrollbars));
  }

  factory LayoutChildV3.verticalScrollbar({required Widget child}) {
    return LayoutChildV3._(id: LayoutChildIdV3.verticalScrollbar, child: child);
  }

  LayoutChildV3._({
    required this.id,
    required Widget child,
  }) : super(key: ValueKey<LayoutChildIdV3>(id), child: child);

  final LayoutChildIdV3 id;

  @override
  void applyParentData(RenderObject renderObject) {
    assert(renderObject.parentData is TableLayoutParentDataV3);
    final TableLayoutParentDataV3 parentData =
        renderObject.parentData! as TableLayoutParentDataV3;
    if (id != parentData.id) {
      parentData.id = id;
      final AbstractNode? targetParent = renderObject.parent;
      if (targetParent is RenderObject) {
        targetParent.markNeedsLayout();
      }
    }
  }

  @override
  Type get debugTypicalAncestorWidgetClass => TableLayoutV3;

  @override
  void debugFillProperties(DiagnosticPropertiesBuilder properties) {
    super.debugFillProperties(properties);
    properties.add(DiagnosticsProperty<Object>('id', id));
  }
}
