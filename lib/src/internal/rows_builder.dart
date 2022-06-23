import 'package:easy_table/src/internal/row_callbacks.dart';
import 'package:easy_table/src/internal/row_widget.dart';
import 'package:easy_table/src/internal/rows_layout_child.dart';
import 'package:easy_table/src/internal/rows_layout.dart';
import 'package:easy_table/src/internal/rows_painting_settings.dart';
import 'package:easy_table/src/internal/table_layout_settings.dart';
import 'package:easy_table/src/model.dart';
import 'package:easy_table/src/row_color.dart';
import 'package:easy_table/src/row_hover_listener.dart';
import 'package:easy_table/src/theme/theme.dart';
import 'package:easy_table/src/theme/theme_data.dart';
import 'package:flutter/material.dart';
import 'package:meta/meta.dart';

@internal
class RowsBuilder<ROW> extends StatelessWidget {
  const RowsBuilder(
      {Key? key,
      required this.layoutSettings,
      required this.model,
      required this.onHover,
      required this.scrolling,
      required this.rowCallbacks,
      required this.rowColor,
      required this.lastRowWidget})
      : super(key: key);

  final EasyTableModel<ROW>? model;
  final TableLayoutSettings<ROW> layoutSettings;
  final bool scrolling;
  final OnRowHoverListener? onHover;
  final RowCallbacks<ROW> rowCallbacks;
  final Widget? lastRowWidget;
  final EasyTableRowColor<ROW>? rowColor;

  @override
  Widget build(BuildContext context) {
    EasyTableThemeData theme = EasyTableTheme.of(context);

    List<RowsLayoutChild> children = [];

    if (model != null) {
      final int last =
          layoutSettings.firstRowIndex + layoutSettings.visibleRowsLength;
      for (int rowIndex = layoutSettings.firstRowIndex;
          rowIndex < last && rowIndex < model!.rowsLength;
          rowIndex++) {
        RowWidget<ROW> row = RowWidget<ROW>(
            index: rowIndex,
            row: model!.rowAt(rowIndex),
            onHover: onHover,
            layoutSettings: layoutSettings,
            rowCallbacks: rowCallbacks,
            scrolling: scrolling,
            color: rowColor,
            columnResizing:
                model != null ? model!.columnInResizing != null : false);
        children.add(RowsLayoutChild(index: rowIndex, child: row, last: false));
      }
      if (lastRowWidget != null &&
          children.length < layoutSettings.visibleRowsLength) {
        children.add(RowsLayoutChild(
            index: model!.rowsLength, child: lastRowWidget!, last: true));
      }

      RowsPaintingSettings paintSettings = RowsPaintingSettings(
          divisorColor: theme.row.dividerColor,
          fillHeight: theme.row.fillHeight,
          lastRowDividerVisible: theme.row.lastDividerVisible,
          rowColor: theme.row.color);
      return ClipRect(
          child: RowsLayout<ROW>(
              layoutSettings: layoutSettings,
              paintSettings: paintSettings,
              children: children));
    }

    return Container();
  }
}
