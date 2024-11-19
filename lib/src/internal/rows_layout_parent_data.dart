import 'package:flutter/rendering.dart';
import 'package:meta/meta.dart';

/// Parent data for [RowsLayoutRenderBox] class.
@internal
@Deprecated('message')
class RowsLayoutParentData extends ContainerBoxParentData<RenderBox> {
  int? index;
  bool? last;
}
