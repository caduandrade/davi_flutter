import 'package:davi/src/internal/fifo_cache.dart';
import 'package:flutter/material.dart';
import 'package:meta/meta.dart';

@internal
class PainterCache<DATA> {
  final FifoCache<_Key, TextPainter> _cache = FifoCache();

  set size(int size) {
    _cache.maxSize = size;
  }

  TextPainter getTextPainter(
      {required double width,
      required TextStyle? textStyle,
      required String value,
      required int rowSpan,
      required int columnSpan}) {
    _Key key = _Key(
        width: width,
        textStyle: textStyle,
        value: value,
        rowSpan: rowSpan,
        columnSpan: columnSpan);
    TextPainter? painter = _cache.get(key);
    if (painter == null) {
      painter = TextPainter(
        maxLines: 1,
        ellipsis: '\u2026',
        text: TextSpan(text: value, style: textStyle),
        textDirection: TextDirection.ltr,
      );
      painter.layout(maxWidth: width);
      _cache.put(key, painter);
    }
    return painter;
  }
}

class _Key {
  _Key(
      {required this.width,
      required this.textStyle,
      required this.value,
      required this.rowSpan,
      required this.columnSpan});

  final double width;
  final TextStyle? textStyle;
  final String value;
  final int rowSpan;
  final int columnSpan;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is _Key &&
          runtimeType == other.runtimeType &&
          width == other.width &&
          textStyle == other.textStyle &&
          value == other.value &&
          rowSpan == other.rowSpan &&
          columnSpan == other.columnSpan;

  @override
  int get hashCode =>
      width.hashCode ^
      textStyle.hashCode ^
      value.hashCode ^
      rowSpan.hashCode ^
      columnSpan.hashCode;
}
