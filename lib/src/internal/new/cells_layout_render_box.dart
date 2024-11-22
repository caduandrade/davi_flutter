import 'package:davi/src/internal/new/hover_notifier.dart';
import 'package:davi/src/internal/new/row_region.dart';
import 'package:davi/src/theme/theme_row_color.dart';
import 'package:flutter/foundation.dart';
import 'package:davi/src/internal/column_metrics.dart';
import 'package:davi/src/internal/new/cells_layout_parent_data.dart';
import 'package:davi/src/internal/scroll_offsets.dart';
import 'package:davi/src/pin_status.dart';

import 'package:flutter/rendering.dart';
import 'package:flutter/services.dart';
import 'package:meta/meta.dart';

@internal
class CellsLayoutRenderBox<DATA> extends RenderBox
    with
        ContainerRenderObjectMixin<RenderBox, CellsLayoutParentData>,
        RenderBoxContainerDefaultsMixin<RenderBox, CellsLayoutParentData>
    implements MouseTrackerAnnotation {
  CellsLayoutRenderBox(
      {required double cellHeight,
      required double rowHeight,
      required double verticalOffset,
      required HorizontalScrollOffsets horizontalScrollOffsets,
      required List<ColumnMetrics> columnsMetrics,
      required Rect leftPinnedAreaBounds,
      required Rect unpinnedAreaBounds,
      required HoverNotifier hoverNotifier,
      required ThemeRowColor? rowColor,
      required int rowsLength,
      required bool fillHeight,
      required bool columnDividerFillHeight,
      required double dividerThickness,
      required RowRegionCache rowRegionCache,
      required ThemeRowColor? hoverBackground,
      required ThemeRowColor? hoverForeground,
      required double columnDividerThickness,
      required Color? columnDividerColor,
      required Color? dividerColor})
      : _cellHeight = cellHeight,
        _rowHeight = rowHeight,
        _verticalOffset = verticalOffset,
        _horizontalScrollOffsets = horizontalScrollOffsets,
        _hoverNotifier = hoverNotifier,
        _fillHeight = fillHeight,
        _columnDividerFillHeight = columnDividerFillHeight,
        _rowColor = rowColor,
        _rowsLength = rowsLength,
        _dividerThickness = dividerThickness,
        _rowRegionCache = rowRegionCache,
        _hoverBackground = hoverBackground,
        _hoverForeground = hoverForeground,
        _dividerColor = dividerColor,
        _columnDividerColor = columnDividerColor,
        _columnDividerThickness = columnDividerThickness,
        _columnsMetrics = columnsMetrics {
    _areaBounds[PinStatus.left] = leftPinnedAreaBounds;
    _areaBounds[PinStatus.none] = unpinnedAreaBounds;
    _hoverNotifier.addListener(markNeedsPaint);
  }

  List<ColumnMetrics> _columnsMetrics;

  set columnsMetrics(List<ColumnMetrics> list) {
    if (listEquals(_columnsMetrics, list) == false) {
      _columnsMetrics = list;
      markNeedsLayout();
    }
  }

  final Map<PinStatus, Rect> _areaBounds = {
    PinStatus.left: Rect.zero,
    PinStatus.none: Rect.zero
  };

  set leftPinnedAreaBounds(Rect areaBounds) {
    if (_areaBounds[PinStatus.left] != areaBounds) {
      _areaBounds[PinStatus.left] = areaBounds;
      markNeedsPaint();
    }
  }

  set unpinnedAreaBounds(Rect areaBounds) {
    if (_areaBounds[PinStatus.none] != areaBounds) {
      _areaBounds[PinStatus.none] = areaBounds;
      markNeedsPaint();
    }
  }

  double _dividerThickness;

  set dividerThickness(double value) {
    if (_dividerThickness != value) {
      _dividerThickness = value;
      markNeedsLayout();
    }
  }

  Color? _dividerColor;

  set dividerColor(Color? value) {
    if (_dividerColor != value) {
      _dividerColor = value;
      markNeedsPaint();
    }
  }

  ThemeRowColor? _hoverBackground;

  set hoverBackground(ThemeRowColor? value) {
    if (_hoverBackground != value) {
      _hoverBackground = value;
      markNeedsPaint();
    }
  }

  ThemeRowColor? _hoverForeground;

  set hoverForeground(ThemeRowColor? value) {
    if (_hoverForeground != value) {
      _hoverForeground = value;
      markNeedsPaint();
    }
  }

  double _rowHeight;

  set rowHeight(double value) {
    if (_rowHeight != value) {
      _rowHeight = value;
      markNeedsLayout();
    }
  }

  double _cellHeight;

  set cellHeight(double value) {
    if (_cellHeight != value) {
      _cellHeight = value;
      markNeedsLayout();
    }
  }

  HorizontalScrollOffsets _horizontalScrollOffsets;

  set horizontalScrollOffsets(HorizontalScrollOffsets value) {
    if (_horizontalScrollOffsets != value) {
      _horizontalScrollOffsets = value;
      markNeedsPaint();
    }
  }

  double _verticalOffset;

  set verticalOffset(double value) {
    if (_verticalOffset != value) {
      _verticalOffset = value;
      markNeedsPaint();
    }
  }

  HoverNotifier _hoverNotifier;

  set hoverNotifier(HoverNotifier value) {
    if (_hoverNotifier != value) {
      _hoverNotifier.removeListener(markNeedsPaint);
      _hoverNotifier = value;
      _hoverNotifier.addListener(markNeedsPaint);
    }
  }

  ThemeRowColor? _rowColor;

  set rowColor(ThemeRowColor? value) {
    if (_rowColor != value) {
      _rowColor = value;
      markNeedsPaint();
    }
  }

  bool _columnDividerFillHeight;

  set columnDividerFillHeight(bool value) {
    if (_columnDividerFillHeight != value) {
      _columnDividerFillHeight = value;
      markNeedsPaint();
    }
  }

  bool _fillHeight;

  set fillHeight(bool value) {
    if (_fillHeight != value) {
      _fillHeight = value;
      markNeedsPaint();
    }
  }

  int _rowsLength;

  set rowsLength(int value) {
    if (_rowsLength != value) {
      _rowsLength = value;
      markNeedsPaint();
    }
  }

  RowRegionCache _rowRegionCache;

  set rowRegionCache(RowRegionCache value) {
    if (_rowRegionCache != value) {
      _rowRegionCache = value;
      markNeedsPaint();
    }
  }

  double _columnDividerThickness;

  set columnDividerThickness(double value) {
    if (_columnDividerThickness != value) {
      _columnDividerThickness = value;
      markNeedsPaint();
    }
  }

  Color? _columnDividerColor;

  set columnDividerColor(Color? value) {
    if (_columnDividerColor != value) {
      _columnDividerColor = value;
      markNeedsPaint();
    }
  }

  final List<RenderBox> _cells = [];
  RenderBox? _trailing;

  @override
  void markNeedsLayout() {
    //TODO remove
    // print('markNeedsLayout ${DateTime.now()} - ${_rowRegionCache.values.length}');
    super.markNeedsLayout();
  }

  @override
  void setupParentData(RenderBox child) {
    if (child.parentData is! CellsLayoutParentData) {
      child.parentData = CellsLayoutParentData();
    }
  }

  @override
  Size computeDryLayout(BoxConstraints constraints) {
    return Size(constraints.maxWidth, constraints.maxHeight);
  }

  @override
  void performLayout() {
    _cells.clear();
    _trailing = null;
    visitChildren((child) {
      final RenderBox renderBox = child as RenderBox;
      final CellsLayoutParentData childParentData = child._parentData();
      final int? columnIndex = childParentData.columnIndex;
      if (columnIndex != null && columnIndex >= 0) {
        // cell
        final ColumnMetrics columnMetrics = _columnsMetrics[columnIndex];
        renderBox.layout(
            BoxConstraints.tightFor(
                width: columnMetrics.width, height: _cellHeight),
            parentUsesSize: true);
        _cells.add(renderBox);
      } else {
        // trailing
        renderBox.layout(
            BoxConstraints.tightFor(
                width: constraints.maxWidth, height: _cellHeight),
            parentUsesSize: true);
        _trailing = renderBox;
      }
      renderBox._parentData().offset = const Offset(0, 0);
    });

    size = computeDryLayout(constraints);
  }

  @override
  void paint(PaintingContext context, Offset offset) {
    if (constraints.maxWidth == 0 || constraints.maxHeight == 0) {
      return;
    }

    Paint paint = Paint()..style = PaintingStyle.fill;
    //TODO old check to allow paint hover
/*

columnResizing:  model != null && columnNotifier.resizing

        !widget.columnResizing &&
        (widget.rowCallbacks.hasCallback ||
            theme.row.hoverBackground != null ||
            theme.row.hoverForeground != null ||
            widget.onHover != null ||
            !theme.row.cursorOnTapGesturesOnly
  */

    // backgrounds
    if (_rowColor != null || _hoverBackground != null) {
      for (RowRegion rowRegion in _rowRegionCache.values) {
        if (rowRegion.trailing) {
          continue;
        }
        if (!rowRegion.hasData && !_fillHeight) {
          continue;
        }
        Color? color;
        if (_rowColor != null) {
          color = _rowColor!(rowRegion.index);
        }
        if (_hoverBackground != null &&
            _hoverNotifier.index == rowRegion.index) {
          color = _hoverBackground!(rowRegion.index) ?? color;
        }
        if (color != null) {
          paint.color = color;
          context.canvas.drawRect(
              rowRegion.bounds.translate(offset.dx, offset.dy), paint);
        }
      }
    }

    // cells
    for (RenderBox child in _cells) {
      final CellsLayoutParentData childParentData = child._parentData();
      final int rowIndex = childParentData.rowIndex!;
      final int columnIndex = childParentData.columnIndex!;
      // cell
      final ColumnMetrics columnMetrics = _columnsMetrics[columnIndex];
      final PinStatus pinStatus = columnMetrics.pinStatus;
      final double horizontalOffset =
          _horizontalScrollOffsets.getOffset(pinStatus);

      context.canvas.save();
      final Rect bounds = _areaBounds[pinStatus]!;
      context.canvas.clipRect(bounds.translate(offset.dx, offset.dy));

      double top = (rowIndex * _rowHeight) - _verticalOffset;

      context.paintChild(child,
          offset.translate(columnMetrics.offset - horizontalOffset, top));
      context.canvas.restore();
    }

    // trailing
    if (_trailing != null && _rowRegionCache.trailingRegion != null) {
      context.paintChild(
          _trailing!, offset.translate(0, _rowRegionCache.trailingRegion!.y));
    }

    // foreground
    if (_hoverForeground != null) {
      for (RowRegion rowRegion in _rowRegionCache.values) {
        if (!rowRegion.hasData) {
          continue;
        }
        if (_hoverNotifier.index == rowRegion.index) {
          Color? color = _hoverForeground!(rowRegion.index);
          if (color != null) {
            paint.color = color;
            context.canvas.drawRect(
                rowRegion.bounds.translate(offset.dx, offset.dy), paint);
          }
        }
      }
    }

    // row divider
    if (_dividerColor != null) {
      paint.color = _dividerColor!;
      for (RowRegion rowRegion in _rowRegionCache.values) {
        if (_fillHeight || rowRegion.hasData || rowRegion.trailing) {
          context.canvas.drawRect(
              Rect.fromLTWH(offset.dx, offset.dy + rowRegion.y + _cellHeight,
                  constraints.maxWidth, _dividerThickness),
              paint);
        }
      }
    }

    // column divider
    if (_columnDividerThickness > 0 && _columnDividerColor != null) {
      paint.color = _columnDividerColor!;

      double height = 0;
      if (_trailing != null && _rowRegionCache.trailingRegion != null) {
        height = _rowRegionCache.trailingRegion!.y;
      } else if (_columnDividerFillHeight) {
        height = constraints.maxHeight;
      } else {
        height = _rowRegionCache.lastWithData!.y + _rowHeight;
      }

      _paintColumns(
          context: context, paint: paint, offset: offset, y: 0, height: height);

      if (_trailing != null &&
          _rowRegionCache.trailingRegion != null &&
          _columnDividerFillHeight) {
        final double y = _rowRegionCache.trailingRegion!.y + _rowHeight;
        height = constraints.maxHeight - y;
        if (height > 0) {
          _paintColumns(
              context: context,
              paint: paint,
              offset: offset,
              y: y,
              height: height);
        }
      }
    }
  }

  void _paintColumns(
      {required PaintingContext context,
      required Paint paint,
      required Offset offset,
      required double y,
      required double height}) {
    for (ColumnMetrics columnMetrics in _columnsMetrics) {
      double scroll = 0;
      if (columnMetrics.pinStatus == PinStatus.none) {
        scroll = _horizontalScrollOffsets.unpinned;
        context.canvas.save();
        context.canvas.clipRect(
            _areaBounds[PinStatus.none]!.translate(offset.dx, offset.dy));
      } else {
        scroll = _horizontalScrollOffsets.leftPinned;
      }
      context.canvas.drawRect(
          Rect.fromLTWH(
              offset.dx + columnMetrics.offset + columnMetrics.width - scroll,
              offset.dy + y,
              _columnDividerThickness,
              height),
          paint);
      if (columnMetrics.pinStatus == PinStatus.none) {
        context.canvas.restore();
      }
    }
  }

  bool isMouseMovementEvent(PointerEvent event) {
    return event is PointerHoverEvent ||
        event is PointerEnterEvent ||
        event is PointerExitEvent;
  }

  @override
  MouseCursor get cursor {
    return _hoverNotifier.cursor;
  }

  @override
  PointerEnterEventListener? get onEnter => null;

  @override
  PointerExitEventListener? get onExit => null;

  @override
  bool get validForMouseTracker => true;

  @override
  bool hitTestChildren(BoxHitTestResult result, {required Offset position}) {
    final int firstRowIndex = (_verticalOffset / _rowHeight).floor();

    if (_trailing != null) {
//TODO trailing hit
    }

    for (RenderBox child in _cells) {
      final CellsLayoutParentData childParentData = child._parentData();
      final int rowIndex = childParentData.rowIndex!;
      final int columnIndex = childParentData.columnIndex!;

      final ColumnMetrics columnMetrics = _columnsMetrics[columnIndex];
      final PinStatus pinStatus = columnMetrics.pinStatus;

      final double horizontalOffset =
          _horizontalScrollOffsets.getOffset(pinStatus);

      final int visualRowIndex = rowIndex - firstRowIndex;

      // Calculates the offset where the cell is rendered.
      final Offset renderedCellOffset = Offset(
          columnMetrics.offset - horizontalOffset, visualRowIndex * _rowHeight);

      // Calculates the rendering area of the cell.
      final Rect renderedCellBounds =
          renderedCellOffset & Size(columnMetrics.width, _cellHeight);

      // Check if the hit position is within the cell rendering area.
      if (renderedCellBounds.contains(position)) {
        // Adjusts the offset to the position relative to the hit within the cell.
        final Offset localOffset = position - renderedCellOffset;
        if (child.hitTest(result, position: localOffset)) {
          return true;
        }
      }
    }
    return _hoverNotifier.index != null;
  }

  @override
  void dispose() {
    _hoverNotifier.removeListener(markNeedsPaint);
    super.dispose();
  }
}

/// Utility extension to facilitate obtaining parent data.
extension _ParentDataGetter on RenderObject {
  CellsLayoutParentData _parentData() {
    return parentData as CellsLayoutParentData;
  }
}
