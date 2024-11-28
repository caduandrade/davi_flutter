import 'package:davi/src/internal/columns_layout_child.dart';
import 'package:davi/src/internal/columns_layout_element.dart';
import 'package:davi/src/internal/columns_layout_render_box.dart';
import 'package:davi/src/internal/scroll_offsets.dart';
import 'package:davi/src/internal/table_layout_settings.dart';
import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';
import 'package:meta/meta.dart';

@internal
class ColumnsLayout extends MultiChildRenderObjectWidget {
  const ColumnsLayout(
      {Key? key,
      required this.layoutSettings,
      required this.horizontalScrollOffsets,
      required this.columnDividerThickness,
      required this.columnDividerColor,
      required List<ColumnsLayoutChild> children})
      : super(key: key, children: children);

  final TableLayoutSettings layoutSettings;
  final HorizontalScrollOffsets horizontalScrollOffsets;
  final double columnDividerThickness;
  final Color? columnDividerColor;

  @override
  RenderObject createRenderObject(BuildContext context) {
    return ColumnsLayoutRenderBox(
        layoutSettings: layoutSettings,
        horizontalScrollOffsets: horizontalScrollOffsets,
        columnDividerColor: columnDividerColor,
        columnDividerThickness: columnDividerThickness);
  }

  @override
  MultiChildRenderObjectElement createElement() {
    return ColumnsLayoutElement(this);
  }

  @override
  void updateRenderObject(
      BuildContext context, covariant ColumnsLayoutRenderBox renderObject) {
    super.updateRenderObject(context, renderObject);
    renderObject
      ..layoutSettings = layoutSettings
      ..horizontalScrollOffsets = horizontalScrollOffsets
      ..columnDividerColor = columnDividerColor
      ..columnDividerThickness = columnDividerThickness;
  }
}
