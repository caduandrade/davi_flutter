import 'package:davi/src/internal/rows_layout.dart';
import 'package:davi/src/internal/rows_layout_parent_data.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:meta/meta.dart';

@internal
class RowsLayoutChild extends ParentDataWidget<RowsLayoutParentData> {
  RowsLayoutChild({
    required this.index,
    required this.last,
    required Widget child,
  }) : super(key: ValueKey<int>(index), child: child);

  final int index;
  final bool last;

  @override
  void applyParentData(RenderObject renderObject) {
    assert(renderObject.parentData is RowsLayoutParentData);
    final RowsLayoutParentData parentData =
        renderObject.parentData! as RowsLayoutParentData;
    if (index != parentData.index || last != parentData.last) {
      parentData.index = index;
      parentData.last = last;
      final AbstractNode? targetParent = renderObject.parent;
      if (targetParent is RenderObject) {
        targetParent.markNeedsLayout();
      }
    }
  }

  @override
  Type get debugTypicalAncestorWidgetClass => RowsLayout;

  @override
  void debugFillProperties(DiagnosticPropertiesBuilder properties) {
    super.debugFillProperties(properties);
    properties.add(DiagnosticsProperty<Object>('index', index));
  }
}
