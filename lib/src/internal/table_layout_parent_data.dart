import 'package:davi/src/internal/layout_child_id.dart';
import 'package:flutter/rendering.dart';
import 'package:meta/meta.dart';

/// Parent data for [TableLayoutRenderBox] class.
@internal
class TableLayoutParentData extends ContainerBoxParentData<RenderBox> {
  LayoutChildId? id;
}
