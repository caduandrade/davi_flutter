import 'package:easy_table/src/experimental/layout_v3/row_callbacks.dart';
import 'package:easy_table/src/experimental/layout_v3/row.dart';
import 'package:easy_table/src/experimental/layout_v3/rows/rows_layout_child.dart';
import 'package:easy_table/src/experimental/layout_v3/rows/rows_layout.dart';
import 'package:easy_table/src/experimental/layout_v3/rows/rows_painting_settings.dart';
import 'package:easy_table/src/experimental/metrics/table_layout_settings.dart';
import 'package:easy_table/src/model.dart';
import 'package:easy_table/src/theme/theme.dart';
import 'package:easy_table/src/theme/theme_data.dart';
import 'package:flutter/material.dart';

class RowsV3<ROW> extends StatelessWidget {
  const RowsV3(
      {Key? key,
      required this.layoutSettings,
      required this.model,
      required this.scrolling,
      required this.rowCallbacks})
      : super(key: key);

  final EasyTableModel<ROW>? model;
  final TableLayoutSettingsV3<ROW> layoutSettings;
  final bool scrolling;
  final RowCallbacksV3<ROW> rowCallbacks;

  @override
  Widget build(BuildContext context) {
    EasyTableThemeData theme = EasyTableTheme.of(context);

    List<RowsLayoutChild<ROW>> children = [];

    if (model != null) {
      final int last =
          layoutSettings.firstRowIndex + layoutSettings.maxVisibleRowsLength;
      for (int i = layoutSettings.firstRowIndex;
          i < last && i < model!.visibleRowsLength;
          i++) {
        RowV3<ROW> row = RowV3<ROW>(
            rowIndex: i,
            row: model!.visibleRowAt(i),
            layoutSettings: layoutSettings,
            rowCallbacks: rowCallbacks,
            scrolling: scrolling);
        children.add(RowsLayoutChild<ROW>(index: i, child: row));
      }

      RowsPaintingSettings paintSettings =
          RowsPaintingSettings(divisorColor: theme.row.dividerColor);
      return ClipRect(
          child: RowsLayout<ROW>(
              layoutSettings: layoutSettings,
              paintSettings: paintSettings,
              children: children));
    }

    return Container();
  }
}
