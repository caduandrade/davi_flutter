import 'package:flutter/rendering.dart';
import 'package:meta/meta.dart';

/// Parent data for [CellsLayoutRenderBox] class.
@internal
class CellsLayoutParentData extends ContainerBoxParentData<RenderBox> {
  int? rowIndex;
  int? columnIndex;

  bool get isCell =>
      rowIndex != null &&
      rowIndex! >= 0 &&
      columnIndex != null &&
      columnIndex! >= 0;
  bool get isTrailing => !isCell;
}
