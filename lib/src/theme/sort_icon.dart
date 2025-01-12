import 'package:davi/davi.dart';
import 'package:davi/src/sort_direction.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';

enum SortIconSize { size12, size14, size16Tall, size16Short, size19 }

class SortIcon extends LeafRenderObjectWidget {
  const SortIcon(
      {super.key,
      required this.color,
      required this.direction,
      required this.size,
      this.inverted = false,
      this.debug = false});

  final Color color;
  final DaviSortDirection direction;
  final bool inverted;
  final SortIconSize size;
  final bool debug;

  @override
  RenderSortIcon createRenderObject(BuildContext context) {
    if (size == SortIconSize.size12) {
      return _RenderSize12(
          direction: direction, debug: debug, color: color, inverted: inverted);
    } else if (size == SortIconSize.size14) {
      return _RenderSize14(
          direction: direction, debug: debug, color: color, inverted: inverted);
    } else if (size == SortIconSize.size16Short) {
      return _RenderSize16Short(
          direction: direction, debug: debug, color: color, inverted: inverted);
    } else if (size == SortIconSize.size16Tall) {
      return _RenderSize16Tall(
          direction: direction, debug: debug, color: color, inverted: inverted);
    } else if (size == SortIconSize.size19) {
      return _RenderSize19(
          direction: direction, debug: debug, color: color, inverted: inverted);
    }
    throw StateError('Unrecognized size: $size');
  }

  @override
  void updateRenderObject(BuildContext context, RenderSortIcon renderObject) {
    renderObject
      ..color = color
      ..direction = direction
      ..inverted = inverted
      ..debug = debug;
  }

  @override
  void debugFillProperties(DiagnosticPropertiesBuilder properties) {
    super.debugFillProperties(properties);
    properties.add(ColorProperty('color', color));
    properties.add(EnumProperty('direction', direction));
    properties.add(EnumProperty('size', size));
    properties.add(StringProperty('inverted', inverted.toString()));
    properties.add(StringProperty('debug', debug.toString()));
  }
}

abstract class RenderSortIcon extends RenderBox {
  RenderSortIcon(
      {required Color color,
      required DaviSortDirection direction,
      required bool inverted,
      required bool debug})
      : _color = color,
        _direction = direction,
        _inverted = inverted,
        _debug = debug;

  double get iconSize;

  bool _inverted;

  set inverted(bool value) {
    if (_inverted != value) {
      _inverted = value;
      markNeedsPaint();
    }
  }

  Color _color;

  set color(Color value) {
    if (_color != value) {
      _color = value;
      markNeedsPaint();
    }
  }

  DaviSortDirection _direction;

  set direction(DaviSortDirection value) {
    if (_direction != value) {
      _direction = value;
      markNeedsPaint();
    }
  }

  bool _debug;

  set debug(bool value) {
    if (_debug != value) {
      _debug = value;
      markNeedsPaint();
    }
  }

  @override
  void performLayout() {
    size = computeDryLayout(constraints);
  }

  @override
  Size computeDryLayout(BoxConstraints constraints) {
    final desiredSize = Size(iconSize, iconSize);
    return constraints.constrain(desiredSize);
  }

  @override
  double computeMinIntrinsicWidth(double height) => iconSize;

  @override
  double computeMaxIntrinsicWidth(double height) => iconSize;

  @override
  double computeMinIntrinsicHeight(double width) => iconSize;

  @override
  double computeMaxIntrinsicHeight(double width) => iconSize;

  Paint get _paint => Paint()
    ..color = _color
    ..style = PaintingStyle.fill;

  void paintSmallerTopBiggerBottom(Canvas canvas);

  void paintBiggerTopSmallerBottom(Canvas canvas);

  @override
  void paint(PaintingContext context, Offset offset) {
    final canvas = context.canvas;
    canvas.save();

    canvas.translate(offset.dx, offset.dy);

    if (_debug) {
      canvas.drawRect(
          Rect.fromLTWH(0, 0, size.width, size.height),
          Paint()
            ..color = Colors.blue[200]!
            ..style = PaintingStyle.fill);
    }

    if (_inverted) {
      if (_direction == DaviSortDirection.ascending) {
        paintBiggerTopSmallerBottom(canvas);
      } else {
        paintSmallerTopBiggerBottom(canvas);
      }
    } else {
      if (_direction == DaviSortDirection.ascending) {
        paintSmallerTopBiggerBottom(canvas);
      } else {
        paintBiggerTopSmallerBottom(canvas);
      }
    }

    canvas.restore();
  }
}

class _RenderSize12 extends RenderSortIcon {
  _RenderSize12(
      {required super.color,
      required super.direction,
      required super.inverted,
      required super.debug});

