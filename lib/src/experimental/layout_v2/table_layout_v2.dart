import 'package:easy_table/src/experimental/columns_metrics_exp.dart';
import 'package:easy_table/src/experimental/layout_v2/layout_child_v2.dart';
import 'package:easy_table/src/experimental/layout_v2/row_callbacks_v2.dart';
import 'package:easy_table/src/experimental/layout_v2/table_layout_element_v2.dart';
import 'package:easy_table/src/experimental/layout_v2/table_layout_render_box_v2.dart';
import 'package:easy_table/src/experimental/table_layout_settings.dart';
import 'package:easy_table/src/experimental/table_paint_settings.dart';
import 'package:easy_table/src/row_hover_listener.dart';
import 'package:easy_table/src/theme/theme_data.dart';
import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';
import 'package:meta/meta.dart';

/// [EasyTable] table layout.
@internal
class TableLayoutV2<ROW> extends MultiChildRenderObjectWidget {
  TableLayoutV2(
      {Key? key,
      required this.onHoverListener,
      required this.layoutSettings,
      required this.paintSettings,
      required this.leftPinnedColumnsMetrics,
      required this.unpinnedColumnsMetrics,
      required this.rightPinnedColumnsMetrics,
      required this.theme,
      required this.rowCallbacks,
      required List<LayoutChildV2> children})
      : super(key: key, children: children);

  final OnRowHoverListener onHoverListener;
  final TableLayoutSettings layoutSettings;
  final TablePaintSettings paintSettings;
  final ColumnsMetricsExp leftPinnedColumnsMetrics;
  final ColumnsMetricsExp unpinnedColumnsMetrics;
  final ColumnsMetricsExp rightPinnedColumnsMetrics;
  final EasyTableThemeData theme;
  final RowCallbacksV2? rowCallbacks;

  @override
  RenderObject createRenderObject(BuildContext context) {
    return TableLayoutRenderBoxV2<ROW>(
        onHoverListener: onHoverListener,
        layoutSettings: layoutSettings,
        paintSettings: paintSettings,
        leftPinnedColumnsMetrics: leftPinnedColumnsMetrics,
        unpinnedColumnsMetrics: unpinnedColumnsMetrics,
        rightPinnedColumnsMetrics: rightPinnedColumnsMetrics,
        theme: theme,
        rowCallbacks: rowCallbacks);
  }

  @override
  MultiChildRenderObjectElement createElement() {
    return TableLayoutElementV2(this);
  }

  @override
  void updateRenderObject(
      BuildContext context, covariant TableLayoutRenderBoxV2 renderObject) {
    super.updateRenderObject(context, renderObject);
    renderObject
      ..onHoverListener = onHoverListener
      ..layoutSettings = layoutSettings
      ..paintSettings = paintSettings
      ..leftPinnedColumnsMetrics = leftPinnedColumnsMetrics
      ..unpinnedColumnsMetrics = unpinnedColumnsMetrics
      ..rightPinnedColumnsMetrics = rightPinnedColumnsMetrics
      ..theme = theme
      ..rowCallbacks = rowCallbacks;
  }
}
