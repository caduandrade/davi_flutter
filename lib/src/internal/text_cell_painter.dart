import 'package:davi/src/internal/painter_cache.dart';
import 'package:flutter/widgets.dart';
import 'package:meta/meta.dart';

@internal
class TextCellPainter extends LeafRenderObjectWidget {
  const TextCellPainter(
      {super.key,
      required this.text,
      required this.rowSpan,
      required this.columnSpan,
      required this.painterCache,
      required this.textStyle});

  final PainterCache painterCache;
  final String text;
  final int rowSpan;
  final int columnSpan;
  final TextStyle? textStyle;

  @override
  RenderObject createRenderObject(BuildContext context) {
    return CellPainterRenderBox(
        text: text,
        rowSpan: rowSpan,
        columnSpan: columnSpan,
        renderCache: painterCache,
        textStyle: textStyle);
  }

  @override
  void updateRenderObject(
      BuildContext context, CellPainterRenderBox renderObject) {
    renderObject
      ..text = text
      ..rowSpan = rowSpan
      ..columnSpan = columnSpan
      ..painterCache = painterCache
      ..textStyle = textStyle;
  }
}

@internal
class CellPainterRenderBox extends RenderBox {
  CellPainterRenderBox(
      {required String text,
      required int rowSpan,
      required int columnSpan,
      required PainterCache renderCache,
      required TextStyle? textStyle})
      : _text = text,
        _rowSpan = rowSpan,
        _columnSpan = columnSpan,
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

  int _rowSpan;

  set rowSpan(int value) {
    if (_rowSpan != value) {
      _rowSpan = value;
      markNeedsLayout();
    }
  }

  int _columnSpan;

  set columnSpan(int value) {
    if (_columnSpan != value) {
      _columnSpan = value;
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
        rowSpan: _rowSpan,
        columnSpan: _columnSpan);
    size = Size(_textPainter.width, _textPainter.height);
  }

  @override
  void paint(PaintingContext context, Offset offset) {
    _textPainter.paint(context.canvas, offset);
  }
}
