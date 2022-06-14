import 'package:easy_table/src/experimental/pin_status.dart';
import 'package:easy_table/src/experimental/layout_v2/layout_child_key_v2.dart';
import 'package:easy_table/src/experimental/layout_v2/layout_child_type_v2.dart';
import 'package:flutter/rendering.dart';

/// Parent data for [TableLayoutRenderBoxExp] class.
class TableLayoutParentDataV2 extends ContainerBoxParentData<RenderBox> {
  LayoutChildKeyV2? key;

  LayoutChildTypeV2? get type => key?.type;
  PinStatus? get pinStatus => key?.pinStatus;
  int? get row => key?.row;
  int? get column => key?.column;
}
