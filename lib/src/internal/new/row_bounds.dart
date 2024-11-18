import 'package:flutter/material.dart';

class RowBounds {

  RowBounds({required this.index, required this.bounds});
  
  final int index;
  final Rect bounds;
  
}

class RowBoundsCache {
  
  final Map<int, RowBounds> _cache = {};

  RowBounds get(int index){
    RowBounds? bounds = _cache[index];
    if(bounds==null) {
      throw StateError('Area bounds not found for index $index.');
    }
    return bounds;
  }

  void add(RowBounds bounds) {
    _cache[bounds.index] = bounds;
  }

  int? boundsIndex(Offset position) {
    for(RowBounds rowBounds in _cache.values) {
      if(rowBounds.bounds.contains(position)) {
        return rowBounds.index;
      }
    }
    return null;
  }
}