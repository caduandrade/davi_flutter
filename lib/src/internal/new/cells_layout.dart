import 'package:davi/davi.dart';
import 'package:davi/src/internal/new/cells_layout_child.dart';
import 'package:davi/src/internal/new/cells_layout_element.dart';
import 'package:davi/src/internal/new/cells_layout_render_box.dart';
import 'package:davi/src/internal/new/hover_notifier.dart';
import 'package:davi/src/internal/new/row_region.dart';
import 'package:davi/src/internal/scroll_offsets.dart';
import 'package:davi/src/internal/table_layout_settings.dart';
import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';
import 'package:meta/meta.dart';

@internal
class CellsLayout<DATA> extends MultiChildRenderObjectWidget {

  const CellsLayout(
      {Key? key,
        required this.layoutSettings,
        required this.verticalOffset,
        required this.horizontalScrollOffsets,
        required this.leftPinnedAreaBounds,
        required this.unpinnedAreaBounds,
        required this.hoverIndex,
           required this.rowsLength,
        required this.rowRegionCache,
      required List<CellsLayoutChild> children})
      :  super(key: key, children: children);

  final TableLayoutSettings layoutSettings;
  final double verticalOffset;
  final HorizontalScrollOffsets horizontalScrollOffsets;
  final Rect leftPinnedAreaBounds;
  final Rect unpinnedAreaBounds;
final   HoverNotifier hoverIndex;
final RowRegionCache rowRegionCache;
   final int rowsLength;

  @override
  RenderObject createRenderObject(BuildContext context) {
    DaviThemeData theme = DaviTheme.of(context);
    return CellsLayoutRenderBox<DATA>(
        hoverBackground: theme.row.hoverBackground,
    hoverForeground: theme.row.hoverForeground,
    cellHeight: layoutSettings.themeMetrics.cell.height,
        rowHeight:layoutSettings.themeMetrics.row.height,
        columnsMetrics: layoutSettings.columnsMetrics,
        verticalOffset:verticalOffset,
        horizontalScrollOffsets:horizontalScrollOffsets,
      leftPinnedAreaBounds: leftPinnedAreaBounds,
      unpinnedAreaBounds: unpinnedAreaBounds,
      hoverNotifier: hoverIndex,
      rowColor: theme.row.color,
        dividerColor: theme.row.dividerColor,
      rowsLength: rowsLength,
        rowRegionCache:rowRegionCache,
      fillHeight: theme.row.fillHeight, dividerThickness: theme.row.dividerThickness
    );
  }



  @override
  MultiChildRenderObjectElement createElement() {
    return CellsLayoutElement(this);
  }

  @override
  void updateRenderObject(
      BuildContext context, covariant CellsLayoutRenderBox renderObject) {
    super.updateRenderObject(context, renderObject);
    DaviThemeData theme = DaviTheme.of(context);
    renderObject
    ..hoverBackground=theme.row.hoverBackground
      ..hoverForeground=theme.row.hoverForeground
    ..cellHeight= layoutSettings.themeMetrics.cell.height
      ..rowHeight=layoutSettings.themeMetrics.row.height
    ..columnsMetrics=layoutSettings.columnsMetrics
    ..verticalOffset=verticalOffset
    ..horizontalScrollOffsets=horizontalScrollOffsets
    ..leftPinnedAreaBounds=leftPinnedAreaBounds
    ..unpinnedAreaBounds=unpinnedAreaBounds
    ..hoverNotifier=hoverIndex
    ..fillHeight=theme.row.fillHeight
    ..rowsLength=rowsLength
      ..rowRegionCache=rowRegionCache
    ..dividerColor= theme.row.dividerColor
      ..dividerThickness=theme.row.dividerThickness
    ..rowColor=theme.row.color;
  }
}

