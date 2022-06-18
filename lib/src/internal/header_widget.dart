import 'package:easy_table/src/column.dart';
import 'package:easy_table/src/internal/columns_layout_child.dart';
import 'package:easy_table/src/internal/columns_layout.dart';
import 'package:easy_table/src/internal/column_metrics.dart';
import 'package:easy_table/src/internal/table_layout_settings.dart';
import 'package:easy_table/src/internal/header_cell.dart';
import 'package:easy_table/src/model.dart';
import 'package:easy_table/src/theme/theme.dart';
import 'package:easy_table/src/theme/theme_data.dart';
import 'package:flutter/widgets.dart';
import 'package:meta/meta.dart';

@internal
class HeaderWidget<ROW> extends StatelessWidget {
  const HeaderWidget(
      {Key? key,
      required this.layoutSettings,
      required this.model,
      required this.resizable,
      required this.multiSortEnabled})
      : super(key: key);

  final TableLayoutSettings<ROW> layoutSettings;
  final EasyTableModel<ROW> model;
  final bool resizable;
  final bool multiSortEnabled;

  @override
  Widget build(BuildContext context) {
    EasyTableThemeData theme = EasyTableTheme.of(context);

    List<ColumnsLayoutChild<ROW>> children = [];

    for (int columnIndex = 0;
        columnIndex < layoutSettings.columnsMetrics.length;
        columnIndex++) {
      final ColumnMetrics<ROW> columnMetrics =
          layoutSettings.columnsMetrics[columnIndex];
      final EasyTableColumn<ROW> column = columnMetrics.column;

      final Widget cell = EasyTableHeaderCell<ROW>(
          key: ValueKey<int>(columnIndex),
          model: model,
          column: column,
          resizable: resizable,
          multiSortEnabled: multiSortEnabled);
      children.add(ColumnsLayoutChild<ROW>(index: columnIndex, child: cell));
    }

    Widget header =
        ColumnsLayout(layoutSettings: layoutSettings, children: children);

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
