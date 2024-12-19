import 'package:davi/src/cell_collision_behavior.dart';
import 'package:davi/src/column_width_behavior.dart';
import 'package:davi/src/internal/new/column_notifier.dart';
import 'package:davi/src/internal/new/hover_notifier.dart';
import 'package:davi/src/internal/theme_metrics/theme_metrics.dart';
import 'package:davi/src/last_visible_row_listener.dart';
import 'package:davi/src/model.dart';
import 'package:davi/src/row_callback_typedefs.dart';
import 'package:davi/src/row_color.dart';
import 'package:davi/src/row_cursor_builder.dart';
import 'package:davi/src/trailing_widget_listener.dart';
import 'package:flutter/widgets.dart';
import 'package:meta/meta.dart';

@internal
class DaviContext<DATA> {
  DaviContext(
      {required this.hoverNotifier,
      required this.hasHoverListener,
      required this.columnNotifier,
      required this.semanticsEnabled,
      required this.model,
      required this.onLastVisibleRow,
      required this.focusable,
      required this.focusNode,
      required this.onTrailingWidget,
      required this.rowCursorBuilder,
      required this.trailingWidget,
      required this.rowColor,
      required this.onRowSecondaryTapUp,
      required this.onRowSecondaryTap,
      required this.onRowDoubleTap,
      required this.onRowTap,
      required this.tapToSortEnabled,
      required this.scrolling,
      required this.visibleRowsCount,
      required this.columnWidthBehavior,
      required this.themeMetrics,
      required this.collisionBehavior});

  final HoverNotifier hoverNotifier;
  final bool hasHoverListener;
  final ColumnNotifier columnNotifier;
  final bool semanticsEnabled;
  final DaviModel<DATA> model;
  final bool focusable;
  final FocusNode focusNode;
  final Widget? trailingWidget;
  final bool tapToSortEnabled;
  final DaviRowColor<DATA>? rowColor;
  final TrailingWidgetListener onTrailingWidget;
  final LastVisibleRowListener onLastVisibleRow;
  final RowCursorBuilder<DATA>? rowCursorBuilder;
  final RowDoubleTapCallback<DATA>? onRowDoubleTap;
  final RowTapCallback<DATA>? onRowTap;
  final RowTapCallback<DATA>? onRowSecondaryTap;
  final RowTapUpCallback<DATA>? onRowSecondaryTapUp;
  final bool scrolling;
  final int? visibleRowsCount;
  final ColumnWidthBehavior columnWidthBehavior;
  final TableThemeMetrics themeMetrics;
  final CellCollisionBehavior collisionBehavior;

  bool get hasCallback =>
      onRowDoubleTap != null ||
      onRowTap != null ||
      onRowSecondaryTap != null ||
      onRowSecondaryTapUp != null;
}
