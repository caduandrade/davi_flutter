import 'package:easy_table/src/internal/rows_layout_child.dart';
import 'package:easy_table/src/internal/rows_layout_element.dart';
import 'package:easy_table/src/internal/rows_layout_render_box.dart';
import 'package:easy_table/src/internal/rows_painting_settings.dart';
import 'package:easy_table/src/internal/table_layout_settings.dart';
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
      required List<RowsLayoutChild> children})
      : super(key: key, children: children);

  final TableLayoutSettings<ROW> layoutSettings;
  final RowsPaintingSettings paintSettings;

  @override
  RenderObject createRenderObject(BuildContext context) {
    return RowsLayoutRenderBox<ROW>(
        layoutSettings: layoutSettings, paintSettings: paintSettings);
  }

  @override
  MultiChildRenderObjectElement createElement() {
    return RowsLayoutElement(this);
  }

  @override
  void updateRenderObject(
      BuildContext context, covariant RowsLayoutRenderBox renderObject) {
    super.updateRenderObject(context, renderObject);
    renderObject
      ..layoutSettings = layoutSettings
      ..paintSettings = paintSettings;
  }
}
