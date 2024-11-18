import 'package:davi/src/column_width_behavior.dart';
import 'package:davi/src/last_row_widget_listener.dart';
import 'package:davi/src/last_visible_row_listener.dart';
import 'package:davi/src/row_callback_typedefs.dart';
import 'package:davi/src/row_color.dart';
import 'package:davi/src/row_cursor_builder.dart';
import 'package:davi/src/row_hover_listener.dart';
import 'package:flutter/material.dart';

/// Table settings.
class DaviSettings<DATA> {
//TODO handle negative values
//TODO allow null and use defaults?
  const DaviSettings(
      {this.onHover,
      this.unpinnedHorizontalScrollController,
      this.pinnedHorizontalScrollController,
      this.verticalScrollController,
      this.onLastVisibleRow,
      this.onRowTap,
      this.onRowSecondaryTap,
      this.onRowSecondaryTapUp,
      this.onRowDoubleTap,
      this.columnWidthBehavior = ColumnWidthBehavior.scrollable,
      int? visibleRowsCount,
      this.focusable = true,
      this.tapToSortEnabled = true,
      this.lastRowWidget,
      this.rowColor,
      this.rowCursor,
      this.onLastRowWidget})
      : visibleRowsCount = visibleRowsCount == null || visibleRowsCount > 0
            ? visibleRowsCount
            : null;

  final ScrollController? unpinnedHorizontalScrollController;
  final ScrollController? pinnedHorizontalScrollController;
  final ScrollController? verticalScrollController;
  final OnRowHoverListener? onHover;
  final DaviRowColor<DATA>? rowColor;
  final RowCursorBuilder<DATA>? rowCursor;
  final RowDoubleTapCallback<DATA>? onRowDoubleTap;
  final RowTapCallback<DATA>? onRowTap;
  final RowTapCallback<DATA>? onRowSecondaryTap;
  final RowTapUpCallback<DATA>? onRowSecondaryTapUp;
  final ColumnWidthBehavior columnWidthBehavior;
  final int? visibleRowsCount;
  final OnLastVisibleRowListener? onLastVisibleRow;
  final bool focusable;
  final Widget? lastRowWidget;
  final OnLastRowWidgetListener? onLastRowWidget;

  /// Indicates whether sorting events are enabled on the header.
  final bool tapToSortEnabled;
}
