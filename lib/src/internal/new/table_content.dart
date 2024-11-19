import 'package:davi/davi.dart';
import 'package:davi/src/internal/cell_widget.dart';
import 'package:davi/src/internal/layout_utils.dart';
import 'package:davi/src/internal/new/cells_layout.dart';
import 'package:davi/src/internal/new/cells_layout_child.dart';
import 'package:davi/src/internal/new/hover_notifier.dart';
import 'package:davi/src/internal/new/row_region.dart';
import 'package:davi/src/internal/new/table_events.dart';
import 'package:davi/src/internal/row_callbacks.dart';
import 'package:davi/src/internal/scroll_offsets.dart';
import 'package:davi/src/internal/table_layout_settings.dart';
import 'package:davi/src/trailing_widget_listener.dart';
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
    required this.onTrailingWidget,
    required this.onLastVisibleRow,
    required this.trailingWidget,
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
  final Widget? trailingWidget;
  final TrailingWidgetListener onTrailingWidget;
  final LastVisibleRowListener onLastVisibleRow;

  @override
  Widget build(BuildContext context) {
    return ListenableBuilder(
        listenable: verticalScrollController,
        builder: (BuildContext context, Widget? child) {
          return LayoutBuilder(builder: _builder);
        });
  }

  Widget _builder(BuildContext context, BoxConstraints constraints){
    //TODO null hover on resizing
    DaviThemeData theme = DaviTheme.of(context);

    final double verticalOffset = verticalScrollController.hasClients
        ? verticalScrollController.offset
        : 0;

    final int firstRowIndex =
    (verticalOffset / layoutSettings.themeMetrics.row.height).floor();

    List<CellsLayoutChild> children = [];

    final RowRegionCache rowRegionCache = RowRegionCache();

    bool trailingWidgetBuilt = false;
    int? lastVisibleRowIndex;

    // This is used to determine if an extra row might become partially
    // visible during scrolling, allowing preemptive
    // caching to improve performance.
    double rowsHeightBuffer = 0;
    if(constraints.maxHeight % layoutSettings.themeMetrics.row.height==0) {
      rowsHeightBuffer = layoutSettings.themeMetrics.row.height;
    }

    int childIndex = 0;

    int rowIndex= firstRowIndex;
    double rowY = (firstRowIndex *  layoutSettings.themeMetrics.row.height) -verticalOffset;
    while(rowY < constraints.maxHeight + rowsHeightBuffer) {
      final Rect bounds = Rect.fromLTWH(0, rowY, constraints.maxWidth, layoutSettings.themeMetrics.cell.height);

      DATA? data;
      if (model != null && rowIndex < model!.rowsLength) {
        data = model!.rowAt(rowIndex);
      }

      bool trailingRegion=false;
      if(trailingWidget!=null && !trailingWidgetBuilt && data==null) {
           trailingWidgetBuilt=true;
           trailingRegion=true;
            children.add(CellsLayoutChild.trailing(child: trailingWidget!));
      }

      //TODO bool visible?

      rowRegionCache.add(RowRegion(index: rowIndex, bounds: bounds, hasData: data!=null, y:rowY, trailing:trailingRegion));

      for(int columnIndex = 0; columnIndex < layoutSettings.columnsMetrics.length ; columnIndex++) {
        if(data!=null){
          //TODO hovered
          DaviRow<DATA> row = DaviRow(data: data, index: rowIndex, hovered: false);
          final DaviColumn<DATA> column = model!.columnAt(columnIndex);
          final CellWidget<DATA> cell =
          CellWidget(column: column, columnIndex: columnIndex, row: row, hoverIndexNotifier:hoverIndex);
          children.add(CellsLayoutChild.cell(childIndex: childIndex, rowIndex: rowIndex, columnIndex: columnIndex, child: cell));
          lastVisibleRowIndex=rowIndex;
        } else {
          children.add(CellsLayoutChild.cell(childIndex: childIndex, rowIndex: rowIndex, columnIndex: columnIndex, child: Text('$childIndex')));
        }
        childIndex++;
      }

      rowY+=layoutSettings.themeMetrics.row.height;
      rowIndex++;
    }

    onTrailingWidget(trailingWidgetBuilt);
    onLastVisibleRow(lastVisibleRowIndex);

    CellsLayout cellsLayout= CellsLayout(layoutSettings: layoutSettings, verticalOffset:verticalOffset,horizontalScrollOffsets:horizontalScrollOffsets,
        leftPinnedAreaBounds:layoutSettings.getAreaBounds(PinStatus.left), unpinnedAreaBounds:layoutSettings.getAreaBounds(PinStatus.none),
        rowsLength: layoutSettings.rowsLength,
        hoverIndex: hoverIndex,
        rowRegionCache:rowRegionCache,
        children: children);

    return ClipRect(child:TableEvents(model: model,
        rowBoundsCache: rowRegionCache,
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

