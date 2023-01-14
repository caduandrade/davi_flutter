import 'package:davi/src/internal/rows_layout_child.dart';
import 'package:davi/src/internal/rows_layout_element.dart';
import 'package:davi/src/internal/rows_layout_render_box.dart';
import 'package:davi/src/internal/rows_painting_settings.dart';
import 'package:davi/src/internal/scroll_offsets.dart';
import 'package:davi/src/internal/table_layout_settings.dart';
import 'package:davi/src/theme/theme.dart';
import 'package:davi/src/theme/theme_data.dart';
import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';
import 'package:meta/meta.dart';

/// Rows layout.
@internal
class RowsLayout<ROW> extends MultiChildRenderObjectWidget {
  RowsLayout(
      {Key? key,
      required this.layoutSettings,
      required this.paintSettings,
      required this.verticalOffset,
      required this.horizontalScrollOffsets,
      required List<RowsLayoutChild> children})
      : super(key: key, children: children);

  final TableLayoutSettings layoutSettings;
  final RowsPaintingSettings paintSettings;
  final double verticalOffset;
  final HorizontalScrollOffsets horizontalScrollOffsets;

  @override
  RenderObject createRenderObject(BuildContext context) {
    EasyTableThemeData theme = EasyTableTheme.of(context);
    return RowsLayoutRenderBox(
        layoutSettings: layoutSettings,
        paintSettings: paintSettings,
        verticalOffset: verticalOffset,
        theme: theme,
        horizontalScrollOffsets: horizontalScrollOffsets);
  }

  @override
  MultiChildRenderObjectElement createElement() {
    return RowsLayoutElement(this);
  }

  @override
  void updateRenderObject(
      BuildContext context, covariant RowsLayoutRenderBox renderObject) {
    EasyTableThemeData theme = EasyTableTheme.of(context);
    super.updateRenderObject(context, renderObject);
    renderObject
      ..layoutSettings = layoutSettings
      ..paintSettings = paintSettings
      ..verticalOffset = verticalOffset
      ..theme = theme
      ..horizontalScrollOffsets = horizontalScrollOffsets;
  }
}
