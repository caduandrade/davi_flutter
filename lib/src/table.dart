import 'dart:math' as math;
import 'package:easy_table/src/cell.dart';
import 'package:easy_table/src/column.dart';
import 'package:easy_table/src/private/header_cell.dart';
import 'package:easy_table/src/model.dart';
import 'package:easy_table/src/private/scroll_controller.dart';
import 'package:easy_table/src/private/table_layout.dart';
import 'package:easy_table/src/row_callbacks.dart';
import 'package:easy_table/src/row_hover_listener.dart';
import 'package:easy_table/src/theme/header_theme_data.dart';
import 'package:easy_table/src/theme/theme.dart';
import 'package:easy_table/src/theme/theme_data.dart';
import 'package:flutter/material.dart';

/// Table view designed for a large number of data.
///
/// The type [ROW] represents the data of each row.
class EasyTable<ROW> extends StatefulWidget {
//TODO handle negative values
//TODO allow null and use defaults?
  const EasyTable(this.model,
      {Key? key,
      this.horizontalScrollController,
      this.verticalScrollController,
      this.onHoverListener,
      this.onRowTap,
      this.onRowDoubleTap})
      : super(key: key);

  final EasyTableModel<ROW>? model;
  final ScrollController? horizontalScrollController;
  final ScrollController? verticalScrollController;
  final OnRowHoverListener? onHoverListener;
  final RowDoubleTapCallback<ROW>? onRowDoubleTap;
  final RowTapCallback<ROW>? onRowTap;

  @override
  State<StatefulWidget> createState() => _EasyTableState<ROW>();
}

/// The [EasyTable] state.
class _EasyTableState<ROW> extends State<EasyTable<ROW>> {
  late ScrollController _verticalScrollController;
  late ScrollController _horizontalScrollController;

  final ScrollController _headerHorizontalScrollController = ScrollController();

  int? _hoveredRowIndex;
  void _setHoveredRowIndex(int? value) {
    if (_hoveredRowIndex != value) {
      setState(() {
        _hoveredRowIndex = value;
      });
      if (widget.onHoverListener != null) {
        widget.onHoverListener!(_hoveredRowIndex);
      }
    }
  }

  @override
  void initState() {
    super.initState();

    widget.model?.addListener(_rebuild);

    _horizontalScrollController =
        widget.horizontalScrollController ?? EasyTableScrollController();
    _verticalScrollController =
        widget.verticalScrollController ?? EasyTableScrollController();

    _horizontalScrollController.addListener(_syncHorizontalScroll);
  }

  @override
  void dispose() {
    widget.model?.removeListener(_rebuild);
    _horizontalScrollController.removeListener(_syncHorizontalScroll);
    super.dispose();
  }

  @override
  void didUpdateWidget(covariant EasyTable<ROW> oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (widget.model != oldWidget.model) {
      oldWidget.model?.removeListener(_rebuild);
      widget.model?.addListener(_rebuild);
    }
    if (widget.horizontalScrollController != null) {
      _horizontalScrollController.removeListener(_syncHorizontalScroll);
      _horizontalScrollController = widget.horizontalScrollController!;
      _horizontalScrollController.addListener(_syncHorizontalScroll);
    }
    if (widget.verticalScrollController != null) {
      _verticalScrollController = widget.verticalScrollController!;
    }
  }

  void _rebuild() {
    setState(() {});
  }

  void _syncHorizontalScroll() {
    if (_headerHorizontalScrollController.hasClients) {
      _headerHorizontalScrollController
          .jumpTo(_horizontalScrollController.offset);
    }
  }

  @override
  Widget build(BuildContext context) {
    Widget table = LayoutBuilder(builder: (context, constraints) {
      if (widget.model != null) {
        EasyTableModel<ROW> model = widget.model!;
        EasyTableThemeData theme = EasyTableTheme.of(context);

        double contentWidth = model.columnsWidth;
        contentWidth += (model.columnsLength) * theme.columnDividerThickness;
        contentWidth = math.max(constraints.maxWidth, contentWidth);

        HeaderThemeData headerTheme = EasyTableTheme.of(context).header;

        return TableLayout(
            header: headerTheme.height > 0
                ? _scrollableHeader(context: context, model: model)
                : null,
            body: _tableContent(
                context: context, model: model, contentWidth: contentWidth));
      }
      return Container();
    });
    EasyTableThemeData theme = EasyTableTheme.of(context);
    if (theme.decoration != null) {
      table = Container(child: table, decoration: theme.decoration);
    }
    return table;
  }

