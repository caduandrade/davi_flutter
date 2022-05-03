import 'dart:math' as math;
import 'package:easy_table/src/cell.dart';
import 'package:easy_table/src/column.dart';
import 'package:easy_table/src/internal/columns_metrics.dart';
import 'package:easy_table/src/internal/divider_painter.dart';
import 'package:easy_table/src/internal/header_cell.dart';
import 'package:easy_table/src/internal/scroll_controller.dart';
import 'package:easy_table/src/internal/table_layout.dart';
import 'package:easy_table/src/model.dart';
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
      this.unpinnedHorizontalScrollController,
      this.verticalScrollController,
      this.pinnedHorizontalScrollController,
      this.onHoverListener,
      this.onRowTap,
      this.onRowDoubleTap,
      this.columnsFit = false,
      int? visibleRowsCount})
      : _visibleRowsCount = visibleRowsCount == null || visibleRowsCount > 0
            ? visibleRowsCount
            : null,
        super(key: key);

  final EasyTableModel<ROW>? model;
  final ScrollController? unpinnedHorizontalScrollController;
  final ScrollController? verticalScrollController;
  final ScrollController? pinnedHorizontalScrollController;
  final OnRowHoverListener? onHoverListener;
  final RowDoubleTapCallback<ROW>? onRowDoubleTap;
  final RowTapCallback<ROW>? onRowTap;
  final bool columnsFit;
  final int? _visibleRowsCount;

  int? get visibleRowsCount => _visibleRowsCount;

  @override
  State<StatefulWidget> createState() => _EasyTableState<ROW>();
}

/// The [EasyTable] state.
class _EasyTableState<ROW> extends State<EasyTable<ROW>> {
  late ScrollController _unpinnedVerticalScrollController;
  late ScrollController _unpinnedHorizontalScrollController;

  late ScrollController _pinnedVerticalScrollController;
  late ScrollController _pinnedHorizontalScrollController;

  final ScrollController _unpinnedHeaderHorizontalScrollController = ScrollController();
  final ScrollController _pinnedHeaderHorizontalScrollController =
      ScrollController();

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

    _unpinnedHorizontalScrollController =
        widget.unpinnedHorizontalScrollController ?? EasyTableScrollController();
    _unpinnedVerticalScrollController =
        widget.verticalScrollController ?? EasyTableScrollController();

    _pinnedHorizontalScrollController =
        widget.pinnedHorizontalScrollController ?? EasyTableScrollController();
    _pinnedVerticalScrollController = EasyTableScrollController();

