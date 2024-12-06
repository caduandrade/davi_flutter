import 'package:davi/src/internal/new/cells_layout.dart';
import 'package:davi/src/internal/new/cells_layout_parent_data.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:meta/meta.dart';

@internal
class CellsLayoutChild<DATA> extends ParentDataWidget<CellsLayoutParentData> {
  static const _CellKey _trailingKey =
      _CellKey(childIndex: -100, rowSpan: -1, columnSpan: -1);

  factory CellsLayoutChild.cell(
      {required int childIndex,
      required int rowIndex,
      required int columnIndex,
      required int rowSpan,
      required int columnSpan,
      required Widget child}) {
    return CellsLayoutChild._(
        key: _CellKey(
            childIndex: childIndex, rowSpan: rowSpan, columnSpan: columnSpan),
        rowIndex: rowIndex,
        columnIndex: columnIndex,
        rowSpan: rowSpan,
        columnSpan: columnSpan,
        child: child);
  }

  factory CellsLayoutChild.trailing({required Widget child}) {
    return CellsLayoutChild._(
        key: _trailingKey,
        rowIndex: -1,
        columnIndex: -1,
        rowSpan: -1,
        columnSpan: -1,
        child: child);
  }

  const CellsLayoutChild._({
    required Key key,
    required this.rowIndex,
    required this.columnIndex,
    required this.rowSpan,
    required this.columnSpan,
    required Widget child,
  }) : super(key: key, child: child);

  final int rowIndex;
  final int? columnIndex;
  final int rowSpan;
  final int columnSpan;

  @override
  void applyParentData(RenderObject renderObject) {
    assert(renderObject.parentData is CellsLayoutParentData);
    final CellsLayoutParentData parentData =
        renderObject.parentData! as CellsLayoutParentData;
    if (rowIndex != parentData.rowIndex) {
      parentData.rowIndex = rowIndex;
      renderObject.parent?.markNeedsPaint();
    }
    if (columnIndex != parentData.columnIndex) {
      parentData.columnIndex = columnIndex;
      renderObject.parent?.markNeedsPaint();
    }
    if (rowSpan != parentData.rowSpan) {
      parentData.rowSpan = rowSpan;
      renderObject.parent?.markNeedsPaint();
    }
    if (columnSpan != parentData.columnSpan) {
      parentData.columnSpan = columnSpan;
      renderObject.parent?.markNeedsPaint();
    }
  }

  @override
  Type get debugTypicalAncestorWidgetClass => CellsLayout;

  @override
  void debugFillProperties(DiagnosticPropertiesBuilder properties) {
    super.debugFillProperties(properties);
    properties.add(DiagnosticsProperty<Object>('rowIndex', rowIndex));
    properties.add(DiagnosticsProperty<Object>('columnIndex', columnIndex));
    properties.add(DiagnosticsProperty<Object>('rowSpan', rowSpan));
    properties.add(DiagnosticsProperty<Object>('columnSpan', columnSpan));
  }
}

class _CellKey extends LocalKey {
  const _CellKey(
      {required this.childIndex,
      required this.rowSpan,
      required this.columnSpan});

  final int childIndex;
  final int rowSpan;
  final int columnSpan;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is _CellKey &&
          runtimeType == other.runtimeType &&
          childIndex == other.childIndex &&
          rowSpan == other.rowSpan &&
          columnSpan == other.columnSpan;

  @override
  int get hashCode =>
      childIndex.hashCode ^ rowSpan.hashCode ^ columnSpan.hashCode;
}
