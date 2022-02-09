import 'dart:math' as math;
import 'package:easy_table/src/easy_table_column.dart';
import 'package:easy_table/src/easy_table_row_color.dart';
import 'package:easy_table/src/private/layout/horizontal_layout.dart';
import 'package:easy_table/src/theme/easy_table_theme.dart';
import 'package:easy_table/src/theme/easy_table_theme_data.dart';
import 'package:easy_table/src/theme/header_theme_data.dart';
import 'package:flutter/material.dart';

/// Table view designed for a large number of data.
///
/// The type [ROW] represents the data of each row.
class EasyTable<ROW> extends StatefulWidget {
//TODO handle negative values
//TODO allow null and use defaults?
  const EasyTable(
      {Key? key,
      required this.columns,
      this.rows,
      this.cellHeight = 32,
      this.horizontalScrollController,
      this.verticalScrollController,
      this.cellPadding = const EdgeInsets.only(left: 8, right: 8),
      this.headerCellPadding = const EdgeInsets.all(8),
      this.rowColor})
      : super(key: key);

  final double cellHeight;
  final EdgeInsetsGeometry? cellPadding;
  final EdgeInsetsGeometry? headerCellPadding;
  final List<EasyTableColumn<ROW>> columns;
  final List<ROW>? rows;
  final ScrollController? horizontalScrollController;
  final ScrollController? verticalScrollController;
  final EasyTableRowColor? rowColor;

  double get rowHeight =>
      cellPadding != null ? cellHeight + cellPadding!.vertical : cellHeight;

  int get length => rows != null ? rows!.length : 0;

  @override
  State<StatefulWidget> createState() => _EasyTableState<ROW>();
}

/// The [EasyTable] state.
class _EasyTableState<ROW> extends State<EasyTable<ROW>> {
  late ScrollController _verticalScrollController;
  late ScrollController _horizontalScrollController;

  final ScrollController _headerHorizontalScrollController = ScrollController();

  final List<double> _columnWidths = [];

  @override
  void initState() {
    super.initState();
    for (EasyTableColumn<ROW> column in widget.columns) {
      _columnWidths.add(column.initialWidth);
    }
    _horizontalScrollController =
        widget.horizontalScrollController ?? ScrollController();
    _verticalScrollController =
        widget.verticalScrollController ?? ScrollController();

    _horizontalScrollController.addListener(_syncHorizontalScroll);
  }

  @override
  void dispose() {
    _horizontalScrollController.removeListener(_syncHorizontalScroll);
    super.dispose();
  }

  @override
  void didUpdateWidget(covariant EasyTable<ROW> oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (widget.horizontalScrollController != null) {
      _horizontalScrollController.removeListener(_syncHorizontalScroll);
      _horizontalScrollController = widget.horizontalScrollController!;
      _horizontalScrollController.addListener(_syncHorizontalScroll);
    }
    if (widget.verticalScrollController != null) {
      _verticalScrollController = widget.verticalScrollController!;
    }
  }

  void _syncHorizontalScroll() {
    _headerHorizontalScrollController
        .jumpTo(_horizontalScrollController.offset);
  }

  @override
  Widget build(BuildContext context) {
    Widget table = LayoutBuilder(builder: (context, constraints) {
      EasyTableThemeData theme = EasyTableTheme.of(context);
      double requiredWidth = 0;
      for (double width in _columnWidths) {
        requiredWidth += width;
      }
      requiredWidth += (widget.columns.length) * theme.columnGap;
      double maxWidth = math.max(constraints.maxWidth, requiredWidth);
      return HorizontalLayout(
          top: ScrollConfiguration(
              behavior:
                  ScrollConfiguration.of(context).copyWith(scrollbars: false),
              child: SingleChildScrollView(
                  controller: _headerHorizontalScrollController,
                  scrollDirection: Axis.horizontal,
                  child: _header(context: context, maxWidth: maxWidth))),
          center: Scrollbar(
              isAlwaysShown: true,
              controller: _horizontalScrollController,
              child: _rows(context: context, maxWidth: maxWidth)));
    });
    EasyTableThemeData theme = EasyTableTheme.of(context);
    if (theme.decoration != null) {
      table = Container(child: table, decoration: theme.decoration);
    }
    return table;
  }

