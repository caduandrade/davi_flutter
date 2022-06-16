import 'package:easy_table/src/experimental/layout_v3/rows/rows_layout_v3.dart';
import 'package:flutter/widgets.dart';

/// The [TableLayoutV2] element.
class RowsLayoutElementV3 extends MultiChildRenderObjectElement {
  RowsLayoutElementV3(RowsLayoutV3 widget) : super(widget);

  @override
  void debugVisitOnstageChildren(ElementVisitor visitor) {
    for (var child in children) {
      if (child.renderObject != null) {
        visitor(child);
      }
    }
  }
}
