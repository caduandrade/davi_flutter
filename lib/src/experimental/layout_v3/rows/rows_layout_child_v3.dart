import 'package:easy_table/src/experimental/layout_v3/rows/rows_layout_parent_data_v3.dart';
import 'package:easy_table/src/experimental/layout_v3/rows/rows_layout_v3.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';

class RowsLayoutChildV3<ROW> extends ParentDataWidget<RowsLayoutParentDataV3> {

  RowsLayoutChildV3({
    required this.index,
    required Widget child,
  }) : super(key: ValueKey(index), child: child);


  final int index;

  @override
  void applyParentData(RenderObject renderObject) {
    assert(renderObject.parentData is RowsLayoutParentDataV3);
    final RowsLayoutParentDataV3 parentData =
        renderObject.parentData! as RowsLayoutParentDataV3;
    if (index != parentData.index) {
      parentData.index = index;
      final AbstractNode? targetParent = renderObject.parent;
      if (targetParent is RenderObject) {
        targetParent.markNeedsLayout();
      }
    }
  }

  @override
  Type get debugTypicalAncestorWidgetClass => RowsLayoutV3;

  @override
  void debugFillProperties(DiagnosticPropertiesBuilder properties) {
    super.debugFillProperties(properties);
    properties.add(DiagnosticsProperty<Object>('index', index));
  }
}
