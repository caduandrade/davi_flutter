import 'package:davi/src/internal/column_metrics.dart';
import 'package:davi/src/internal/rows_layout_parent_data.dart';
import 'package:davi/src/internal/rows_painting_settings.dart';
import 'package:davi/src/internal/scroll_offsets.dart';
import 'package:davi/src/internal/table_layout_settings.dart';
import 'package:davi/src/pin_status.dart';
import 'package:davi/src/theme/theme_data.dart';
import 'package:flutter/rendering.dart';
import 'package:meta/meta.dart';

@internal
class RowsLayoutRenderBox extends RenderBox
    with
        ContainerRenderObjectMixin<RenderBox, RowsLayoutParentData>,
        RenderBoxContainerDefaultsMixin<RenderBox, RowsLayoutParentData> {
  RowsLayoutRenderBox(
      {required TableLayoutSettings layoutSettings,
      required RowsPaintingSettings paintSettings,
      required EasyTableThemeData theme,
      required double verticalOffset,
      required HorizontalScrollOffsets horizontalScrollOffsets})
      : _layoutSettings = layoutSettings,
        _paintSettings = paintSettings,
        _theme = theme,
        _verticalOffset = verticalOffset,
        _horizontalScrollOffsets = horizontalScrollOffsets;

  double _verticalOffset;

  set verticalOffset(double value) {
    if (_verticalOffset != value) {
      _verticalOffset = value;
      markNeedsLayout();
    }
  }

  HorizontalScrollOffsets _horizontalScrollOffsets;

  set horizontalScrollOffsets(HorizontalScrollOffsets value) {
    if (_horizontalScrollOffsets != value) {
      _horizontalScrollOffsets = value;
      markNeedsLayout();
    }
  }

  TableLayoutSettings _layoutSettings;

  set layoutSettings(TableLayoutSettings value) {
    if (_layoutSettings != value) {
      _layoutSettings = value;
      markNeedsLayout();
    }
  }

  EasyTableThemeData _theme;

  set theme(EasyTableThemeData value) {
    if (_theme != value) {
      _theme = value;
      markNeedsPaint();
    }
  }

  RowsPaintingSettings _paintSettings;

  set paintSettings(RowsPaintingSettings value) {
    if (_paintSettings != value) {
      _paintSettings = value;
      markNeedsPaint();
    }
  }

  @override
  void setupParentData(RenderBox child) {
    if (child.parentData is! RowsLayoutParentData) {
      child.parentData = RowsLayoutParentData();
    }
  }

  @override
  Size computeDryLayout(BoxConstraints constraints) {
    return Size(constraints.maxWidth, constraints.maxHeight);
  }

  @override
  void performLayout() {
    final double rowHeight = _layoutSettings.themeMetrics.row.height;

    visitChildren((child) {
      final RenderBox renderBox = child as RenderBox;
      final RowsLayoutParentData parentData = child._parentData();
      final int rowIndex = parentData.index!;

      renderBox.layout(
          BoxConstraints.tightFor(
              width: constraints.maxWidth,
              height: _layoutSettings.themeMetrics.cell.height),
          parentUsesSize: true);

      final double y = (rowIndex * rowHeight) - _verticalOffset;

      renderBox._parentData().offset = Offset(0, y);
    });

    size = getDryLayout(constraints);
  }

  @override
  void paint(PaintingContext context, Offset offset) {
    // backgrounds
    if (_paintSettings.rowColor != null) {
      int last = _paintSettings.firstRowIndex;
      if (_paintSettings.fillHeight) {
        last += _paintSettings.maxVisibleRowsLength;
      } else {
        last += _paintSettings.visibleRowsLength;
      }
      for (int rowIndex = _paintSettings.firstRowIndex;
          rowIndex < last;
          rowIndex++) {
        Color? color = _paintSettings.rowColor!(rowIndex);
        if (color != null) {
          Paint paint = Paint()..color = color;
          double top = (rowIndex * _layoutSettings.themeMetrics.row.height) -
              _verticalOffset +
              offset.dy;
          context.canvas.drawRect(
              Rect.fromLTWH(offset.dx, top, _layoutSettings.cellsBounds.width,
                  _layoutSettings.themeMetrics.cell.height),
              paint);
        }
      }
    }
    defaultPaint(context, offset);
    // row dividers
    if (_layoutSettings.themeMetrics.row.dividerThickness > 0 &&
        _paintSettings.divisorColor != null) {
      Paint paint = Paint()..color = _paintSettings.divisorColor!;
      int last = _paintSettings.firstRowIndex;
      if (_paintSettings.fillHeight) {
        last += _paintSettings.maxVisibleRowsLength;
      } else {
        last += _paintSettings.visibleRowsLength;
        if (!_paintSettings.lastRowDividerVisible) {
          last--;
        }
      }
      for (int rowIndex = _paintSettings.firstRowIndex;
          rowIndex < last;
          rowIndex++) {
        double top = (rowIndex * _layoutSettings.themeMetrics.row.height) -
            _verticalOffset +
            _layoutSettings.themeMetrics.cell.height +
            offset.dy;
        context.canvas.drawRect(
            Rect.fromLTWH(offset.dx, top, _layoutSettings.cellsBounds.width,
                _layoutSettings.themeMetrics.row.dividerThickness),
            paint);
      }
    }

    // column dividers
    if (_theme.columnDividerThickness > 0 &&
        (_theme.columnDividerColor != null)) {
      _MetricsForLastRowWidget? metricsForLastRowWidget;
      if (_layoutSettings.hasLastRowWidget) {
        final int rowIndex = _layoutSettings.rowsLength - 1;
        if (rowIndex >= _paintSettings.firstRowIndex &&
            rowIndex <
                _paintSettings.firstRowIndex +
                    _paintSettings.visibleRowsLength) {
          final double top1 = offset.dy;
          final double lastRowWidgetTop =
              (rowIndex * _layoutSettings.themeMetrics.row.height) -
                  _verticalOffset +
                  offset.dy;
          final height1 = lastRowWidgetTop - top1;
          final top2 =
              lastRowWidgetTop + _layoutSettings.themeMetrics.cell.height;
          final height2 = _layoutSettings.cellsBounds.height -
              lastRowWidgetTop -
              _layoutSettings.themeMetrics.cell.height +
              offset.dy;
          metricsForLastRowWidget = _MetricsForLastRowWidget(
              top1: top1, height1: height1, top2: top2, height2: height2);
        }
      }
      Paint? columnPaint;
      if (_theme.columnDividerColor != null) {
        columnPaint = Paint()..color = _theme.columnDividerColor!;
      }

      bool needAreaDivisor = false;
      for (int columnIndex = 0;
          columnIndex < _layoutSettings.columnsMetrics.length;
          columnIndex++) {
        final ColumnMetrics columnMetrics =
            _layoutSettings.columnsMetrics[columnIndex];
        final PinStatus pinStatus = columnMetrics.pinStatus;
        final Rect areaBounds = _layoutSettings.getAreaBounds(pinStatus);
        final double scrollOffset =
            _horizontalScrollOffsets.getOffset(pinStatus);
        double left = offset.dx +
            columnMetrics.offset +
            columnMetrics.width -
            scrollOffset;
        context.canvas.save();
        context.canvas.clipRect(areaBounds.translate(offset.dx, offset.dy));
        if (columnPaint != null) {
          if (metricsForLastRowWidget != null) {
            context.canvas.drawRect(
                Rect.fromLTWH(
                    left,
                    metricsForLastRowWidget.top1,
                    _layoutSettings.themeMetrics.columnDividerThickness,
                    metricsForLastRowWidget.height1),
                columnPaint);
            if (_theme.columnDividerFillHeight) {
              context.canvas.drawRect(
                  Rect.fromLTWH(
                      left,
                      metricsForLastRowWidget.top2,
                      _layoutSettings.themeMetrics.columnDividerThickness,
                      metricsForLastRowWidget.height2),
                  columnPaint);
            }
          } else {
            if (_theme.columnDividerFillHeight) {
              context.canvas.drawRect(
                  Rect.fromLTWH(
                      left,
                      offset.dy,
                      _layoutSettings.themeMetrics.columnDividerThickness,
                      _layoutSettings.cellsBounds.height),
                  columnPaint);
            } else {
              context.canvas.drawRect(
                  Rect.fromLTWH(
                      left,
                      offset.dy,
                      _layoutSettings.themeMetrics.columnDividerThickness,
                      _paintSettings.visibleRowsLength *
                          _layoutSettings.themeMetrics.row.height),
                  columnPaint);
            }
          }
        }
        context.canvas.restore();
        if (pinStatus == PinStatus.left) {
          needAreaDivisor = true;
        } else if (needAreaDivisor && pinStatus == PinStatus.none) {
          needAreaDivisor = false;
          context.canvas.save();
          context.canvas.clipRect(Rect.fromLTWH(offset.dx, offset.dy,
              _layoutSettings.cellsBounds.width, _layoutSettings.height));
          left = offset.dx +
              columnMetrics.offset -
              _layoutSettings.themeMetrics.columnDividerThickness;
          if (columnPaint != null) {
            if (metricsForLastRowWidget != null) {
              context.canvas.drawRect(
                  Rect.fromLTWH(
                      left,
                      metricsForLastRowWidget.top1,
                      _layoutSettings.themeMetrics.columnDividerThickness,
                      metricsForLastRowWidget.height1),
                  columnPaint);
              if (_theme.columnDividerFillHeight) {
                context.canvas.drawRect(
                    Rect.fromLTWH(
                        left,
                        metricsForLastRowWidget.top2,
                        _layoutSettings.themeMetrics.columnDividerThickness,
                        metricsForLastRowWidget.height2),
                    columnPaint);
              }
            } else {
              if (_theme.columnDividerFillHeight) {
                context.canvas.drawRect(
                    Rect.fromLTWH(
                        left,
                        offset.dy,
                        _layoutSettings.themeMetrics.columnDividerThickness,
                        _layoutSettings.cellsBounds.height),
                    columnPaint);
              } else {
                context.canvas.drawRect(
                    Rect.fromLTWH(
                        left,
                        offset.dy,
                        _layoutSettings.themeMetrics.columnDividerThickness,
                        _paintSettings.visibleRowsLength *
                            _layoutSettings.themeMetrics.row.height),
                    columnPaint);
              }
            }
          }
          context.canvas.restore();
        }
      }
    }
  }

  @override
  bool hitTestChildren(BoxHitTestResult result, {required Offset position}) {
    return defaultHitTestChildren(result, position: position);
  }
}

/// Utility extension to facilitate obtaining parent data.
extension _ParentDataGetter on RenderObject {
  RowsLayoutParentData _parentData() {
    return parentData as RowsLayoutParentData;
  }
}

/// Cells metrics when last row widget is visible
class _MetricsForLastRowWidget {
  _MetricsForLastRowWidget(
      {required this.top1,
      required this.height1,
      required this.top2,
      required this.height2});

  final double top1;
  final double height1;
  final double top2;
  final double height2;
}
