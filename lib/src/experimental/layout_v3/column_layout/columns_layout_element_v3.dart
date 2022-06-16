import 'package:easy_table/src/experimental/layout_v3/column_layout/columns_layout_v3.dart';
import 'package:flutter/widgets.dart';

/// The [TableLayoutV2] element.
class ColumnsLayoutElementV3 extends MultiChildRenderObjectElement {
  ColumnsLayoutElementV3(ColumnsLayoutV3 widget) : super(widget);

  @override
  void debugVisitOnstageChildren(ElementVisitor visitor) {
    for (var child in children) {
      if (child.renderObject != null) {
        visitor(child);
      }
    }
  }
}
