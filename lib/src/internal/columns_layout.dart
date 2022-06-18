import 'package:easy_table/src/internal/columns_layout_child.dart';
import 'package:easy_table/src/internal/columns_layout_element.dart';
import 'package:easy_table/src/internal/columns_layout_render_box.dart';
import 'package:easy_table/src/internal/table_layout_settings.dart';
import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';
import 'package:meta/meta.dart';

@internal
class ColumnsLayout<ROW> extends MultiChildRenderObjectWidget {
  ColumnsLayout(
      {Key? key,
      required this.layoutSettings,
      required List<ColumnsLayoutChild> children})
      : super(key: key, children: children);

  final TableLayoutSettings<ROW> layoutSettings;

  @override
  RenderObject createRenderObject(BuildContext context) {
    return ColumnsLayoutRenderBox<ROW>(layoutSettings: layoutSettings);
  }

  @override
  MultiChildRenderObjectElement createElement() {
    return ColumnsLayoutElement(this);
  }

  @override
  void updateRenderObject(
      BuildContext context, covariant ColumnsLayoutRenderBox renderObject) {
    super.updateRenderObject(context, renderObject);
    renderObject.layoutSettings = layoutSettings;
  }
}
