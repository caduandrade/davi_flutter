import 'package:easy_table/src/experimental/table_layout_exp.dart';
import 'package:flutter/widgets.dart';

/// The [TableLayoutExp] element.
class TableLayoutElementExp extends MultiChildRenderObjectElement {
  TableLayoutElementExp(TableLayoutExp widget) : super(widget);

  @override
  void debugVisitOnstageChildren(ElementVisitor visitor) {
    for (var child in children) {
      if (child.renderObject != null) {
        visitor(child);
      }
    }
  }
}
