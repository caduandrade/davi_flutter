import 'package:davi/src/column.dart';
import 'package:davi/src/internal/columns_layout.dart';
import 'package:davi/src/internal/columns_layout_child.dart';
import 'package:davi/src/internal/header_cell.dart';
import 'package:davi/src/internal/new/column_notifier.dart';
import 'package:davi/src/internal/new/hover_notifier.dart';
import 'package:davi/src/internal/scroll_offsets.dart';
import 'package:davi/src/internal/table_layout_settings.dart';
import 'package:davi/src/model.dart';
import 'package:davi/src/theme/theme.dart';
import 'package:davi/src/theme/theme_data.dart';
import 'package:flutter/widgets.dart';
import 'package:meta/meta.dart';

@internal
class HeaderWidget<DATA> extends StatelessWidget {
  const HeaderWidget(
      {Key? key,
      required this.layoutSettings,
      required this.model,
      required this.resizable,
      required this.horizontalScrollOffsets,
      required this.tapToSortEnabled,
      required this.columnNotifier,
      required this.hoverNotifier})
      : super(key: key);

  final TableLayoutSettings layoutSettings;
  final DaviModel<DATA> model;
  final bool resizable;
  final HorizontalScrollOffsets horizontalScrollOffsets;
  final bool tapToSortEnabled;
  final ColumnNotifier columnNotifier;
  final HoverNotifier hoverNotifier;

  @override
  Widget build(BuildContext context) {
    DaviThemeData theme = DaviTheme.of(context);

    List<ColumnsLayoutChild<DATA>> children = [];

    final isMultiSorted = model.isMultiSorted;

    for (int columnIndex = 0;
        columnIndex < model.columnsLength;
        columnIndex++) {
      final DaviColumn<DATA> column = model.columnAt(columnIndex);

      final Widget cell = DaviHeaderCell<DATA>(
          key: ValueKey<int>(columnIndex),
          model: model,
          column: column,
          resizable: resizable,
          tapToSortEnabled: tapToSortEnabled,
          isMultiSorted: isMultiSorted,
          columnIndex: columnIndex,
      columnNotifier: columnNotifier,
      hoverNotifier: hoverNotifier);
      children.add(ColumnsLayoutChild<DATA>(index: columnIndex, child: cell));
    }

    Widget header = ColumnsLayout(
        layoutSettings: layoutSettings,
        horizontalScrollOffsets: horizontalScrollOffsets,
        paintDividerColumns: true,
        children: children);

    Color? color = theme.header.color;
    BoxBorder? border;
    if (theme.header.bottomBorderHeight > 0 &&
        theme.header.bottomBorderColor != null) {
      border = Border(
          bottom: BorderSide(
              width: theme.header.bottomBorderHeight,
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
