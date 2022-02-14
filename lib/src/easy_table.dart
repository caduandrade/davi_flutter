import 'dart:math' as math;
import 'package:easy_table/src/easy_table_column.dart';
import 'package:easy_table/src/private/easy_table_header_cell.dart';
import 'package:easy_table/src/easy_table_model.dart';
import 'package:easy_table/src/private/easy_table_scroll_controller.dart';
import 'package:easy_table/src/private/layout/top_center_layout.dart';
import 'package:easy_table/src/row_callbacks.dart';
import 'package:easy_table/src/row_hover_listener.dart';
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
    _headerHorizontalScrollController
        .jumpTo(_horizontalScrollController.offset);
  }

  @override
  Widget build(BuildContext context) {
    Widget table = LayoutBuilder(builder: (context, constraints) {
      if (widget.model != null) {
        EasyTableModel<ROW> model = widget.model!;
        EasyTableThemeData theme = EasyTableTheme.of(context);

        double rowHeight = theme.cell.contentHeight;
        if (theme.cell.padding != null) {
          rowHeight += theme.cell.padding!.vertical;
        }

        double requiredWidth = model.columnsWidth;
        requiredWidth += (model.columnsLength) * theme.columnDividerThickness;
        double maxWidth = math.max(constraints.maxWidth, requiredWidth);
        return TopCenterLayout(
            top: ScrollConfiguration(
                behavior:
                    ScrollConfiguration.of(context).copyWith(scrollbars: false),
                child: SingleChildScrollView(
                    controller: _headerHorizontalScrollController,
                    scrollDirection: Axis.horizontal,
                    child: _header(
                        context: context, model: model, maxWidth: maxWidth))),
            center: Scrollbar(
                isAlwaysShown: true,
                controller: _horizontalScrollController,
                child: _rows(
                    context: context,
                    model: model,
                    maxWidth: maxWidth,
                    rowHeight: rowHeight)));
      }
      return Container();
    });
    EasyTableThemeData theme = EasyTableTheme.of(context);
    if (theme.decoration != null) {
      table = Container(child: table, decoration: theme.decoration);
    }
    return table;
  }

  /// Builds a headers
  Widget _header(
      {required BuildContext context,
      required EasyTableModel<ROW> model,
      required double maxWidth}) {
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
    HeaderThemeData headerTheme = EasyTableTheme.of(context).header;
    BoxDecoration? decoration;
    if (headerTheme.bottomBorder != null) {
      decoration =
          BoxDecoration(border: Border(bottom: headerTheme.bottomBorder!));
    }
    return Container(
        child: Row(
            children: children, crossAxisAlignment: CrossAxisAlignment.stretch),
        width: maxWidth,
        decoration: decoration);
  }

  /// Builds the table content.
  Widget _rows(
      {required BuildContext context,
      required EasyTableModel<ROW> model,
      required double maxWidth,
      required double rowHeight}) {
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
                    child: MouseRegion(
                        child: ListView.builder(
                            controller: _verticalScrollController,
                            itemExtent: rowHeight + theme.rowDividerThickness,
                            itemBuilder: (context, index) {
                              return _row(
                                  context: context,
                                  model: model,
                                  rowIndex: index,
                                  rowHeight: rowHeight);
                            },
                            itemCount: model.rowsLength),
                        onExit: (event) => _setHoveredRowIndex(null))),
                width: maxWidth)));
  }

  /// Builds a single table row.
  Widget _row(
      {required BuildContext context,
      required EasyTableModel<ROW> model,
      required int rowIndex,
      required double rowHeight}) {
    EasyTableThemeData theme = EasyTableTheme.of(context);
    ROW row = model.visibleRowAt(rowIndex);
    List<Widget> children = [];
    for (int columnIndex = 0;
        columnIndex < model.columnsLength;
        columnIndex++) {
      EasyTableColumn<ROW> column = model.columnAt(columnIndex);
      children.add(_cell(
          context: context,
          row: row,
          column: column,
          rowIndex: rowIndex,
          rowHeight: rowHeight));
    }
    Widget rowWidget = Row(
      children: children,
      crossAxisAlignment: CrossAxisAlignment.stretch,
    );

    if (_hoveredRowIndex == rowIndex && theme.hoveredRowColor != null) {
      rowWidget =
          Container(child: rowWidget, color: theme.hoveredRowColor!(rowIndex));
    } else if (theme.rowColor != null) {
      rowWidget = Container(child: rowWidget, color: theme.rowColor!(rowIndex));
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
        onEnter: (event) => _setHoveredRowIndex(rowIndex));

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
      required int rowIndex,
      required double rowHeight}) {
    Widget? cell = column.buildCellWidget(context, row);
    return _wrapWithColumnGap(
        context: context, column: column, widget: cell ?? Container());
  }

  /// Builds a table header cell.
  Widget _headerCell(
      {required BuildContext context,
      required EasyTableModel<ROW> model,
      required EasyTableColumn<ROW> column,
      required int columnIndex}) {
    Widget headerCell = EasyTableHeaderCell<ROW>(model: model, column: column);
    return _wrapWithColumnGap(
        context: context, column: column, widget: headerCell);
  }

  Widget _wrapWithColumnGap(
      {required BuildContext context,
      required EasyTableColumn<ROW> column,
      required Widget widget}) {
    widget = ClipRect(child: widget);
    EasyTableThemeData theme = EasyTableTheme.of(context);
    double width = column.width;

    if (theme.columnDividerThickness > 0) {
      width += theme.columnDividerThickness;
      if (theme.columnDividerColor != null) {
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
