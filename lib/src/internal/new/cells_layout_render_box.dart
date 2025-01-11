import 'dart:math' as math;
import 'package:davi/davi.dart';
import 'package:davi/src/internal/new/divider_paint_manager.dart';
import 'package:davi/src/internal/new/hover_notifier.dart';
import 'package:davi/src/internal/column_metrics.dart';
import 'package:davi/src/internal/new/cells_layout_parent_data.dart';
import 'package:davi/src/internal/new/viewport_state.dart';
import 'package:davi/src/internal/scroll_controllers.dart';
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
      required ScrollControllers scrollControllers,
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
        _scrollControllers = scrollControllers,
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
    _scrollControllers.leftPinnedHorizontal.addListener(markNeedsPaint);
    _scrollControllers.unpinnedHorizontal.addListener(markNeedsPaint);
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

  ScrollControllers _scrollControllers;

  set scrollControllers(ScrollControllers value) {
    if (_scrollControllers != value) {
      _scrollControllers.leftPinnedHorizontal.removeListener(markNeedsPaint);
      _scrollControllers.unpinnedHorizontal.removeListener(markNeedsPaint);
      _scrollControllers = value;
      _scrollControllers.leftPinnedHorizontal.addListener(markNeedsPaint);
      _scrollControllers.unpinnedHorizontal.addListener(markNeedsPaint);
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
      childParentData.offset = const Offset(0, 0);
      if (childParentData.isCell) {
        renderBox.layout(
            BoxConstraints.tightFor(width: size.width, height: size.height),
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
          color = _rowColor!(RowColorParams(
              data: data,
              rowIndex: rowRegion.index,
              hovered: _hoverNotifier.index == rowRegion.index));
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
      context.paintChild(child, offset);
    }

    // trailing
    if (_trailing != null && _rowRegionCache.trailingRegion != null) {
      context.paintChild(_trailing!,
          offset.translate(0, _rowRegionCache.trailingRegion!.bounds.top));
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
        double scroll = _scrollControllers.getOffset(columnMetrics.pinStatus);
        if (columnMetrics.pinStatus == PinStatus.none) {
          context.canvas.save();
          context.canvas.clipRect(
              _areaBounds[PinStatus.none]!.translate(offset.dx, offset.dy));
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
            top += startRow.bounds.top + _cellHeight;
          }
          if (end.edge) {
            bottom += constraints.maxHeight;
          } else {
            RowRegion endRow = _rowRegionCache.get(end.index);
            bottom += endRow.bounds.top + _cellHeight;
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
                _scrollControllers.getOffset(startColumn.pinStatus);
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
                _scrollControllers.getOffset(endColumn.pinStatus);
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
          double top = offset.dy + rowRegion.bounds.top + _cellHeight;
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
    if (_trailing != null && _rowRegionCache.trailingRegion != null) {
      final Offset renderedTrailingOffset =
          Offset(0, _rowRegionCache.trailingRegion!.bounds.top);
      // Adjusts the offset to the position relative to the hit within the trailing.
      final Offset localOffset = position - renderedTrailingOffset;
      if (_trailing!.hitTest(result, position: localOffset)) {
        return true;
      }
    }

    for (RenderBox child in _cells) {
      if (child.hitTest(result, position: position)) {
        return true;
      }
    }
    return _hoverNotifier.index != null;
  }

  @override
  void dispose() {
    _scrollControllers.leftPinnedHorizontal.removeListener(markNeedsPaint);
    _scrollControllers.unpinnedHorizontal.removeListener(markNeedsPaint);
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
