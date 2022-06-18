import 'package:easy_table/src/experimental/layout_v3/layout_child.dart';
import 'package:easy_table/src/experimental/layout_v3/table_layout_element.dart';
import 'package:easy_table/src/experimental/layout_v3/table_layout_render_box.dart';
import 'package:easy_table/src/experimental/metrics/table_layout_settings.dart';
import 'package:easy_table/src/experimental/table_paint_settings.dart';
import 'package:easy_table/src/theme/theme_data.dart';
import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';
import 'package:meta/meta.dart';

/// [EasyTable] table layout.
@internal
class TableLayoutV3<ROW> extends MultiChildRenderObjectWidget {
  TableLayoutV3(
      {Key? key,
      required this.layoutSettings,
      required this.paintSettings,
      required this.theme,
      required List<LayoutChildV3> children})
      : super(key: key, children: children);

  final TableLayoutSettingsV3<ROW> layoutSettings;
  final TablePaintSettings paintSettings;
  final EasyTableThemeData theme;

  @override
  RenderObject createRenderObject(BuildContext context) {
    return TableLayoutRenderBoxV3<ROW>(
        layoutSettings: layoutSettings,
        paintSettings: paintSettings,
        theme: theme);
  }

  @override
  MultiChildRenderObjectElement createElement() {
    return TableLayoutElementV3(this);
  }

  @override
  void updateRenderObject(
      BuildContext context, covariant TableLayoutRenderBoxV3 renderObject) {
    super.updateRenderObject(context, renderObject);
    renderObject
      ..layoutSettings = layoutSettings
      ..paintSettings = paintSettings
      ..theme = theme;
  }
}
