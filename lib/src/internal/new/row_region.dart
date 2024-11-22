import 'dart:collection';
import 'dart:math' as math;

import 'package:flutter/material.dart';

class RowRegion implements Comparable<RowRegion> {
  RowRegion(
      {required this.index,
      required this.bounds,
      required this.hasData,
      required this.y,
      required this.trailing});

  final int index;
  final double y;
  final Rect bounds;
  final bool hasData;
  final bool trailing;

  @override
  int compareTo(RowRegion other) => index.compareTo(other.index);
}

class RowRegionCache {
  final List<RowRegion> _cache = [];

  late final Iterable<RowRegion> values = UnmodifiableListView(_cache);

  int? _firstIndex;

  int? get firstIndex => _firstIndex;
  int? _lastIndex;

  int? get lastIndex => _lastIndex;

  RowRegion? get lastWithData {
    for (RowRegion rowRegion in _cache.reversed) {
      if (rowRegion.hasData) {
        return rowRegion;
      }
    }
    return null;
  }

  RowRegion? _trailingRegion;

  RowRegion? get trailingRegion => _trailingRegion;

  void add(RowRegion region) {
    if (region.trailing) {
      if (_trailingRegion != null) {
        throw StateError('Already exits trailing region.');
      }
      _trailingRegion = region;
    }
    _firstIndex = _firstIndex != null
        ? math.min(_firstIndex!, region.index)
        : region.index;
    _lastIndex =
        _lastIndex != null ? math.max(_lastIndex!, region.index) : region.index;
    _cache.add(region);
  }

  void sort() {
    _cache.sort();
  }

  int? boundsIndex(Offset position) {
    for (RowRegion rowBounds in _cache) {
      if (rowBounds.bounds.contains(position)) {
        return rowBounds.index;
      }
    }
    return null;
  }
}