    _unpinnedHorizontalScrollController.addListener(_syncUnpinnedHeaderHorizontalScrolls);
    _pinnedHorizontalScrollController.addListener(_syncPinnedHeaderHorizontalScrolls);
    _unpinnedVerticalScrollController.addListener(_syncPinnedVerticalScrolls);
    _pinnedVerticalScrollController.addListener(_syncUnpinnedVerticalScrolls);
  }

  @override
  void dispose() {
    widget.model?.removeListener(_rebuild);
    _unpinnedHorizontalScrollController.removeListener(_syncUnpinnedHeaderHorizontalScrolls);
    _pinnedHorizontalScrollController
        .removeListener(_syncPinnedHeaderHorizontalScrolls);
    _unpinnedVerticalScrollController.removeListener(_syncPinnedVerticalScrolls);
    _pinnedVerticalScrollController.removeListener(_syncUnpinnedVerticalScrolls);
    super.dispose();
  }

  @override
  void didUpdateWidget(covariant EasyTable<ROW> oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (widget.model != oldWidget.model) {
      oldWidget.model?.removeListener(_rebuild);
      widget.model?.addListener(_rebuild);
    }
    if (widget.verticalScrollController != null) {
      _unpinnedVerticalScrollController.removeListener(_syncPinnedVerticalScrolls);
      _unpinnedVerticalScrollController = widget.verticalScrollController!;
      _unpinnedVerticalScrollController.addListener(_syncPinnedVerticalScrolls);
    }
    if (widget.unpinnedHorizontalScrollController != null) {
      _unpinnedHorizontalScrollController
          .removeListener(_syncUnpinnedHeaderHorizontalScrolls);
      _unpinnedHorizontalScrollController = widget.unpinnedHorizontalScrollController!;
      _unpinnedHorizontalScrollController.addListener(_syncUnpinnedHeaderHorizontalScrolls);
    }
    if (widget.pinnedHorizontalScrollController != null) {
      _pinnedHorizontalScrollController
          .removeListener(_syncPinnedHeaderHorizontalScrolls);
      _pinnedHorizontalScrollController =
          widget.pinnedHorizontalScrollController!;
      _pinnedHorizontalScrollController
          .addListener(_syncPinnedHeaderHorizontalScrolls);
    }
    if (widget.verticalScrollController != null) {
      _unpinnedVerticalScrollController = widget.verticalScrollController!;
    }
  }

  void _rebuild() {
    setState(() {});
  }

  void _syncUnpinnedHeaderHorizontalScrolls() {
    if (_unpinnedHeaderHorizontalScrollController.hasClients) {
      _unpinnedHeaderHorizontalScrollController
          .jumpTo(_unpinnedHorizontalScrollController.offset);
    }
  }

  void _syncPinnedHeaderHorizontalScrolls() {
    if (_pinnedHeaderHorizontalScrollController.hasClients) {
      _pinnedHeaderHorizontalScrollController
          .jumpTo(_pinnedHorizontalScrollController.offset);
    }
  }

  void _syncPinnedVerticalScrolls() {
    if (_pinnedVerticalScrollController.hasClients) {
      _pinnedVerticalScrollController.jumpTo(_unpinnedVerticalScrollController.offset);
    }
  }

  void _syncUnpinnedVerticalScrolls() {
    if (_unpinnedVerticalScrollController.hasClients) {
      _unpinnedVerticalScrollController.jumpTo(_pinnedVerticalScrollController.offset);
    }
  }

  @override
  Widget build(BuildContext context) {
    Widget table = LayoutBuilder(builder: (context, constraints) {
      if (widget.model != null) {
        EasyTableModel<ROW> model = widget.model!;
        EasyTableThemeData theme = EasyTableTheme.of(context);
        HeaderThemeData headerTheme = theme.header;

        double rowHeight = theme.cell.contentHeight;
        if (theme.cell.padding != null) {
          rowHeight += theme.cell.padding!.vertical;
        }

        final double headerHeight = headerTheme.height;

        Widget? header;
        Widget? pinnedHeader;
        Widget body;
        Widget? pinnedBody;
        double pinnedWidth = 0;

        if (widget.columnsFit) {
          double contentWidth =
              math.max(constraints.maxWidth, model.allColumnsWidth);
          ColumnsMetrics columnsMetrics = ColumnsMetrics.columnsFit(
              model: model,
              containerWidth: constraints.maxWidth,
              columnDividerThickness: theme.columnDividerThickness);

          if (headerHeight > 0) {
            header = _HeaderWidget<ROW>(
                horizontalScrollController: _unpinnedHeaderHorizontalScrollController,
                columnsFit: true,
                model: model,
                columnsMetrics: columnsMetrics,
                contentWidth: contentWidth,
                columnFilter: ColumnFilter.all);
          }
          body = _BodyWidget(
              columnsFit: widget.columnsFit,
              horizontalScrollController: _unpinnedHorizontalScrollController,
              verticalScrollController: _unpinnedVerticalScrollController,
              setHoveredRowIndex: _setHoveredRowIndex,
              hoveredRowIndex: _hoveredRowIndex,
              onRowTap: widget.onRowTap,
              onRowDoubleTap: widget.onRowDoubleTap,
              model: model,
              columnsMetrics: columnsMetrics,
              contentWidth: contentWidth,
              rowHeight: rowHeight,
              columnFilter: ColumnFilter.all);
        } else {
          final int pinnedColumnsLength = model.pinnedColumnsLength;
          final bool hasPinned = pinnedColumnsLength > 0;

          double contentWidth;
          final double pinnedContentWidth = model.pinnedColumnsWidth +
              (pinnedColumnsLength * theme.columnDividerThickness);
          if (hasPinned) {
            pinnedWidth = math.min(pinnedContentWidth, constraints.maxWidth);
            contentWidth = math.max(
                constraints.maxWidth - pinnedWidth,
                model.unpinnedColumnsWidth +
                    (model.unpinnedColumnsLength *
                        theme.columnDividerThickness));
          } else {
            contentWidth = math.max(
                constraints.maxWidth,
                model.allColumnsWidth +
                    (model.columnsLength * theme.columnDividerThickness));
          }

          ColumnsMetrics unpinnedColumnsMetrics = ColumnsMetrics.resizable(
              model: model,
              columnDividerThickness: theme.columnDividerThickness,
              filter: hasPinned ? ColumnFilter.unpinnedOnly : ColumnFilter.all);

          ColumnsMetrics? pinnedColumnsMetrics = hasPinned
              ? ColumnsMetrics.resizable(
                  model: model,
                  columnDividerThickness: theme.columnDividerThickness,
                  filter: ColumnFilter.pinnedOnly)
              : null;

          if (headerHeight > 0) {
            header = _HeaderWidget<ROW>(
                horizontalScrollController: _unpinnedHeaderHorizontalScrollController,
                columnsFit: false,
                model: model,
                columnsMetrics: unpinnedColumnsMetrics,
                contentWidth: contentWidth,
                columnFilter:
                    hasPinned ? ColumnFilter.unpinnedOnly : ColumnFilter.all);
            pinnedHeader = pinnedColumnsMetrics != null
                ? _HeaderWidget<ROW>(
                    horizontalScrollController:
                        _pinnedHeaderHorizontalScrollController,
                    columnsFit: false,
                    model: model,
                    columnsMetrics: pinnedColumnsMetrics,
                    contentWidth: pinnedContentWidth,
                    columnFilter: ColumnFilter.pinnedOnly)
                : null;
          }

          body = _BodyWidget(
              columnsFit: widget.columnsFit,
              horizontalScrollController: _unpinnedHorizontalScrollController,
              verticalScrollController: _unpinnedVerticalScrollController,
              setHoveredRowIndex: _setHoveredRowIndex,
              hoveredRowIndex: _hoveredRowIndex,
              onRowTap: widget.onRowTap,
              onRowDoubleTap: widget.onRowDoubleTap,
              model: model,
              columnsMetrics: unpinnedColumnsMetrics,
              contentWidth: contentWidth,
              rowHeight: rowHeight,
              columnFilter:
                  hasPinned ? ColumnFilter.unpinnedOnly : ColumnFilter.all);

          pinnedBody = pinnedColumnsMetrics != null
              ? _BodyWidget(
                  columnsFit: false,
                  horizontalScrollController: _pinnedHorizontalScrollController,
                  verticalScrollController: _pinnedVerticalScrollController,
                  setHoveredRowIndex: _setHoveredRowIndex,
                  hoveredRowIndex: _hoveredRowIndex,
                  onRowTap: widget.onRowTap,
                  onRowDoubleTap: widget.onRowDoubleTap,
                  model: model,
                  columnsMetrics: pinnedColumnsMetrics,
                  contentWidth: pinnedContentWidth,
                  rowHeight: rowHeight,
                  columnFilter: ColumnFilter.pinnedOnly)
              : null;
        }

        return ClipRect(
            child: TableLayout(
                header: header,
                body: body,
                pinnedBody: pinnedBody,
                pinnedHeader: pinnedHeader,
                rowsCount: model.rowsLength,
                visibleRowsCount: widget.visibleRowsCount,
                rowHeight: rowHeight,
                headerHeight: headerHeight,
                pinnedWidth: pinnedWidth));
      }
      return Container();
    });
    EasyTableThemeData theme = EasyTableTheme.of(context);
    if (theme.decoration != null) {
      table = Container(child: table, decoration: theme.decoration);
    }
    return table;
  }
}

