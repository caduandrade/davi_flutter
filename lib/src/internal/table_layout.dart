import 'package:easy_table/src/internal/layout_child.dart';
import 'package:easy_table/src/internal/table_layout_element.dart';
import 'package:easy_table/src/internal/table_layout_render_box.dart';
import 'package:easy_table/src/internal/table_layout_settings.dart';
import 'package:easy_table/src/theme/theme_data.dart';
import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';
import 'package:meta/meta.dart';

/// [EasyTable] table layout.
@internal
class TableLayout<ROW> extends MultiChildRenderObjectWidget {
  TableLayout(
      {Key? key,
      required this.layoutSettings,
      required this.theme,
      required List<LayoutChild> children})
      : super(key: key, children: children);

  final TableLayoutSettings<ROW> layoutSettings;
  final EasyTableThemeData theme;

  @override
  RenderObject createRenderObject(BuildContext context) {
    return TableLayoutRenderBox<ROW>(
        layoutSettings: layoutSettings, theme: theme);
  }

  @override
  MultiChildRenderObjectElement createElement() {
    return TableLayoutElement(this);
  }

  @override
  void updateRenderObject(
      BuildContext context, covariant TableLayoutRenderBox renderObject) {
    super.updateRenderObject(context, renderObject);
    renderObject
      ..layoutSettings = layoutSettings
      ..theme = theme;
  }
}
