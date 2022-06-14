import 'package:easy_table/src/experimental/layout_v2/table_layout_parent_data_v2.dart';
import 'package:flutter/widgets.dart';

mixin ChildPainterMixinV2 {
  void paintChild(
      {required PaintingContext context,
      required Offset offset,
      required RenderBox? child}) {
    if (child != null) {
      final TableLayoutParentDataV2 parentData =
          child.parentData as TableLayoutParentDataV2;
      context.paintChild(child, parentData.offset + offset);
    }
  }
}