/// Horizontal layout with gap between children
class _HorizontalLayout extends StatelessWidget {
  const _HorizontalLayout(
      {Key? key, required this.columnsMetrics, required this.children})
      : super(key: key);

  final ColumnsMetrics columnsMetrics;
  final List<Widget> children;

  @override
  Widget build(BuildContext context) {
    EasyTableThemeData theme = EasyTableTheme.of(context);
    for (int i = 0; i < children.length; i++) {
      LayoutWidth layoutWidth = columnsMetrics.columns[i];
      children[i] = SizedBox(child: children[i], width: layoutWidth.width);
      if (theme.columnDividerThickness > 0) {
        children[i] = Padding(
            child: children[i],
            padding: EdgeInsets.only(right: theme.columnDividerThickness));
      }
    }
    return Row(
        children: children, crossAxisAlignment: CrossAxisAlignment.stretch);
  }
}

/// Table header
class _HeaderWidget<ROW> extends StatelessWidget {
  const _HeaderWidget(
      {Key? key,
      required this.model,
      required this.columnsMetrics,
      required this.columnsFit,
      required this.horizontalScrollController,
      required this.columnFilter,
      required this.contentWidth})
      : super(key: key);

  final EasyTableModel<ROW> model;
  final ColumnsMetrics columnsMetrics;
  final bool columnsFit;
  final double contentWidth;
  final ScrollController horizontalScrollController;
  final ColumnFilter columnFilter;

