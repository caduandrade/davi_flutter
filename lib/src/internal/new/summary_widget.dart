import 'package:davi/src/column.dart';
import 'package:davi/src/internal/columns_layout.dart';
import 'package:davi/src/internal/columns_layout_child.dart';
import 'package:davi/src/internal/new/davi_context.dart';
import 'package:davi/src/internal/table_layout_settings.dart';
import 'package:davi/src/theme/theme.dart';
import 'package:davi/src/theme/theme_data.dart';
import 'package:flutter/widgets.dart';

class SummaryWidget<DATA> extends StatelessWidget {
  const SummaryWidget(
      {Key? key, required this.daviContext, required this.layoutSettings})
      : super(key: key);

  final DaviContext<DATA> daviContext;
  final TableLayoutSettings layoutSettings;

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
      if (column.summary != null) {
        Widget summaryCell = ClipRect(child: column.summary!(context));
        if (theme.summary.padding != null) {
          summaryCell =
              Padding(padding: theme.summary.padding!, child: summaryCell);
        }
        if (theme.summary.alignment != null) {
          summaryCell =
              Align(alignment: theme.summary.alignment!, child: summaryCell);
        }

        children.add(
            ColumnsLayoutChild<DATA>(index: columnIndex, child: summaryCell));
      }
    }

    Widget summary = ColumnsLayout(
        layoutSettings: layoutSettings,
        scrollControllers: daviContext.scrollControllers,
        columnDividerThickness: theme.columnDividerThickness,
        columnDividerColor: theme.summary.columnDividerColor,
        children: children);

    Color? color = theme.summary.color;
    BoxBorder? border;
    if (theme.summary.topBorderThickness > 0 &&
        theme.summary.topBorderColor != null) {
      border = Border(
          top: BorderSide(
              width: theme.summary.topBorderThickness,
              color: theme.summary.topBorderColor!));
    }

    if (color != null || border != null) {
      return Container(
          decoration: BoxDecoration(
            border: border,
            color: color,
          ),
          child: summary);
    }
    return summary;
  }
}
