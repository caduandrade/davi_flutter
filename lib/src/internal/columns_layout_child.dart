import 'package:davi/src/internal/columns_layout.dart';
import 'package:davi/src/internal/columns_layout_parent_data.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:meta/meta.dart';

@internal
class ColumnsLayoutChild<DATA>
    extends ParentDataWidget<ColumnsLayoutParentData> {
  ColumnsLayoutChild({
    required this.index,
    required super.child,
  }) : super(key: ValueKey(index));

  final int index;

  @override
  void applyParentData(RenderObject renderObject) {
    assert(renderObject.parentData is ColumnsLayoutParentData);
    final ColumnsLayoutParentData parentData =
        renderObject.parentData! as ColumnsLayoutParentData;
    if (index != parentData.index) {
      parentData.index = index;
      renderObject.parent?.markNeedsLayout();
    }
  }

  @override
  Type get debugTypicalAncestorWidgetClass => ColumnsLayout;

  @override
  void debugFillProperties(DiagnosticPropertiesBuilder properties) {
    super.debugFillProperties(properties);
    properties.add(DiagnosticsProperty<Object>('index', index));
  }
}