  Widget _scrollableHeader(
      {required BuildContext context, required EasyTableModel<ROW> model}) {
    return CustomScrollView(
        controller: _headerHorizontalScrollController,
        scrollDirection: Axis.horizontal,
        slivers: [
          SliverToBoxAdapter(child: _header(context: context, model: model))
        ]);
  }

  /// Builds the header
  Widget _header(
      {required BuildContext context, required EasyTableModel<ROW> model}) {
    List<Widget> children = [];
    for (int columnIndex = 0;
        columnIndex < model.columnsLength;
        columnIndex++) {
      EasyTableColumn<ROW> column = model.columnAt(columnIndex);
      children.add(_headerCell(
          context: context,
          model: model,
          column: column,
          columnIndex: columnIndex));
    }
    return Row(
        children: children, crossAxisAlignment: CrossAxisAlignment.stretch);
  }

  /// Builds the table content.
  Widget _tableContent(
      {required BuildContext context,
      required EasyTableModel<ROW> model,
      required double contentWidth}) {
    EasyTableThemeData theme = EasyTableTheme.of(context);

    double rowHeight = theme.cell.contentHeight;
    if (theme.cell.padding != null) {
      rowHeight += theme.cell.padding!.vertical;
    }

    Widget list = ListView.builder(
        controller: _verticalScrollController,
        itemExtent: rowHeight + theme.rowDividerThickness,
        itemBuilder: (context, index) {
          return _row(
              context: context,
              model: model,
              visibleRowIndex: index,
              rowHeight: rowHeight);
        },
        itemCount: model.visibleRowsLength);

    if (theme.columnDividerThickness > 0 && theme.columnDividerColor != null) {
      list = CustomPaint(
          child: list,
          foregroundPainter: _DividersPainter(
              model: model,
              columnDividerThickness: theme.columnDividerThickness,
              columnDividerColor: theme.columnDividerColor!));
    }

    return Scrollbar(
        isAlwaysShown: true,
        controller: _horizontalScrollController,
        child: Scrollbar(
            isAlwaysShown: true,
            controller: _verticalScrollController,
            notificationPredicate: (p) {
              return true;
            },
            child: CustomScrollView(
                scrollDirection: Axis.horizontal,
                controller: _horizontalScrollController,
                slivers: [
                  SliverToBoxAdapter(
                      child: SizedBox(
                          child: ScrollConfiguration(
                              behavior: ScrollConfiguration.of(context)
                                  .copyWith(scrollbars: false),
                              child: MouseRegion(
                                  child: list,
                                  onExit: (event) =>
                                      _setHoveredRowIndex(null))),
                          width: contentWidth))
                ])));
  }

  /// Builds a single table row.
  Widget _row(
      {required BuildContext context,
      required EasyTableModel<ROW> model,
      required int visibleRowIndex,
      required double rowHeight}) {
    EasyTableThemeData theme = EasyTableTheme.of(context);
    ROW row = model.visibleRowAt(visibleRowIndex);
    List<Widget> children = [];
    for (int columnIndex = 0;
        columnIndex < model.columnsLength;
        columnIndex++) {
      EasyTableColumn<ROW> column = model.columnAt(columnIndex);
      children.add(_cell(
          context: context,
          row: row,
          column: column,
          visibleRowIndex: visibleRowIndex,
          rowHeight: rowHeight));
    }
    Widget rowWidget = Row(
      children: children,
      crossAxisAlignment: CrossAxisAlignment.stretch,
    );

    if (_hoveredRowIndex == visibleRowIndex && theme.hoveredRowColor != null) {
      rowWidget = Container(
          child: rowWidget, color: theme.hoveredRowColor!(visibleRowIndex));
    } else if (theme.rowColor != null) {
      rowWidget =
          Container(child: rowWidget, color: theme.rowColor!(visibleRowIndex));
    }

    MouseCursor cursor = MouseCursor.defer;

    if (widget.onRowTap != null || widget.onRowDoubleTap != null) {
      cursor = SystemMouseCursors.click;
      rowWidget = GestureDetector(
        behavior: HitTestBehavior.opaque,
        child: rowWidget,
        onDoubleTap: widget.onRowDoubleTap != null
            ? () => widget.onRowDoubleTap!(row)
            : null,
        onTap: widget.onRowTap != null ? () => widget.onRowTap!(row) : null,
      );
    }

    rowWidget = MouseRegion(
        cursor: cursor,
        child: rowWidget,
        onEnter: (event) => _setHoveredRowIndex(visibleRowIndex));

    if (theme.rowDividerThickness > 0) {
      rowWidget = Padding(
          child: rowWidget,
          padding: EdgeInsets.only(bottom: theme.rowDividerThickness));
    }

    return rowWidget;
  }

