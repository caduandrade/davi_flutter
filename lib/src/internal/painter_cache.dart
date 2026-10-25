import 'package:davi/src/internal/fifo_cache.dart';
import 'package:flutter/material.dart';
import 'package:meta/meta.dart';

@internal
class PainterCache<DATA> {
  final FifoCache<_Key, TextPainter> _cache = FifoCache();

  set size(int size) {
    _cache.maxSize = size;
  }

  /// [overflow] null (the default) lets the text wrap onto as many lines as
  /// it needs - the row then grows to fit, since row height is dynamic.
  /// A non-null value keeps the text on a single line, truncated to [width]
  /// (with an ellipsis for [TextOverflow.ellipsis]) - the pre-dynamic-height
  /// behavior, opt-in via `DaviColumn.cellOverflow`.
  TextPainter getTextPainter(
      {required double width,
      required TextStyle? textStyle,
      required String value,
      TextOverflow? overflow}) {
    _Key key = _Key(
        width: width, textStyle: textStyle, value: value, overflow: overflow);
    TextPainter? painter = _cache.get(key);
    if (painter == null) {
      painter = TextPainter(
        maxLines: overflow != null ? 1 : null,
        ellipsis: overflow == TextOverflow.ellipsis ? '\u2026' : null,
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
      required this.overflow});

  final double width;
  final TextStyle? textStyle;
  final String value;
  final TextOverflow? overflow;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is _Key &&
          runtimeType == other.runtimeType &&
          width == other.width &&
          textStyle == other.textStyle &&
          value == other.value &&
          overflow == other.overflow;

  @override
  int get hashCode =>
      width.hashCode ^ textStyle.hashCode ^ value.hashCode ^ overflow.hashCode;
}
