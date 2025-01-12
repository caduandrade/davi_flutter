import 'package:davi/src/internal/table_layout.dart';
import 'package:flutter/widgets.dart';
import 'package:meta/meta.dart';

/// The [TableLayout] element.
@internal
class TableLayoutElement extends MultiChildRenderObjectElement {
  TableLayoutElement(TableLayout super.widget);

  @override
  void debugVisitOnstageChildren(ElementVisitor visitor) {
    for (var child in children) {
      if (child.renderObject != null) {
        visitor(child);
      }
    }
  }
}
