import 'package:davi/src/internal/cells_layout.dart';
import 'package:davi/src/internal/cells_layout_parent_data.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:meta/meta.dart';

@internal
class CellsLayoutChild<DATA> extends ParentDataWidget<CellsLayoutParentData> {
  factory CellsLayoutChild.cell(
      {required int cellIndex, required Widget child}) {
    return CellsLayoutChild._(
        key: ValueKey<int>(cellIndex), cellIndex: cellIndex, child: child);
  }

  factory CellsLayoutChild.trailing({required Widget child}) {
    return CellsLayoutChild._(
        key: const ValueKey<int>(-1), cellIndex: -1, child: child);
  }

  const CellsLayoutChild._({
    required super.key,
    required this.cellIndex,
    required super.child,
  });

  final int? cellIndex;

  @override
  void applyParentData(RenderObject renderObject) {
    assert(renderObject.parentData is CellsLayoutParentData);
    final CellsLayoutParentData parentData =
        renderObject.parentData! as CellsLayoutParentData;
    if (cellIndex != parentData.cellIndex) {
      parentData.cellIndex = cellIndex;
      renderObject.parent?.markNeedsPaint();
    }
  }

  @override
  Type get debugTypicalAncestorWidgetClass => CellsLayout;

  @override
  void debugFillProperties(DiagnosticPropertiesBuilder properties) {
    super.debugFillProperties(properties);
    properties.add(DiagnosticsProperty<Object>('cellIndex', cellIndex));
  }
}
