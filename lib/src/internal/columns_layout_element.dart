import 'package:easy_table/src/internal/columns_layout.dart';
import 'package:flutter/widgets.dart';
import 'package:meta/meta.dart';

/// The [ColumnsLayout] element.
@internal
class ColumnsLayoutElement extends MultiChildRenderObjectElement {
  ColumnsLayoutElement(ColumnsLayout widget) : super(widget);

  @override
  void debugVisitOnstageChildren(ElementVisitor visitor) {
    for (var child in children) {
      if (child.renderObject != null) {
        visitor(child);
      }
    }
  }
}
