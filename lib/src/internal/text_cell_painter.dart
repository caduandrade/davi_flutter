import 'package:davi/src/internal/painter_cache.dart';
import 'package:flutter/widgets.dart';
import 'package:meta/meta.dart';

@internal
class TextCellPainter extends LeafRenderObjectWidget {
  const TextCellPainter(
      {super.key,
      required this.text,
      required this.painterCache,
      required this.textStyle,
      this.overflow});

  final PainterCache painterCache;
  final String text;
  final TextStyle? textStyle;
  final TextOverflow? overflow;

  @override
  RenderObject createRenderObject(BuildContext context) {
    return CellPainterRenderBox(
        text: text,
        renderCache: painterCache,
        textStyle: textStyle,
        overflow: overflow);
  }

  @override
  void updateRenderObject(
      BuildContext context, CellPainterRenderBox renderObject) {
    renderObject
      ..text = text
      ..painterCache = painterCache
      ..textStyle = textStyle
      ..overflow = overflow;
  }
}

@internal
class CellPainterRenderBox extends RenderBox {
  CellPainterRenderBox(
      {required String text,
      required PainterCache renderCache,
      required TextStyle? textStyle,
      TextOverflow? overflow})
      : _text = text,
        _painterCache = renderCache,
        _textStyle = textStyle,
        _overflow = overflow;

  PainterCache _painterCache;

  set painterCache(PainterCache value) {
    _painterCache = value;
  }

  TextStyle? _textStyle;

  set textStyle(TextStyle? value) {
    if (_textStyle != value) {
      _textStyle = value;
      markNeedsLayout();
    }
  }

  TextOverflow? _overflow;

  set overflow(TextOverflow? value) {
    if (_overflow != value) {
      _overflow = value;
      markNeedsLayout();
    }
  }

  String _text;

  set text(String value) {
    if (_text != value) {
      _text = value;
      markNeedsLayout();
    }
  }

  late TextPainter _textPainter;

  @override
  void performLayout() {
    _textPainter = _painterCache.getTextPainter(
        width: constraints.maxWidth,
        textStyle: _textStyle,
        value: _text,
        overflow: _overflow);
    size = Size(_textPainter.width, _textPainter.height);
  }

  // The default RenderBox intrinsics are 0, which would report a text cell
  // as having no content height at all - measure it the same way
  // performLayout does, so a row sizes correctly around its text cells.
  @override
  double computeMinIntrinsicHeight(double width) => _measureHeight(width);

  @override
  double computeMaxIntrinsicHeight(double width) => _measureHeight(width);

  double _measureHeight(double width) {
    return _painterCache
        .getTextPainter(
            width: width,
            textStyle: _textStyle,
            value: _text,
            overflow: _overflow)
        .height;
  }

  @override
  void paint(PaintingContext context, Offset offset) {
    _textPainter.paint(context.canvas, offset);
  }
}
