import 'package:easy_table/easy_table.dart';
import 'package:easy_table/src/easy_table_sort_type.dart';
import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';

/// Default header cell
class EasyTableHeaderCell<ROW> extends StatelessWidget {
  /// Builds a header cell.
  const EasyTableHeaderCell(
      {Key? key,
      required this.model,
      required this.column,
      this.child,
      this.value,
      this.padding,
      this.alignment})
      : super(key: key);

  final Widget? child;
  final String? value;

  final EdgeInsetsGeometry? padding;
  final AlignmentGeometry? alignment;

  final EasyTableModel<ROW> model;
  final EasyTableColumn<ROW> column;

  @override
  Widget build(BuildContext context) {
    Widget? widget = child;

    EasyTableThemeData theme = EasyTableTheme.of(context);

    TextStyle? textStyle = theme.headerCell.textStyle;

    if (value != null) {
      widget = Text(value!, overflow: TextOverflow.ellipsis, style: textStyle);
    }

    widget = widget ?? Container();

    widget = Align(
        child: widget, alignment: alignment ?? theme.headerCell.alignment);

    if (column.sortable && model.sortedColumn == column) {
      IconData? icon;
      if (model.sortType == EasyTableSortType.ascending) {
        icon = theme.headerCell.ascendingIcon;
      } else if (model.sortType == EasyTableSortType.descending) {
        icon = theme.headerCell.descendingIcon;
      }
      widget = Row(children: [
        Expanded(child: widget),
        Icon(icon,
            color: theme.headerCell.sortIconColor,
            size: theme.headerCell.sortIconSize)
      ]);
    }

    EdgeInsetsGeometry? p = padding ?? theme.headerCell.padding;
    if (p != null) {
      widget = Padding(padding: p, child: widget);
    }

    if (column.sortable) {
      return GestureDetector(
          behavior: HitTestBehavior.opaque,
          child: widget,
          onTap: () => _onHeaderPressed(model: model, column: column));
    }
    return widget;
  }

  void _onHeaderPressed(
      {required EasyTableModel<ROW> model,
      required EasyTableColumn<ROW> column}) {
    if (model.sortedColumn == null) {
      model.sortByColumn(column: column, sortType: EasyTableSortType.ascending);
    } else {
      if (model.sortedColumn != column) {
        model.sortByColumn(
            column: column, sortType: EasyTableSortType.ascending);
      } else if (model.sortType == EasyTableSortType.ascending) {
        model.sortByColumn(
            column: column, sortType: EasyTableSortType.descending);
      } else {
        model.removeColumnSort();
      }
    }
  }
}
