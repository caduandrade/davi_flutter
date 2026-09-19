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
      required String value}) {
    _Key key = _Key(width: width, textStyle: textStyle, value: value);
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
  _Key({required this.width, required this.textStyle, required this.value});

  final double width;
  final TextStyle? textStyle;
  final String value;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is _Key &&
          runtimeType == other.runtimeType &&
          width == other.width &&
          textStyle == other.textStyle &&
          value == other.value;

  @override
  int get hashCode => width.hashCode ^ textStyle.hashCode ^ value.hashCode;
}
