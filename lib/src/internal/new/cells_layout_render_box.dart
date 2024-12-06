import 'dart:math' as math;
import 'package:davi/davi.dart';
import 'package:davi/src/internal/new/divider_paint_manager.dart';
import 'package:davi/src/internal/new/hover_notifier.dart';
import 'package:davi/src/internal/new/row_region.dart';
import 'package:davi/src/internal/column_metrics.dart';
import 'package:davi/src/internal/new/cells_layout_parent_data.dart';
import 'package:davi/src/internal/scroll_offsets.dart';
import 'package:flutter/foundation.dart';
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
      required ThemeRowColor? themeRowColor,
      required int rowsLength,
      required bool fillHeight,
      required bool columnDividerFillHeight,
      required double dividerThickness,
      required RowRegionCache rowRegionCache,
      required ThemeRowColor? hoverBackground,
      required ThemeRowColor? hoverForeground,
      required double columnDividerThickness,
      required Color? columnDividerColor,
      required Color? dividerColor,
      required DaviRowColor<DATA>? rowColor,
      required DividerPaintManager dividerPaintManager,
      required DaviModel<DATA> model})
      : _model = model,
        _cellHeight = cellHeight,
        _rowHeight = rowHeight,
        _verticalOffset = verticalOffset,
        _horizontalScrollOffsets = horizontalScrollOffsets,
        _hoverNotifier = hoverNotifier,
        _fillHeight = fillHeight,
        _columnDividerFillHeight = columnDividerFillHeight,
        _themeRowColor = themeRowColor,
        _rowColor = rowColor,
        _rowsLength = rowsLength,
        _dividerThickness = dividerThickness,
        _dividerPaintManager = dividerPaintManager,
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

  DaviModel<DATA> _model;

  set model(DaviModel<DATA> value) {
    if (_model != value) {
      _model = value;
      markNeedsPaint();
    }
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

  DaviRowColor<DATA>? _rowColor;

  set rowColor(DaviRowColor<DATA>? value) {
    if (_rowColor != value) {
      _rowColor = value;
      markNeedsPaint();
    }
  }

  ThemeRowColor? _themeRowColor;

  set themeRowColor(ThemeRowColor? value) {
    if (_themeRowColor != value) {
      _themeRowColor = value;
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

  bool _hasLayoutErrors = false;

  DividerPaintManager _dividerPaintManager;
  set dividerPaintManager(DividerPaintManager value) {
    _dividerPaintManager = value;
  }

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
    size = computeDryLayout(constraints);
    _hasLayoutErrors = false;
    _cells.clear();
    _trailing = null;
    visitChildren((child) {
      final RenderBox renderBox = child as RenderBox;
      final CellsLayoutParentData childParentData = child._parentData();

      if (childParentData.isCell) {
        // cell
        final int rowIndex = childParentData.rowIndex!;
        final RowRegion rowRegion = _rowRegionCache.get(rowIndex);
        final int columnIndex = childParentData.columnIndex!;
        final int rowSpan = childParentData.rowSpan!;
        final int columnSpan = childParentData.columnSpan!;

        if (columnIndex + columnSpan > _columnsMetrics.length) {
          _hasLayoutErrors = true;
          throw StateError(
              'The column span exceeds the table\'s column limit at row $rowIndex, starting from column $columnIndex.');
        } else if (rowRegion.hasData &&
            rowIndex + rowSpan > _model.rowsLength) {
          _hasLayoutErrors = true;
          throw StateError(
              'The row span exceeds the table\'s row limit at row $rowIndex and column $columnIndex.');
        }

        double width = 0;
        for (int i = columnIndex; i < columnIndex + columnSpan; i++) {
          final ColumnMetrics columnMetrics = _columnsMetrics[i];
          width += columnMetrics.width;
          if (i < columnIndex + columnSpan - 1) {
            width += _columnDividerThickness;
          }
        }

        double height = 0;
        for (int i = rowIndex; i < rowIndex + rowSpan; i++) {
          height += _cellHeight;
          if (i < rowIndex + rowSpan - 1) {
            height += _dividerThickness;
          }
        }

        renderBox.layout(BoxConstraints.tightFor(width: width, height: height),
            parentUsesSize: false);
        _cells.add(renderBox);
      } else {
        // trailing
        renderBox.layout(
            BoxConstraints.tightFor(
                width: constraints.maxWidth, height: _cellHeight),
            parentUsesSize: false);
        _trailing = renderBox;
      }
      renderBox._parentData().offset = const Offset(0, 0);
    });
  }

  @override
  void paint(PaintingContext context, Offset offset) {
    if (_hasLayoutErrors ||
        constraints.maxWidth == 0 ||
        constraints.maxHeight == 0) {
      return;
    }

    Paint paint = Paint()..style = PaintingStyle.fill;
    // backgrounds
    if (_themeRowColor != null ||
        _hoverBackground != null ||
        _rowColor != null) {
      for (RowRegion rowRegion in _rowRegionCache.values) {
        if (!rowRegion.visible) {
          continue;
        }
        if (rowRegion.trailing) {
          continue;
        }
        if (!rowRegion.hasData && !_fillHeight) {
          continue;
        }
        Color? color;
        if (_hoverBackground != null &&
            _hoverNotifier.index == rowRegion.index) {
          color = _hoverBackground!(rowRegion.index) ?? color;
        }
        if (rowRegion.hasData && color == null && _rowColor != null) {
          final DATA data = _model.rowAt(rowRegion.index);
          color = _rowColor!(
              data, rowRegion.index, _hoverNotifier.index == rowRegion.index);
        }
        if (color == null && _themeRowColor != null) {
          color = _themeRowColor!(rowRegion.index);
        }
        if (color != null) {
          paint.color = color;
          context.canvas.drawRect(
              rowRegion.bounds.translate(offset.dx, offset.dy), paint);
        }
      }
    }

    // cell widgets
    for (RenderBox child in _cells) {
      final CellsLayoutParentData childParentData = child._parentData();
      final int rowIndex = childParentData.rowIndex!;
      final int columnIndex = childParentData.columnIndex!;
      final int rowSpan = childParentData.rowSpan!;
      final int columnSpan = childParentData.columnSpan!;

      _dividerPaintManager.addStopsForCell(
          rowIndex: rowIndex,
          columnIndex: columnIndex,
          rowSpan: rowSpan,
          columnSpan: columnSpan);

      final ColumnMetrics columnMetrics = _columnsMetrics[columnIndex];
      final PinStatus pinStatus = columnMetrics.pinStatus;
      final double horizontalOffset =
          _horizontalScrollOffsets.getOffset(pinStatus);

      context.canvas.save();
      final Rect bounds = _areaBounds[pinStatus]!;
      context.canvas.clipRect(bounds.translate(offset.dx, offset.dy));

      final double top = (rowIndex * _rowHeight) - _verticalOffset;
      final Offset childOffset =
          offset.translate(columnMetrics.offset - horizontalOffset, top);

      context.paintChild(child, childOffset);
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
        if (!rowRegion.visible) {
          continue;
        }
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

    // column dividers
    if (_columnDividerThickness > 0 && _columnDividerColor != null) {
      paint.color = _columnDividerColor!;
      for (int columnIndex = 0;
          columnIndex < _columnsMetrics.length;
          columnIndex++) {
        final ColumnMetrics columnMetrics = _columnsMetrics[columnIndex];
        double scroll = 0;
        if (columnMetrics.pinStatus == PinStatus.none) {
          scroll = _horizontalScrollOffsets.unpinned;
          context.canvas.save();
          context.canvas.clipRect(
              _areaBounds[PinStatus.none]!.translate(offset.dx, offset.dy));
        } else {
          scroll = _horizontalScrollOffsets.leftPinned;
        }

        double left =
            offset.dx + columnMetrics.offset + columnMetrics.width - scroll;

        double right = left + _columnDividerThickness;
        for (DividerSegment dividerSegment
            in _dividerPaintManager.verticalSegments(column: columnIndex)) {
          final DividerVertex start = dividerSegment.start;
          final DividerVertex end = dividerSegment.end;
          double top = offset.dy;
          double bottom = offset.dy;
          if (!start.edge) {
            RowRegion startRow = _rowRegionCache.get(start.index);
            top += startRow.y + _cellHeight;
          }
          if (end.edge) {
            bottom += constraints.maxHeight;
          } else {
            RowRegion endRow = _rowRegionCache.get(end.index);
            bottom += endRow.y + _cellHeight;
          }
          context.canvas
              .drawRect(Rect.fromLTRB(left, top, right, bottom), paint);
        }

        if (columnMetrics.pinStatus == PinStatus.none) {
          context.canvas.restore();
        }
      }
    }

    // row dividers
    if (_dividerColor != null) {
      paint.color = _dividerColor!;
      for (RowRegion rowRegion in _rowRegionCache.values) {
        if (!rowRegion.visible) {
          continue;
        }
        for (DividerSegment dividerSegment
            in _dividerPaintManager.horizontalSegments(row: rowRegion.index)) {
          final DividerVertex start = dividerSegment.start;
          ColumnMetrics? startColumn;
          final DividerVertex end = dividerSegment.end;
          double left = offset.dx;
          if (!start.edge) {
            startColumn = _columnsMetrics[start.index];
            double scrollOffset =
                _horizontalScrollOffsets.getOffset(startColumn.pinStatus);
            left += startColumn.offset +
                startColumn.width +
                _columnDividerThickness -
                scrollOffset;
            if (startColumn.pinStatus == PinStatus.none) {
              left = math.max(
                  left,
                  offset.dx +
                      _areaBounds[PinStatus.left]!.right +
                      _columnDividerThickness);
            }
          }
          double right = offset.dx;
          if (end.edge) {
            right += constraints.maxWidth;
          } else {
            ColumnMetrics endColumn = _columnsMetrics[end.index];
            double scrollOffset =
                _horizontalScrollOffsets.getOffset(endColumn.pinStatus);
            right += endColumn.offset +
                endColumn.width +
                _columnDividerThickness -
                scrollOffset;
            bool hasPinLeft = (startColumn != null &&
                    startColumn.pinStatus == PinStatus.left) ||
                (startColumn == null && _areaBounds[PinStatus.left]!.width > 0);
            if (hasPinLeft && endColumn.pinStatus == PinStatus.none) {
              right = math.max(
                  right, offset.dx + _areaBounds[PinStatus.left]!.right);
            }
          }
          double top = offset.dy + rowRegion.y + _cellHeight;
          context.canvas.drawRect(
              Rect.fromLTRB(left, top, right, top + _dividerThickness), paint);
        }
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

    if (_trailing != null && _rowRegionCache.trailingRegion != null) {
      final Offset renderedTrailingOffset =
          Offset(0, _rowRegionCache.trailingRegion!.y);
      // Adjusts the offset to the position relative to the hit within the trailing.
      final Offset localOffset = position - renderedTrailingOffset;
      if (_trailing!.hitTest(result, position: localOffset)) {
        return true;
      }
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
