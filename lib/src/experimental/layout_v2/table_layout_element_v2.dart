import 'package:easy_table/src/experimental/layout_v2/table_layout_v2.dart';
import 'package:flutter/widgets.dart';

/// The [TableLayoutV2] element.
class TableLayoutElementV2 extends MultiChildRenderObjectElement {
  TableLayoutElementV2(TableLayoutV2 widget) : super(widget);

  @override
  void debugVisitOnstageChildren(ElementVisitor visitor) {
    for (var child in children) {
      if (child.renderObject != null) {
        visitor(child);
      }
    }
  }
}
