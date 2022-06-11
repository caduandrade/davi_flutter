import 'package:easy_table/src/experimental/table_layout_parent_data_exp.dart';
import 'package:flutter/widgets.dart';

mixin ChildPainterMixin {
  void paintChild(
      {required PaintingContext context,
      required Offset offset,
      required RenderBox? child}) {
    if (child != null) {
      final TableLayoutParentDataExp parentData =
          child.parentData as TableLayoutParentDataExp;
      context.paintChild(child, parentData.offset + offset);
    }
  }
}
