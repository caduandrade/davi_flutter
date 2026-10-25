import 'dart:math' as math;

import 'package:davi/src/column.dart';
import 'package:davi/src/data_source.dart';
import 'package:flutter/rendering.dart';
import 'package:flutter/scheduler.dart';
import 'package:meta/meta.dart';

/// Resolves the pending auto size of the columns (see
/// [DaviColumn.initialAutoSize] and `autoSizeColumns` on the model and
/// controller), only in [ColumnWidthBehavior.scrollable].
///
/// While a column is pending, the header and cells render boxes report the
/// intrinsic width of its header and of its visible cells during layout.
/// After the frame, the widest one (limited by
/// [DaviColumn.maxAutoSizeWidth]) becomes the column width.
///
/// An initial auto size waits until there are rows to measure. Its
/// measuring frame is not painted, so the columns don't visibly jump
/// from the configured width to the measured one.
@internal
class ColumnAutoSizer {
  DaviDataSource? _dataSource;
  bool _enabled = false;
  bool _disposed = false;

  final Map<DaviColumn, double> _headerWidths = {};
  final Map<DaviColumn, double> _cellWidths = {};
  bool _dataRowsMeasured = false;
  bool _resolveScheduled = false;

  /// Changes whenever the header and cells need a new layout to be
  /// measured, or the table needs a new paint after a resolution.
  int get generation => _generation;
  int _generation = 0;

  /// Whether some column is waiting for its initial auto size.
  bool get hasPendingInitial => _hasPendingInitial;
  bool _hasPendingInitial = false;

  /// Whether the current frame is only measuring the initial auto size and
  /// should not be painted.
  bool get hidePaint => _hidePaint;
  bool _hidePaint = false;

  /// Called on every table build.
  void update({required DaviDataSource dataSource, required bool enabled}) {
    _dataSource = dataSource;
    _enabled = enabled;
    _hasPendingInitial = false;
    bool hasPending = false;
    if (enabled) {
      for (int i = 0; i < dataSource.columnsLength; i++) {
        final DaviColumn column = dataSource.columnAt(i);
        if (DaviColumnHelper.isInitialAutoSizePending(column: column)) {
          _hasPendingInitial = true;
          hasPending = true;
        } else if (DaviColumnHelper.isAutoSizeRequested(column: column)) {
          hasPending = true;
        }
      }
    }
    if (hasPending) {
      // Forces the header and cells to be laid out (and measured) again.
      _generation++;
    }
  }

  void dispose() {
    _disposed = true;
  }

  DaviColumn? _pendingColumn(int columnIndex) {
    final DaviDataSource? dataSource = _dataSource;
    if (!_enabled ||
        dataSource == null ||
        columnIndex >= dataSource.columnsLength) {
      return null;
    }
    final DaviColumn column = dataSource.columnAt(columnIndex);
    if (DaviColumnHelper.isInitialAutoSizePending(column: column) ||
        DaviColumnHelper.isAutoSizeRequested(column: column)) {
      return column;
    }
    return null;
  }

  /// Measures the header cell of a column, if it is pending.
  void measureHeader(int columnIndex, RenderBox header) {
    final DaviColumn? column = _pendingColumn(columnIndex);
    if (column == null) {
      return;
    }
    _put(_headerWidths, column, header.getMaxIntrinsicWidth(double.infinity));
    _scheduleResolve();
  }

  /// Measures a visible cell (of a row with data) of a column, if it is
  /// pending.
  void measureCell(int columnIndex, RenderBox cell) {
    final DaviColumn? column = _pendingColumn(columnIndex);
    if (column == null) {
      return;
    }
    _dataRowsMeasured = true;
    if (DaviColumnHelper.isInitialAutoSizePending(column: column)) {
      _hidePaint = true;
    }
    // Painted cells take the column width, they have no width of their own.
    if (column.cellPainter == null && column.cellBarValue == null) {
      _put(_cellWidths, column, cell.getMaxIntrinsicWidth(double.infinity));
    }
    _scheduleResolve();
  }

  void _put(Map<DaviColumn, double> map, DaviColumn column, double width) {
    map[column] = math.max(map[column] ?? 0, width);
  }

  void _scheduleResolve() {
    if (_resolveScheduled) {
      return;
    }
    _resolveScheduled = true;
    SchedulerBinding.instance.addPostFrameCallback((_) => _resolve());
    SchedulerBinding.instance.ensureVisualUpdate();
  }

  void _resolve() {
    _resolveScheduled = false;
    final bool hadHiddenPaint = _hidePaint;
    _hidePaint = false;
    final DaviDataSource? dataSource = _dataSource;
    if (!_disposed && _enabled && dataSource != null) {
      for (int i = 0; i < dataSource.columnsLength; i++) {
        final DaviColumn column = dataSource.columnAt(i);
        final bool requested =
            DaviColumnHelper.isAutoSizeRequested(column: column);
        final bool initial =
            DaviColumnHelper.isInitialAutoSizePending(column: column);
        if (!requested && !(initial && _dataRowsMeasured)) {
          // Initial auto size keeps waiting for rows.
          continue;
        }
        double width =
            math.max(_headerWidths[column] ?? 0, _cellWidths[column] ?? 0);
        if (width <= 0) {
          // Nothing to measure: keeps the current width.
          width = column.width;
        } else if (column.maxAutoSizeWidth != null) {
          width = math.min(width, column.maxAutoSizeWidth!);
        }
        DaviColumnHelper.applyAutoSize(column: column, width: width);
      }
    }
    _headerWidths.clear();
    _cellWidths.clear();
    _dataRowsMeasured = false;
    if (hadHiddenPaint) {
      // Repaints the table even if no width has changed.
      _generation++;
    }
  }
}
