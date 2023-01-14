import 'package:davi/davi.dart';
import 'package:davi/src/internal/columns_layout_child.dart';
import 'package:davi/src/internal/columns_layout_element.dart';
import 'package:davi/src/internal/columns_layout_render_box.dart';
import 'package:davi/src/internal/scroll_offsets.dart';
import 'package:davi/src/internal/table_layout_settings.dart';
import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';
import 'package:meta/meta.dart';

@internal
class ColumnsLayout<ROW> extends MultiChildRenderObjectWidget {
  ColumnsLayout(
      {Key? key,
      required this.layoutSettings,
      required this.horizontalScrollOffsets,
      required this.paintDividerColumns,
      required List<ColumnsLayoutChild> children})
      : super(key: key, children: children);

  final TableLayoutSettings layoutSettings;
  final HorizontalScrollOffsets horizontalScrollOffsets;
  final bool paintDividerColumns;

  @override
  RenderObject createRenderObject(BuildContext context) {
    DaviThemeData theme = DaviTheme.of(context);
    return ColumnsLayoutRenderBox<ROW>(
        layoutSettings: layoutSettings,
        horizontalScrollOffsets: horizontalScrollOffsets,
        theme: theme,
        paintDividerColumns: paintDividerColumns);
  }

  @override
  MultiChildRenderObjectElement createElement() {
    return ColumnsLayoutElement(this);
  }

  @override
  void updateRenderObject(
      BuildContext context, covariant ColumnsLayoutRenderBox renderObject) {
    super.updateRenderObject(context, renderObject);
    DaviThemeData theme = DaviTheme.of(context);
    renderObject
      ..layoutSettings = layoutSettings
      ..horizontalScrollOffsets = horizontalScrollOffsets
      ..theme = theme
      ..paintDividerColumns = paintDividerColumns;
  }
}
