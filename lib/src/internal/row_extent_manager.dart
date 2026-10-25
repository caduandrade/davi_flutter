import 'dart:async';
import 'dart:math' as math;

import 'package:flutter/foundation.dart';

/// Tracks the height of every row so the table can scroll and size itself
/// without every row sharing a single fixed height.
///
/// Row height is normally discovered lazily, by measuring a row's real cell
/// content the same way the header row already measures its own height (see
/// `ColumnsLayoutRenderBox._measureRowHeight`). Until a row has been
/// measured - because it has never been visible yet - it's assigned a seed
/// "estimated" height (`RowThemeData.estimatedHeight`). This is the same
/// "estimate, then correct" strategy Flutter's own `ListView`/
/// `RenderSliverList` use when `itemExtent` isn't fixed: totals and
/// scrollbar sizing are approximate until the relevant rows are measured,
/// then self-correct.
///
/// Backed by a Fenwick tree (Binary Indexed Tree) so that both "pixel offset
/// of row N" and "which row is at pixel offset X" are O(log n), and a single
/// row's height can be corrected in O(log n) too - important since rows are
/// measured continuously while scrolling.
///
/// A [ChangeNotifier]: [TableScrollbar] listens to it to keep the vertical
/// scrollbar's hidden `SingleChildScrollView` sized correctly, which is what
/// feeds `ScrollPosition.maxScrollExtent` (via `applyContentDimensions`).
/// Without that, mouse-wheel/keyboard scrolling - which clamps to
/// `ScrollPosition`'s own extents rather than reading this manager directly
/// - would stay capped at a stale total height until something unrelated
/// happened to rebuild the table.
@internal
class RowExtentManager extends ChangeNotifier {
  int _rowsLength = 0;
  double _dividerThickness = 0;

  /// Seed height for rows without a real measurement yet, and for "virtual"
  /// row indices past [rowsLength] (e.g. filler rows painted to fill the
  /// viewport when there isn't enough data - see `RowThemeData.fillHeight`).
  double _estimatedHeight = 0;
  List<double> _heights = const [];

  /// Whether each row's height is a real measurement ([setHeight] was
  /// called for it) rather than still the seed estimate - lets
  /// [updateGeometry] reseed only genuinely-unmeasured rows instead of
  /// discarding every real measurement whenever, say, the divider thickness
  /// changes.
  List<bool> _measured = const [];

  /// 1-indexed Fenwick tree over each row's "extent"
  /// (`heightOf(row) + dividerThickness`).
  List<double> _tree = const [0];

  int get rowsLength => _rowsLength;

  // The manager is a single long-lived instance that gets mutated in place
  // (resize()/setHeight()) rather than replaced, for performance - RenderBox
  // setters elsewhere compare this instead of object identity to detect a
  // content change, since a same-reference reassignment would otherwise look
  // like a no-op to them and silently skip a needed relayout (stale layout
  // with fresh paint-time reads, i.e. a visibly broken frame until something
  // unrelated happens to force another layout pass).
  int _generation = 0;
  int get generation => _generation;

  /// Whether a coalesced post-frame [notifyListeners] call is already
  /// pending (see [setHeight]).
  bool _notifyScheduled = false;

  /// Rebuilds the manager for a new row count, discarding every measurement.
  ///
  /// Called whenever the row count changes, and whenever previously measured
  /// heights could no longer match the row at that index (sorting/replacing
  /// rows shuffles which data sits at which index) - re-measuring rows as
  /// they scroll back into view is cheap and keeps things correct.
  void resize(
      {required int rowsLength,
      required double estimatedHeight,
      required double dividerThickness}) {
    _rowsLength = math.max(0, rowsLength);
    _dividerThickness = dividerThickness;
    _estimatedHeight = estimatedHeight;
    _heights = List<double>.filled(_rowsLength, estimatedHeight);
    _measured = List<bool>.filled(_rowsLength, false);
    _rebuildTree();
    _generation++;
    notifyListeners();
  }

  /// Applies a new seed estimate and/or divider thickness without
  /// discarding rows that have already been measured - unlike [resize],
  /// this doesn't mean "the data underneath might be different now", just
  /// that the geometry parameters changed, so previously measured content
  /// heights are still valid; only genuinely unmeasured rows get reseeded.
  void updateGeometry(
      {required double estimatedHeight, required double dividerThickness}) {
    if (_estimatedHeight == estimatedHeight &&
        _dividerThickness == dividerThickness) {
      return;
    }
    _estimatedHeight = estimatedHeight;
    _dividerThickness = dividerThickness;
    for (int i = 0; i < _rowsLength; i++) {
      if (!_measured[i]) {
        _heights[i] = estimatedHeight;
      }
    }
    _rebuildTree();
    _generation++;
    notifyListeners();
  }

  void _rebuildTree() {
    _tree = List<double>.filled(_rowsLength + 1, 0);
    for (int i = 1; i <= _rowsLength; i++) {
      _tree[i] += _heights[i - 1] + _dividerThickness;
      final int parent = i + (i & (-i));
      if (parent <= _rowsLength) {
        _tree[parent] += _tree[i];
      }
    }
  }

  /// The row's current best-known content height: the real measured height
  /// if [setHeight] has been called for it, otherwise the seed estimate.
  ///
  /// Tolerates [rowIndex] at or past [rowsLength] (a "virtual" filler row),
  /// answering with the seed estimate.
  double heightOf(int rowIndex) =>
      rowIndex < _rowsLength ? _heights[rowIndex] : _estimatedHeight;

  /// The row's content height plus the divider painted below it.
  double extentOf(int rowIndex) => heightOf(rowIndex) + _dividerThickness;

