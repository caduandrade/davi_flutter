import 'package:flutter/rendering.dart';
import 'package:meta/meta.dart';

/// Parent data for [CellsLayoutRenderBox] class.
@internal
class CellsLayoutParentData extends ContainerBoxParentData<RenderBox> {
  int? cellIndex;

  bool get isCell =>
      cellIndex != null &&
          cellIndex! >= 0;

  bool get isTrailing => !isCell;
}
