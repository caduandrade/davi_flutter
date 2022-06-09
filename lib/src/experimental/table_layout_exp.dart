import 'dart:math' as math;
import 'package:easy_table/src/experimental/layout_child.dart';
import 'package:easy_table/src/experimental/table_layout_element_exp.dart';
import 'package:easy_table/src/experimental/table_layout_render_box_exp.dart';
import 'package:easy_table/src/experimental/table_layout_settings.dart';
import 'package:easy_table/src/experimental/table_paint_settings.dart';
import 'package:easy_table/src/experimental/table_scroll_controllers.dart';
import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';
import 'package:meta/meta.dart';

/// [EasyTable] table layout.
@internal
class TableLayoutExp extends MultiChildRenderObjectWidget {
  TableLayoutExp(
      {Key? key,
      required this.layoutSettings,
      required this.paintSettings,
      required this.scrollControllers,
      required List<LayoutChild> children})
      : super(key: key, children: children);

  final TableLayoutSettings layoutSettings;
  final TablePaintSettings paintSettings;
  final TableScrollControllers scrollControllers;

  @override
  RenderObject createRenderObject(BuildContext context) {
    return TableLayoutRenderBoxExp(
        layoutSettings: layoutSettings, paintSettings: paintSettings);
  }

  @override
  MultiChildRenderObjectElement createElement() {
    return TableLayoutElementExp(this);
  }

  @override
  void updateRenderObject(
      BuildContext context, covariant TableLayoutRenderBoxExp renderObject) {
    super.updateRenderObject(context, renderObject);
    renderObject
      ..layoutSettings = layoutSettings
      ..paintSettings = paintSettings;
  }
}
