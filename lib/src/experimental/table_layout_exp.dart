import 'package:easy_table/src/experimental/columns_metrics_exp.dart';
import 'package:easy_table/src/experimental/layout_child.dart';
import 'package:easy_table/src/experimental/table_layout_element_exp.dart';
import 'package:easy_table/src/experimental/table_layout_render_box_exp.dart';
import 'package:easy_table/src/experimental/table_layout_settings.dart';
import 'package:easy_table/src/experimental/table_paint_settings.dart';
import 'package:easy_table/src/experimental/table_scroll_controllers.dart';
import 'package:easy_table/src/row_hover_listener.dart';
import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';
import 'package:meta/meta.dart';

/// [EasyTable] table layout.
@internal
class TableLayoutExp<ROW> extends MultiChildRenderObjectWidget {
  TableLayoutExp(
      {Key? key,
      required this.onHoverListener,
      required this.layoutSettings,
      required this.paintSettings,
      required this.leftPinnedColumnsMetrics,
      required this.unpinnedColumnsMetrics,
      required this.rightPinnedColumnsMetrics,
      required this.rows,
      required List<LayoutChild> children})
      : super(key: key, children: children);

  final OnRowHoverListener onHoverListener;
  final TableLayoutSettings layoutSettings;
  final TablePaintSettings paintSettings;
  final ColumnsMetricsExp leftPinnedColumnsMetrics;
  final ColumnsMetricsExp unpinnedColumnsMetrics;
  final ColumnsMetricsExp rightPinnedColumnsMetrics;
  final List<ROW> rows;

  @override
  RenderObject createRenderObject(BuildContext context) {
    return TableLayoutRenderBoxExp<ROW>(
        onHoverListener: onHoverListener,
        layoutSettings: layoutSettings,
        paintSettings: paintSettings,
        leftPinnedColumnsMetrics: leftPinnedColumnsMetrics,
        unpinnedColumnsMetrics: unpinnedColumnsMetrics,
        rightPinnedColumnsMetrics: rightPinnedColumnsMetrics,
        rows: rows);
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
      ..onHoverListener = onHoverListener
      ..layoutSettings = layoutSettings
      ..paintSettings = paintSettings
      ..leftPinnedColumnsMetrics = leftPinnedColumnsMetrics
      ..unpinnedColumnsMetrics = unpinnedColumnsMetrics
      ..rightPinnedColumnsMetrics = rightPinnedColumnsMetrics
      ..rows = rows;
  }
}