  /// Builds a table cell.
  Widget _cell(
      {required BuildContext context,
      required ROW row,
      required EasyTableColumn<ROW> column,
      required int visibleRowIndex,
      required double rowHeight}) {
    EasyTableThemeData theme = EasyTableTheme.of(context);
    Widget? cell;

    if (column.cellBuilder != null) {
      cell = column.cellBuilder!(context, row);
    } else {
      final TextStyle? textStyle = theme.cell.textStyle;
      bool nullValue = false;
      if (column.stringValueMapper != null) {
        final String? value = column.stringValueMapper!(row);
        if (value != null) {
          cell = EasyTableCell.string(value: value, textStyle: textStyle);
        } else {
          nullValue = true;
        }
      } else if (column.intValueMapper != null) {
        final int? value = column.intValueMapper!(row);
        if (value != null) {
          cell = EasyTableCell.int(value: value, textStyle: textStyle);
        } else {
          nullValue = true;
        }
      } else if (column.doubleValueMapper != null) {
        final double? value = column.doubleValueMapper!(row);
        if (value != null) {
          cell = EasyTableCell.double(
              value: value,
              fractionDigits: column.fractionDigits,
              textStyle: textStyle);
        } else {
          nullValue = true;
        }
      } else if (column.objectValueMapper != null) {
        final Object? value = column.objectValueMapper!(row);
        if (value != null) {
          return EasyTableCell.string(
              value: value.toString(), textStyle: textStyle);
        } else {
          nullValue = true;
        }
      }
      if (nullValue && theme.nullCellColor != null) {
        cell = Container(color: theme.nullCellColor!(visibleRowIndex));
      }
    }
    return _wrapWithColumnGap(
        context: context,
        column: column,
        widget: cell ?? Container(),
        paintDivider: false);
  }

  /// Builds a table header cell.
  Widget _headerCell(
      {required BuildContext context,
      required EasyTableModel<ROW> model,
      required EasyTableColumn<ROW> column,
      required int columnIndex}) {
    Widget headerCell = EasyTableHeaderCell<ROW>(model: model, column: column);
    return _wrapWithColumnGap(
        context: context,
        column: column,
        widget: headerCell,
        paintDivider: true);
  }

  Widget _wrapWithColumnGap(
      {required BuildContext context,
      required EasyTableColumn<ROW> column,
      required Widget widget,
      required bool paintDivider}) {
    widget = ClipRect(child: widget);
    EasyTableThemeData theme = EasyTableTheme.of(context);
    double width = column.width;

    if (theme.columnDividerThickness > 0) {
      width += theme.columnDividerThickness;
      if (paintDivider && theme.columnDividerColor != null) {
        widget = Container(
            child: widget,
            decoration: BoxDecoration(
                border: Border(
                    right: BorderSide(
                        width: theme.columnDividerThickness,
                        color: theme.columnDividerColor!))));
      } else {
        widget = Padding(
            padding: EdgeInsets.only(right: theme.columnDividerThickness),
            child: widget);
      }
    }
    return ConstrainedBox(
        constraints: BoxConstraints.tightFor(width: width), child: widget);
  }
}

class _DividersPainter extends CustomPainter {
  _DividersPainter(
      {required this.model,
      required this.columnDividerThickness,
      required this.columnDividerColor});

  final EasyTableModel model;
  final Color columnDividerColor;
  final double columnDividerThickness;

  @override
  void paint(Canvas canvas, Size size) {
    Paint paint = Paint()..color = columnDividerColor;
    double x = 0;
    for (int i = 0; i < model.columnsLength; i++) {
      EasyTableColumn column = model.columnAt(i);
      x += column.width;
      canvas.drawRect(
          Rect.fromLTRB(x, 0, x + columnDividerThickness, size.height), paint);
      x += columnDividerThickness;
    }
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => true;
}
