import 'package:davi/src/internal/new/painter_cache.dart';
import 'package:flutter/widgets.dart';
import 'package:meta/meta.dart';

@internal
class CellPainter extends LeafRenderObjectWidget {
  const CellPainter(
      {Key? key,
      required this.text,
      required this.painterCache,
      required this.textStyle})
      : super(key: key);

  final PainterCache painterCache;
  final String text;
  final TextStyle? textStyle;

  @override
  RenderObject createRenderObject(BuildContext context) {
    return CellPainterRenderBox(
        text: text, renderCache: painterCache, textStyle: textStyle);
  }

  @override
  void updateRenderObject(
      BuildContext context, CellPainterRenderBox renderObject) {
    renderObject
      ..text = text
      ..painterCache = painterCache
      ..textStyle = textStyle;
  }
}

@internal
class CellPainterRenderBox extends RenderBox {
  CellPainterRenderBox(
      {required String text,
      required PainterCache renderCache,
      required TextStyle? textStyle})
      : _text = text,
        _painterCache = renderCache,
        _textStyle = textStyle;

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
        rowSpan: 1);
    size = Size(_textPainter.width, _textPainter.height);
  }

  @override
  void paint(PaintingContext context, Offset offset) {
    _textPainter.paint(context.canvas, offset);
  }
}
