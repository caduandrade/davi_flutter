import 'package:easy_table/src/experimental/layout_v3/rows/rows_layout.dart';
import 'package:flutter/widgets.dart';

/// The [RowsLayout] element.
class RowsLayoutElementV3 extends MultiChildRenderObjectElement {
  RowsLayoutElementV3(RowsLayout widget) : super(widget);

  @override
  void debugVisitOnstageChildren(ElementVisitor visitor) {
    for (var child in children) {
      if (child.renderObject != null) {
        visitor(child);
      }
    }
  }
}