  @override
  Widget build(BuildContext context) {
    List<Widget> children = [];
    for (int columnIndex = 0;
        columnIndex < model.columnsLength;
        columnIndex++) {
      EasyTableColumn<ROW> column = model.columnAt(columnIndex);
      if (columnFilter == ColumnFilter.all ||
          (columnFilter == ColumnFilter.unpinnedOnly &&
              column.pinned == false) ||
          (columnFilter == ColumnFilter.pinnedOnly && column.pinned)) {
        children.add(EasyTableHeaderCell<ROW>(
            model: model, column: column, resizable: !columnsFit));
      }
    }

    Widget header =
        _HorizontalLayout(columnsMetrics: columnsMetrics, children: children);

    EasyTableThemeData theme = EasyTableTheme.of(context);

    if (theme.header.columnDividerColor != null) {
      header = CustomPaint(
          child: header,
          foregroundPainter: DividerPainter(
              columnsMetrics: columnsMetrics,
              color: theme.header.columnDividerColor!));
    }

    if (theme.header.bottomBorderHeight > 0 &&
        theme.header.bottomBorderColor != null) {
      header = Container(
          child: header,
          decoration: BoxDecoration(
              border: Border(
                  bottom: BorderSide(
                      width: theme.header.bottomBorderHeight,
                      color: theme.header.bottomBorderColor!))));
    }

    if (columnsFit) {
      return header;
    }
    // scrollable header
    return CustomScrollView(
        controller: horizontalScrollController,
        scrollDirection: Axis.horizontal,
        slivers: [
          SliverToBoxAdapter(
              child: SizedBox(child: header, width: contentWidth))
        ]);
  }
}

typedef SetHoveredRowIndex = void Function(int? value);

class _BodyWidget<ROW> extends StatelessWidget {
  const _BodyWidget(
      {Key? key,
      required this.model,
      required this.verticalScrollController,
      required this.horizontalScrollController,
      required this.columnsMetrics,
      required this.contentWidth,
      required this.rowHeight,
      required this.columnsFit,
      this.onRowTap,
      this.onRowDoubleTap,
      this.hoveredRowIndex,
      required this.columnFilter,
      required this.setHoveredRowIndex})
      : super(key: key);

  final EasyTableModel<ROW> model;
  final ScrollController verticalScrollController;
  final ScrollController horizontalScrollController;
  final ColumnsMetrics columnsMetrics;
  final double contentWidth;
  final double rowHeight;
  final bool columnsFit;
  final RowTapCallback<ROW>? onRowTap;
  final RowDoubleTapCallback<ROW>? onRowDoubleTap;
  final int? hoveredRowIndex;
  final SetHoveredRowIndex setHoveredRowIndex;
  final ColumnFilter columnFilter;

