import 'package:davi/davi.dart';
import 'package:davi/src/internal/cell_widget.dart';
import 'package:davi/src/internal/layout_utils.dart';
import 'package:davi/src/internal/new/cells_layout.dart';
import 'package:davi/src/internal/new/cells_layout_child.dart';
import 'package:davi/src/internal/new/hover_notifier.dart';
import 'package:davi/src/internal/new/row_bounds.dart';
import 'package:davi/src/internal/new/row_region.dart';
import 'package:davi/src/internal/new/table_events.dart';
import 'package:davi/src/internal/row_callbacks.dart';
import 'package:davi/src/internal/scroll_offsets.dart';
import 'package:davi/src/internal/table_layout_settings.dart';
import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';
import 'package:meta/meta.dart';

@internal
class TableContent<DATA> extends StatelessWidget {

  const TableContent({Key? key, required this.layoutSettings,required this.verticalScrollController,
    required this.horizontalScrollOffsets,required this.hoverIndex,
    required this.onHover,
    required  this.rowCallbacks,
    required this.rowCursorBuilder,
    required this.model, required this.focusable, required this.scrolling, required this.focusNode}) : super(key: key);

  final TableLayoutSettings layoutSettings;
  final ScrollController verticalScrollController;
  final HorizontalScrollOffsets horizontalScrollOffsets;
  final HoverNotifier hoverIndex;
  final OnRowHoverListener? onHover;
  final RowCallbacks<DATA> rowCallbacks;
  final RowCursorBuilder<DATA>? rowCursorBuilder;
  final bool focusable;
  final bool scrolling;
  final FocusNode focusNode;
  final DaviModel<DATA>? model;

  @override
  Widget build(BuildContext context) {
    return ListenableBuilder(
        listenable: verticalScrollController,
        builder: (BuildContext context, Widget? child) {
          return LayoutBuilder(builder: _builder);
        });
  }

  Widget _builder(BuildContext context, BoxConstraints constraints){
    DaviThemeData theme = DaviTheme.of(context);

    final double verticalOffset = verticalScrollController.hasClients
        ? verticalScrollController.offset
        : 0;

    final int firstRowIndex =
    (verticalOffset / layoutSettings.themeMetrics.row.height).floor();
    
    final int maxRowsLength = LayoutUtils.maxRowsLength(
        visibleAreaHeight: layoutSettings.cellsBounds.height,
        rowHeight: layoutSettings.themeMetrics.row.height);

    final RowBoundsCache rowBoundsCache = RowBoundsCache();

    for (int rowIndex = firstRowIndex;  rowIndex <= firstRowIndex + maxRowsLength;  rowIndex++) {
      final double top = (rowIndex *  layoutSettings.themeMetrics.row.height) -verticalOffset;
      final Rect bounds = Rect.fromLTWH(0, top, constraints.maxWidth, layoutSettings.themeMetrics.cell.height);
      rowBoundsCache.add(RowBounds(index: rowIndex, bounds: bounds));
    }

    List<CellsLayoutChild> children = [];

    if (model != null) {
      if (model!.rowsLength > 0) {
        int visualIndex = 0;
        for (int rowIndex = firstRowIndex;  rowIndex <= firstRowIndex + maxRowsLength;  rowIndex++) {
          DATA? data;
          if(rowIndex<model!.rowsLength) {
            data=model!.rowAt(rowIndex);
          }

          if(data!=null){
            RowRegion<DATA> rowRegion = RowRegion(index: rowIndex, data: data, onHover: onHover, cursor: rowCursorBuilder, rowCallbacks: rowCallbacks, horizontalScrollOffsets: horizontalScrollOffsets, hoverIndexNotifier: hoverIndex);
            //TODO remove
           // children.add(CellsLayoutChild.row(childIndex: visualIndex, rowIndex: rowIndex, child: rowRegion));
          }

          for(int columnIndex = 0; columnIndex < layoutSettings.columnsMetrics.length ; columnIndex++) {
            if(data!=null){
              //TODO hovered
              DaviRow<DATA> row = DaviRow(data: data, index: rowIndex, hovered: false);
              final DaviColumn<DATA> column = model!.columnAt(columnIndex);
              final CellWidget<DATA> cell =
              CellWidget(column: column, columnIndex: columnIndex, row: row, hoverIndexNotifier:hoverIndex);
              children.add(CellsLayoutChild.cell(childIndex: visualIndex, rowIndex: rowIndex, columnIndex: columnIndex, child: cell));
            } else {
              children.add(CellsLayoutChild.cell(childIndex: visualIndex, rowIndex: rowIndex, columnIndex: columnIndex, child: Text('$visualIndex')));
            }
            visualIndex++;
          }
        }
      }
    }


    CellsLayout cellsLayout= CellsLayout(layoutSettings: layoutSettings, verticalOffset:verticalOffset,horizontalScrollOffsets:horizontalScrollOffsets,
        leftPinnedAreaBounds:layoutSettings.getAreaBounds(PinStatus.left), unpinnedAreaBounds:layoutSettings.getAreaBounds(PinStatus.none),
        rowsLength: layoutSettings.rowsLength,
          hoverIndex: hoverIndex,
        rowBoundsCache:rowBoundsCache,
        children: children);
  

    return ClipRect(child:TableEvents(model: model,
        rowBoundsCache: rowBoundsCache,
        verticalScrollController: verticalScrollController,
        scrolling: scrolling,
        focusNode: focusNode,
        hoverIndex: hoverIndex,
        rowCallbacks: rowCallbacks,
        onHover: onHover,
        rowCursorBuilder: rowCursorBuilder,
        focusable: focusable,
        rowTheme: theme.row,
        child: cellsLayout));
    
  }
 
}