  /// The pixel offset of the top of [rowIndex]. Tolerates [rowIndex] past
  /// [rowsLength] (see [heightOf]).
  double offsetOf(int rowIndex) {
    if (rowIndex <= _rowsLength) {
      return _prefixSum(rowIndex);
    }
    return _prefixSum(_rowsLength) +
        (rowIndex - _rowsLength) * (_estimatedHeight + _dividerThickness);
  }

  /// Total height of the first [rowCount] rows, not counting the divider
  /// that would follow the last one - this is what feeds scrollbar sizing
  /// and `visibleRowsCount` mode.
  double heightUpTo(int rowCount) {
    if (rowCount <= 0 || _rowsLength == 0) {
      return 0;
    }
    return math.max(
        0, _prefixSum(math.min(rowCount, _rowsLength)) - _dividerThickness);
  }

  /// Best-known total content height of every row (an estimate that
  /// self-corrects as more rows are measured).
  double get totalHeight => heightUpTo(_rowsLength);

  /// Records the real measured height of [rowIndex]. Marks the row as
  /// measured even if [newHeight] happens to match what's already known (the
  /// seed estimate, or a previous measurement) - otherwise a row whose real
  /// height coincidentally equals the seed would look "unmeasured" to
  /// [updateGeometry] and get incorrectly reseeded to a later, unrelated
  /// estimate change.
  void setHeight(int rowIndex, double newHeight) {
    final double delta = newHeight - _heights[rowIndex];
    _measured[rowIndex] = true;
    if (delta == 0) {
      return;
    }
    _heights[rowIndex] = newHeight;
    for (int i = rowIndex + 1; i <= _rowsLength; i += i & (-i)) {
      _tree[i] += delta;
    }
    _generation++;
    // setHeight() is called from CellsLayoutRenderBox's measure pass, i.e.
    // mid-layout: notifying listeners synchronously here would have a
    // ListenableBuilder call setState mid-frame ("Build scheduled during
    // frame"). Defer to a microtask (rather than SchedulerBinding's
    // post-frame callback, which needs a live Flutter binding and would
    // break plain, binding-free unit tests of this class) and coalesce -
    // many rows can be measured within the same layout pass, but they only
    // need one scrollbar-extent refresh.
    if (!_notifyScheduled) {
      _notifyScheduled = true;
      scheduleMicrotask(() {
        _notifyScheduled = false;
        if (!_disposed) {
          notifyListeners();
        }
      });
    }
  }

  bool _disposed = false;

  @override
  void dispose() {
    _disposed = true;
    super.dispose();
  }

  /// The row index whose vertical span contains pixel [offset].
  int indexAtOffset(double offset) {
    if (_rowsLength == 0) {
      return 0;
    }
    int index = 0;
    double remaining = math.max(0, offset);
    int highestBit = 1;
    while (highestBit * 2 <= _rowsLength) {
      highestBit *= 2;
    }
    for (int pw = highestBit; pw > 0; pw >>= 1) {
      final int next = index + pw;
      if (next <= _rowsLength && _tree[next] <= remaining) {
        index = next;
        remaining -= _tree[next];
      }
    }
    return math.min(index, _rowsLength - 1);
  }

  /// How many rows are needed to cover [availableHeight] pixels of viewport
  /// starting at [scrollOffset], including a partially-visible leading and
  /// trailing row.
  int visibleRowCount(
      {required double scrollOffset, required double availableHeight}) {
    if (availableHeight <= 0 || _rowsLength == 0) {
      return 0;
    }
    final int firstIndex = indexAtOffset(scrollOffset);
    final double firstRowRemaining =
        offsetOf(firstIndex) + extentOf(firstIndex) - scrollOffset;
    double remaining = availableHeight - firstRowRemaining;
    int count = 1;
    int index = firstIndex + 1;
    // Walk remaining real rows one at a time, since their heights vary.
    while (remaining > 0 && index < _rowsLength) {
      remaining -= extentOf(index);
      index++;
      count++;
    }
    // Past real data every row shares the same estimated extent (filler
    // rows) - jump straight to the answer instead of looping. This also
    // sidesteps an infinite loop if that extent is ever zero.
    if (remaining > 0) {
      final double virtualExtent = _estimatedHeight + _dividerThickness;
      if (virtualExtent > 0) {
        count += (remaining / virtualExtent).ceil();
      }
    }
    return count;
  }

  /// A conservative, worst-case row count for [availableHeight] pixels of
  /// viewport starting at [scrollOffset]: unlike [visibleRowCount], this
  /// ignores exactly where within the first visible row [scrollOffset]
  /// falls, always assuming the least favorable case (as if scrolled to
  /// that row's very top) plus one extra row of margin.
  ///
  /// This makes the result depend only on which row is first (a
  /// whole-row-granularity value), not on the exact scroll pixel - so it
  /// stays stable for any scroll position within the same starting row,
  /// which is what lets [ViewportState] skip its expensive cell-mapping
  /// rebuild on sub-row-height scroll deltas.
  int viewportRowCount(
      {required double scrollOffset, required double availableHeight}) {
    if (availableHeight <= 0 || _rowsLength == 0) {
      return 0;
    }
    final int firstIndex = indexAtOffset(scrollOffset);
    double remaining = availableHeight;
    int count = 0;
    int index = firstIndex;
    while (remaining > 0 && index < _rowsLength) {
      remaining -= extentOf(index);
      index++;
      count++;
    }
    if (remaining > 0) {
      final double virtualExtent = _estimatedHeight + _dividerThickness;
      if (virtualExtent > 0) {
        count += (remaining / virtualExtent).ceil();
      }
    }
    return count + 1;
  }

  double _prefixSum(int count) {
    double sum = 0;
    for (int i = count; i > 0; i -= i & (-i)) {
      sum += _tree[i];
    }
    return sum;
  }
}
