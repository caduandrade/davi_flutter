import 'package:davi/src/internal/columns_layout.dart';
import 'package:flutter/widgets.dart';
import 'package:meta/meta.dart';

/// The [ColumnsLayout] element.
@internal
class ColumnsLayoutElement extends MultiChildRenderObjectElement {
  ColumnsLayoutElement(ColumnsLayout super.widget);

  @override
  void debugVisitOnstageChildren(ElementVisitor visitor) {
    for (var child in children) {
      if (child.renderObject != null) {
        visitor(child);
      }
    }
  }
}
