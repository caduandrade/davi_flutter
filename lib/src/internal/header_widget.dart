import 'package:davi/src/column.dart';
import 'package:davi/src/internal/columns_layout.dart';
import 'package:davi/src/internal/columns_layout_child.dart';
import 'package:davi/src/internal/header_cell.dart';
import 'package:davi/src/internal/davi_context.dart';
import 'package:davi/src/internal/table_layout_settings.dart';
import 'package:davi/src/theme/theme.dart';
import 'package:davi/src/theme/theme_data.dart';
import 'package:flutter/widgets.dart';
import 'package:meta/meta.dart';

@internal
class HeaderWidget<DATA> extends StatelessWidget {
  const HeaderWidget(
      {super.key,
      required this.daviContext,
      required this.layoutSettings,
      required this.resizable});

  final DaviContext<DATA> daviContext;
  final TableLayoutSettings layoutSettings;
  final bool resizable;

  @override
  Widget build(BuildContext context) {
    if (daviContext.model.isColumnsEmpty) {
      return Container();
    }
    DaviThemeData theme = DaviTheme.of(context);

    List<ColumnsLayoutChild<DATA>> children = [];

    for (int columnIndex = 0;
        columnIndex < daviContext.model.columnsLength;
        columnIndex++) {
      final DaviColumn<DATA> column = daviContext.model.columnAt(columnIndex);

      final Widget cell = DaviHeaderCell<DATA>(
          key: ValueKey<int>(columnIndex),
          daviContext: daviContext,
          column: column,
          resizable: resizable,
          columnIndex: columnIndex);
      children.add(ColumnsLayoutChild<DATA>(index: columnIndex, child: cell));
    }

    Widget header = ColumnsLayout(
        layoutSettings: layoutSettings,
        scrollControllers: daviContext.scrollControllers,
        columnDividerThickness: theme.columnDividerThickness,
        columnDividerColor: theme.header.columnDividerColor,
        children: children);

    Color? color = theme.header.color;
    BoxBorder? border;
    if (theme.header.bottomBorderThickness > 0 &&
        theme.header.bottomBorderColor != null) {
      border = Border(
          bottom: BorderSide(
              width: theme.header.bottomBorderThickness,
              color: theme.header.bottomBorderColor!));
    }

    if (color != null || border != null) {
      header = Container(
          decoration: BoxDecoration(border: border, color: color),
          child: header);
    }
    return header;
  }
}