  @override
  double get iconSize => 12;

  @override
  void paintSmallerTopBiggerBottom(Canvas canvas) {
    canvas.drawRect(const Rect.fromLTWH(7, 1, 3, 2), _paint);
    canvas.drawRect(const Rect.fromLTWH(4, 5, 6, 2), _paint);
    canvas.drawRect(const Rect.fromLTWH(2, 9, 8, 2), _paint);
  }

  @override
  void paintBiggerTopSmallerBottom(Canvas canvas) {
    canvas.drawRect(const Rect.fromLTWH(2, 1, 8, 2), _paint);
    canvas.drawRect(const Rect.fromLTWH(4, 5, 6, 2), _paint);
    canvas.drawRect(const Rect.fromLTWH(7, 9, 3, 2), _paint);
  }
}

class _RenderSize14 extends RenderSortIcon {
  _RenderSize14(
      {required super.color,
      required super.direction,
      required super.inverted,
      required super.debug});

  @override
  double get iconSize => 14;

  @override
  void paintSmallerTopBiggerBottom(Canvas canvas) {
    canvas.drawRect(const Rect.fromLTWH(8, 2, 4, 2), _paint);
    canvas.drawRect(const Rect.fromLTWH(5, 6, 7, 2), _paint);
    canvas.drawRect(const Rect.fromLTWH(2, 10, 10, 2), _paint);
  }

  @override
  void paintBiggerTopSmallerBottom(Canvas canvas) {
    canvas.drawRect(const Rect.fromLTWH(2, 2, 10, 2), _paint);
    canvas.drawRect(const Rect.fromLTWH(5, 6, 7, 2), _paint);
    canvas.drawRect(const Rect.fromLTWH(8, 10, 4, 2), _paint);
  }
}

class _RenderSize16Tall extends RenderSortIcon {
  _RenderSize16Tall(
      {required super.color,
      required super.direction,
      required super.inverted,
      required super.debug});

  @override
  double get iconSize => 16;

  @override
  void paintSmallerTopBiggerBottom(Canvas canvas) {
    canvas.drawRect(const Rect.fromLTWH(10, 2, 4, 2), _paint);
    canvas.drawRect(const Rect.fromLTWH(6, 7, 8, 2), _paint);
    canvas.drawRect(const Rect.fromLTWH(2, 12, 12, 2), _paint);
  }

  @override
  void paintBiggerTopSmallerBottom(Canvas canvas) {
    canvas.drawRect(const Rect.fromLTWH(2, 2, 12, 2), _paint);
    canvas.drawRect(const Rect.fromLTWH(6, 7, 8, 2), _paint);
    canvas.drawRect(const Rect.fromLTWH(10, 12, 4, 2), _paint);
  }
}

class _RenderSize16Short extends RenderSortIcon {
  _RenderSize16Short(
      {required super.color,
      required super.direction,
      required super.inverted,
      required super.debug});

  @override
  double get iconSize => 16;

  @override
  void paintSmallerTopBiggerBottom(Canvas canvas) {
    canvas.drawRect(const Rect.fromLTWH(10, 3, 4, 2), _paint);
    canvas.drawRect(const Rect.fromLTWH(6, 7, 8, 2), _paint);
    canvas.drawRect(const Rect.fromLTWH(2, 11, 12, 2), _paint);
  }

  @override
  void paintBiggerTopSmallerBottom(Canvas canvas) {
    canvas.drawRect(const Rect.fromLTWH(2, 3, 12, 2), _paint);
    canvas.drawRect(const Rect.fromLTWH(6, 7, 8, 2), _paint);
    canvas.drawRect(const Rect.fromLTWH(10, 11, 4, 2), _paint);
  }
}

class _RenderSize19 extends RenderSortIcon {
  _RenderSize19(
      {required super.color,
      required super.direction,
      required super.inverted,
      required super.debug});

  @override
  double get iconSize => 19;

  @override
  void paintSmallerTopBiggerBottom(Canvas canvas) {
    canvas.drawRect(const Rect.fromLTWH(12, 2, 5, 3), _paint);
    canvas.drawRect(const Rect.fromLTWH(7, 8, 10, 3), _paint);
    canvas.drawRect(const Rect.fromLTWH(2, 14, 15, 3), _paint);
  }

  @override
  void paintBiggerTopSmallerBottom(Canvas canvas) {
    canvas.drawRect(const Rect.fromLTWH(2, 2, 15, 3), _paint);
    canvas.drawRect(const Rect.fromLTWH(7, 8, 10, 3), _paint);
    canvas.drawRect(const Rect.fromLTWH(12, 14, 5, 3), _paint);
  }
}