  /// Builds a headers
  Widget _header({required BuildContext context, required double maxWidth}) {
    List<Widget> children = [];
    for (int columnIndex = 0;
        columnIndex < widget.columns.length;
        columnIndex++) {
      EasyTableColumn<ROW> column = widget.columns[columnIndex];
      children.add(_headerCell(
          context: context,
          column: column,
          columnIndex: columnIndex,
          columnWidth: _columnWidths[columnIndex]));
    }
    HeaderThemeData headerTheme = EasyTableTheme.of(context).header;
    BoxDecoration? decoration;
    if (headerTheme.bottomBorder != null) {
      decoration =
          BoxDecoration(border: Border(bottom: headerTheme.bottomBorder!));
    }
    return Container(
        child: Row(children: children),
        width: maxWidth,
        decoration: decoration);
  }

  /// Builds the table content.
  Widget _rows({required BuildContext context, required double maxWidth}) {
    EasyTableThemeData theme = EasyTableTheme.of(context);
    return Scrollbar(
        isAlwaysShown: true,
        controller: _verticalScrollController,
        notificationPredicate: (p) {
          return true;
        },
        child: SingleChildScrollView(
            scrollDirection: Axis.horizontal,
            controller: _horizontalScrollController,
            child: SizedBox(
                child: ScrollConfiguration(
                    behavior: ScrollConfiguration.of(context)
                        .copyWith(scrollbars: false),
                    child: ListView.builder(
                        controller: _verticalScrollController,
                        itemExtent: widget.rowHeight + theme.rowGap,
                        itemBuilder: (context, index) {
                          return _row(context: context, rowIndex: index);
                        },
                        itemCount: widget.length)),
                width: maxWidth)));
  }

  /// Builds a single table row.
  Widget _row({required BuildContext context, required int rowIndex}) {
    EasyTableThemeData theme = EasyTableTheme.of(context);
    ROW row = widget.rows![rowIndex];
    List<Widget> children = [];
    for (int columnIndex = 0;
        columnIndex < widget.columns.length;
        columnIndex++) {
      EasyTableColumn<ROW> column = widget.columns[columnIndex];
      children.add(_cell(
          context: context,
          row: row,
          column: column,
          rowIndex: rowIndex,
          rowHeight: widget.rowHeight,
          columnWidth: _columnWidths[columnIndex]));
    }
    Widget rowWidget = Row(children: children);

    if (widget.rowColor != null) {
      rowWidget =
          Container(child: rowWidget, color: widget.rowColor!(row, rowIndex));
    }
    if (theme.rowGap > 0) {
      rowWidget = Padding(
          child: rowWidget, padding: EdgeInsets.only(bottom: theme.rowGap));
    }

    return rowWidget;
  }

  /// Builds a table cell.
  Widget _cell(
      {required BuildContext context,
      required ROW row,
      required EasyTableColumn<ROW> column,
      required int rowIndex,
      required double rowHeight,
      required double columnWidth}) {
    EasyTableThemeData theme = EasyTableTheme.of(context);
    double width = columnWidth;

    Widget? cellWidget = column.buildCellWidget(context, row);
    EdgeInsetsGeometry? padding;
    if (theme.columnGap > 0) {
      width += theme.columnGap;
      padding = EdgeInsets.only(right: theme.columnGap);
    }
    if (widget.cellPadding != null) {
      if (padding != null) {
        padding = widget.cellPadding!.add(padding);
      } else {
        padding = widget.cellPadding!;
      }
    }
    if (padding != null) {
      cellWidget = Padding(padding: padding, child: cellWidget);
    }
    return ConstrainedBox(
        constraints: BoxConstraints.tightFor(width: width, height: rowHeight),
        child: cellWidget);
  }

  /// Builds a table header cell.
  Widget _headerCell(
      {required BuildContext context,
      required EasyTableColumn column,
      required int columnIndex,
      required double columnWidth}) {
    EasyTableThemeData theme = EasyTableTheme.of(context);
    double width = columnWidth;
    Widget? headerCellWidget;
    if (column.headerCellBuilder != null) {
      headerCellWidget =
          column.headerCellBuilder!(context, column, columnIndex);
    }
    EdgeInsetsGeometry? padding;
    if (theme.columnGap > 0) {
      width += theme.columnGap;
      padding = EdgeInsets.only(right: theme.columnGap);
    }
    if (widget.headerCellPadding != null) {
      if (padding != null) {
        padding = widget.headerCellPadding!.add(padding);
      } else {
        padding = widget.headerCellPadding!;
      }
    }
    if (padding != null) {
      headerCellWidget = Padding(padding: padding, child: headerCellWidget);
    }
    return ConstrainedBox(
        constraints: BoxConstraints.tightFor(width: width),
        child: headerCellWidget);
  }
}
