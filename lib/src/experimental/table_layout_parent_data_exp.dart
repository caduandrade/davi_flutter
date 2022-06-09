import 'package:easy_table/src/experimental/content_area_id.dart';
import 'package:easy_table/src/experimental/layout_child_key.dart';
import 'package:easy_table/src/experimental/layout_child_type.dart';
import 'package:flutter/rendering.dart';

/// Parent data for [TableLayoutRenderBoxExp] class.
class TableLayoutParentDataExp extends ContainerBoxParentData<RenderBox> {
  LayoutChildKey? key;

  LayoutChildType? get type => key?.type;
  ContentAreaId? get contentAreaId => key?.contentAreaId;
  int? get row => key?.row;
  int? get column => key?.column;
}
