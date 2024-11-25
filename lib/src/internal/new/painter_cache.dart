import 'package:davi/src/internal/new/fifo_cache.dart';
import 'package:flutter/material.dart';
import 'package:meta/meta.dart';

@internal
class PainterCache<DATA> {
  //TODO set cache max de linhas
  final FifoCache<_Key, TextPainter> _cache = FifoCache(900);

  TextPainter getTextPainter(
      {required double width,
      required TextStyle? textStyle,
      required String value,
      required int rowSpan}) {
    _Key key = _Key(
        width: width, textStyle: textStyle, value: value, rowSpan: rowSpan);
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
      required this.rowSpan});

  final double width;
  final TextStyle? textStyle;
  final String value;
  final int rowSpan;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is _Key &&
          runtimeType == other.runtimeType &&
          width == other.width &&
          textStyle == other.textStyle &&
          value == other.value &&
          rowSpan == other.rowSpan;

  @override
  int get hashCode =>
      width.hashCode ^ textStyle.hashCode ^ value.hashCode ^ rowSpan.hashCode;
}
