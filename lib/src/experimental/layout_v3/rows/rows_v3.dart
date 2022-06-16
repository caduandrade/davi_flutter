import 'package:easy_table/src/experimental/layout_v3/row_v3.dart';
import 'package:easy_table/src/experimental/layout_v3/rows/rows_layout_child_v3.dart';
import 'package:easy_table/src/experimental/layout_v3/rows/rows_layout_v3.dart';
import 'package:easy_table/src/experimental/layout_v3/rows/rows_painting_settings.dart';
import 'package:easy_table/src/experimental/metrics/table_layout_settings_v3.dart';
import 'package:easy_table/src/model.dart';
import 'package:flutter/material.dart';

class RowsV3<ROW> extends StatelessWidget {
  const RowsV3({Key? key, required this.layoutSettings, required this.model})
      : super(key: key);

  final EasyTableModel<ROW>? model;
  final TableLayoutSettingsV3<ROW> layoutSettings;

  @override
  Widget build(BuildContext context) {
    List<RowsLayoutChildV3> children = [];

    if (model != null) {
      final int last =
          layoutSettings.firstRowIndex + layoutSettings.maxVisibleRowsLength;
      for (int i = layoutSettings.firstRowIndex;
          i < last && i < model!.visibleRowsLength;
          i++) {
        RowV3 row = RowV3(rowIndex: i, row: model!.visibleRowAt(i));
        children.add(RowsLayoutChildV3(index: i, child: row));
      }

      //TODO use correct color
      RowsPaintingSettings paintSettings =
          RowsPaintingSettings(divisorColor: Colors.green);
      return RowsLayoutV3<ROW>(
          layoutSettings: layoutSettings,
          paintSettings: paintSettings,
          children: children);
    }

    return const Placeholder();
  }
}