  @override
  Widget build(BuildContext context) {
    EasyTableThemeData theme = EasyTableTheme.of(context);

    Widget list = ListView.builder(
        controller: verticalScrollController,
        itemExtent: rowHeight + theme.rowDividerThickness,
        itemBuilder: (context, index) {
          return _row(
              context: context,
              model: model,
              columnsMetrics: columnsMetrics,
              visibleRowIndex: index,
              columnFilter: columnFilter);
        },
        itemCount: model.visibleRowsLength);

    if (theme.row.columnDividerColor != null) {
      list = CustomPaint(
          child: list,
          foregroundPainter: DividerPainter(
              columnsMetrics: columnsMetrics,
              color: theme.row.columnDividerColor!));
    }

    list =
        MouseRegion(child: list, onExit: (event) => setHoveredRowIndex(null));

    if (columnsFit) {
      return Scrollbar(
          isAlwaysShown: true,
          controller: verticalScrollController,
          child: list);
    }

    CustomScrollView customScrollView = CustomScrollView(
        scrollDirection: Axis.horizontal,
        controller: horizontalScrollController,
        slivers: [
          SliverToBoxAdapter(
              child: SizedBox(
                  child: ScrollConfiguration(
                      behavior: ScrollConfiguration.of(context)
                          .copyWith(scrollbars: false),
                      child: list),
                  width: contentWidth))
        ]);

    if (columnFilter == ColumnFilter.pinnedOnly) {
      return Scrollbar(
          isAlwaysShown: true,
          controller: horizontalScrollController,
          child: customScrollView);
    }
    return Scrollbar(
        isAlwaysShown: true,
        controller: horizontalScrollController,
        child: Scrollbar(
            isAlwaysShown: true,
            controller: verticalScrollController,
            notificationPredicate: (p) {
              return true;
            },
            child: customScrollView));
  }

  /// Builds a single table row.
  Widget _row(
      {required BuildContext context,
      required EasyTableModel<ROW> model,
      required ColumnsMetrics columnsMetrics,
      required int visibleRowIndex,
      required ColumnFilter columnFilter}) {
    EasyTableThemeData theme = EasyTableTheme.of(context);
    ROW row = model.visibleRowAt(visibleRowIndex);
    List<Widget> children = [];
    for (int columnIndex = 0;
        columnIndex < model.columnsLength;
        columnIndex++) {
      EasyTableColumn<ROW> column = model.columnAt(columnIndex);
      if (columnFilter == ColumnFilter.all ||
          (columnFilter == ColumnFilter.unpinnedOnly &&
              column.pinned == false) ||
          (columnFilter == ColumnFilter.pinnedOnly && column.pinned)) {
        children.add(_cell(
            context: context,
            row: row,
            column: column,
            visibleRowIndex: visibleRowIndex));
      }
    }

    Widget rowWidget =
        _HorizontalLayout(columnsMetrics: columnsMetrics, children: children);

    if (hoveredRowIndex == visibleRowIndex && theme.row.hoveredColor != null) {
      rowWidget = Container(
          child: rowWidget, color: theme.row.hoveredColor!(visibleRowIndex));
    } else if (theme.row.color != null) {
      rowWidget =
          Container(child: rowWidget, color: theme.row.color!(visibleRowIndex));
    }

    MouseCursor cursor = MouseCursor.defer;

    if (onRowTap != null || onRowDoubleTap != null) {
      cursor = SystemMouseCursors.click;
      rowWidget = GestureDetector(
        behavior: HitTestBehavior.opaque,
        child: rowWidget,
        onDoubleTap: onRowDoubleTap != null ? () => onRowDoubleTap!(row) : null,
        onTap: onRowTap != null ? () => onRowTap!(row) : null,
      );
    }

    rowWidget = MouseRegion(
        cursor: cursor,
        child: rowWidget,
        onEnter: (event) => setHoveredRowIndex(visibleRowIndex));

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
      required int visibleRowIndex}) {
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
      if (nullValue && theme.cell.nullValueColor != null) {
        cell = Container(color: theme.cell.nullValueColor!(visibleRowIndex));
      }
    }
    return ClipRect(child: cell);
  }
}
