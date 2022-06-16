import 'package:easy_table/src/experimental/columns_metrics_exp.dart';
import 'package:easy_table/src/experimental/layout_v3/layout_child_v3.dart';
import 'package:easy_table/src/experimental/layout_v3/table_layout_element_v3.dart';
import 'package:easy_table/src/experimental/layout_v3/table_layout_render_box_v3.dart';
import 'package:easy_table/src/experimental/table_layout_settings.dart';
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
      required this.leftPinnedColumnsMetrics,
      required this.unpinnedColumnsMetrics,
      required this.rightPinnedColumnsMetrics,
      required this.theme,
      required List<LayoutChildV3> children})
      : super(key: key, children: children);

  final TableLayoutSettings layoutSettings;
  final TablePaintSettings paintSettings;
  final ColumnsMetricsExp leftPinnedColumnsMetrics;
  final ColumnsMetricsExp unpinnedColumnsMetrics;
  final ColumnsMetricsExp rightPinnedColumnsMetrics;
  final EasyTableThemeData theme;

  @override
  RenderObject createRenderObject(BuildContext context) {
    return TableLayoutRenderBoxV3<ROW>(
        layoutSettings: layoutSettings,
        paintSettings: paintSettings,
        leftPinnedColumnsMetrics: leftPinnedColumnsMetrics,
        unpinnedColumnsMetrics: unpinnedColumnsMetrics,
        rightPinnedColumnsMetrics: rightPinnedColumnsMetrics,
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
      ..leftPinnedColumnsMetrics = leftPinnedColumnsMetrics
      ..unpinnedColumnsMetrics = unpinnedColumnsMetrics
      ..rightPinnedColumnsMetrics = rightPinnedColumnsMetrics
      ..theme = theme;
  }
}
