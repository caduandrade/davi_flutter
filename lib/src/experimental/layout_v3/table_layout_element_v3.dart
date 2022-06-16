import 'package:easy_table/src/experimental/layout_v3/table_layout_v3.dart';
import 'package:flutter/widgets.dart';

/// The [TableLayoutV2] element.
class TableLayoutElementV3 extends MultiChildRenderObjectElement {
  TableLayoutElementV3(TableLayoutV3 widget) : super(widget);

  @override
  void debugVisitOnstageChildren(ElementVisitor visitor) {
    for (var child in children) {
      if (child.renderObject != null) {
        visitor(child);
      }
    }
  }
}
