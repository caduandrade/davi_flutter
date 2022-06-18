import 'package:easy_table/src/internal/rows_layout.dart';
import 'package:flutter/widgets.dart';
import 'package:meta/meta.dart';

/// The [RowsLayout] element.
@internal
class RowsLayoutElement extends MultiChildRenderObjectElement {
  RowsLayoutElement(RowsLayout widget) : super(widget);

  @override
  void debugVisitOnstageChildren(ElementVisitor visitor) {
    for (var child in children) {
      if (child.renderObject != null) {
        visitor(child);
      }
    }
  }
}
