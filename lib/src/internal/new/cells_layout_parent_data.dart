import 'package:flutter/rendering.dart';
import 'package:meta/meta.dart';

/// Parent data for [CellsLayoutRenderBox] class.
@internal
class CellsLayoutParentData extends ContainerBoxParentData<RenderBox> {
  int? rowIndex;
  int? columnIndex;

  bool get isCell => columnIndex!=null;
  bool get isRow => !isCell;
}
