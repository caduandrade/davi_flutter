import 'package:davi/src/internal/new/cells_layout.dart';
import 'package:flutter/widgets.dart';
import 'package:meta/meta.dart';

/// The [CellsLayout] element.
@internal
class CellsLayoutElement extends MultiChildRenderObjectElement {
  CellsLayoutElement(CellsLayout widget) : super(widget);

  @override
  void debugVisitOnstageChildren(ElementVisitor visitor) {
    for (var child in children) {
      if (child.renderObject != null) {
        visitor(child);
      }
    }
  }
}
