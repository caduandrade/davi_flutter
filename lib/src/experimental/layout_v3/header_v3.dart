import 'package:easy_table/src/column.dart';
import 'package:easy_table/src/experimental/layout_v3/column_layout/columns_layout_child_v3.dart';
import 'package:easy_table/src/experimental/layout_v3/column_layout/columns_layout_v3.dart';
import 'package:easy_table/src/experimental/metrics/column_metrics_v3.dart';
import 'package:easy_table/src/experimental/metrics/table_layout_settings_v3.dart';
import 'package:easy_table/src/internal/header_cell.dart';
import 'package:easy_table/src/model.dart';
import 'package:easy_table/src/theme/theme.dart';
import 'package:easy_table/src/theme/theme_data.dart';
import 'package:flutter/widgets.dart';

class HeaderV3<ROW> extends StatelessWidget {
  const HeaderV3(
      {Key? key,
      required this.layoutSettings,
      required this.model,
      required this.resizable,
      required this.multiSortEnabled})
      : super(key: key);

  final TableLayoutSettingsV3<ROW> layoutSettings;
  final EasyTableModel<ROW> model;
  final bool resizable;
  final bool multiSortEnabled;

  @override
  Widget build(BuildContext context) {
    EasyTableThemeData theme = EasyTableTheme.of(context);

    List<ColumnsLayoutChildV3<ROW>> children = [];

    for (int columnIndex = 0;
        columnIndex < layoutSettings.columnsMetrics.length;
        columnIndex++) {
      final ColumnMetricsV3<ROW> columnMetrics =
          layoutSettings.columnsMetrics[columnIndex];
      final EasyTableColumn<ROW> column = columnMetrics.column;

      final Widget cell = EasyTableHeaderCell<ROW>(
          key: ValueKey<int>(columnIndex),
          model: model,
          column: column,
          resizable: resizable,
          multiSortEnabled: multiSortEnabled);
      children.add(ColumnsLayoutChildV3<ROW>(index: columnIndex, child: cell));
    }

    Widget header =
        ColumnsLayoutV3(layoutSettings: layoutSettings, children: children);

    if (theme.header.bottomBorderHeight > 0 &&
        theme.header.bottomBorderColor != null) {
      header = Container(
          decoration: BoxDecoration(
              border: Border(
                  bottom: BorderSide(
                      width: theme.header.bottomBorderHeight,
                      color: theme.header.bottomBorderColor!))),
          child: header);
    }
    return header;
  }
}
