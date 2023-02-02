import 'package:davi/davi.dart';
import 'package:davi/src/sort_direction.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';

enum SortIconSize { size12, size14, size16Tall, size16Short, size19 }

class SortIcon extends LeafRenderObjectWidget {
  const SortIcon(
      {Key? key,
      required this.color,
      required this.direction,
      required this.size,
      this.debug = false})
      : super(key: key);

  final Color color;
  final DaviSortDirection direction;
  final SortIconSize size;
  final bool debug;

  @override
  RenderSortIcon createRenderObject(BuildContext context) {
    if (size == SortIconSize.size12) {
      return RenderSize12(direction: direction, debug: debug, color: color);
    } else if (size == SortIconSize.size14) {
      return RenderSize14(direction: direction, debug: debug, color: color);
    } else if (size == SortIconSize.size16Short) {
      return RenderSize16Short(
          direction: direction, debug: debug, color: color);
    } else if (size == SortIconSize.size16Tall) {
      return RenderSize16Tall(direction: direction, debug: debug, color: color);
    } else if (size == SortIconSize.size19) {
      return RenderSize19(direction: direction, debug: debug, color: color);
    }
    throw StateError('Unrecognized size: $size');
  }

  @override
  void updateRenderObject(BuildContext context, RenderSortIcon renderObject) {
    renderObject
      ..color = color
      ..direction = direction
      ..debug = debug;
  }

  @override
  void debugFillProperties(DiagnosticPropertiesBuilder properties) {
    super.debugFillProperties(properties);
    properties.add(ColorProperty('color', color));
    properties.add(EnumProperty('direction', direction));
    properties.add(EnumProperty('size', size));
    properties.add(StringProperty('debug', debug.toString()));
  }
}

abstract class RenderSortIcon extends RenderBox {
  RenderSortIcon(
      {required Color color,
      required DaviSortDirection direction,
      required bool debug})
      : _color = color,
        _direction = direction,
        _debug = debug;

  double get iconSize;

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

  void paintIcon(Canvas canvas);

  @override
  void paint(PaintingContext context, Offset offset) {
    final canvas = context.canvas;
    canvas.save();

    canvas.translate(offset.dx.roundToDouble(), offset.dy.roundToDouble());

    if (_debug) {
      canvas.drawRect(
          Rect.fromLTRB(0, 0, size.width, size.height),
          Paint()
            ..color = Colors.blue[200]!
            ..style = PaintingStyle.fill);
    }

    paintIcon(canvas);

    canvas.restore();
  }
}

class RenderSize12 extends RenderSortIcon {
  RenderSize12(
      {required Color color,
      required DaviSortDirection direction,
      required bool debug})
      : super(color: color, direction: direction, debug: debug);

  @override
  double get iconSize => 12;

  @override
  void paintIcon(Canvas canvas) {
    if (_direction == DaviSortDirection.ascending) {
      canvas.drawRect(const Rect.fromLTWH(7, 1, 3, 2), _paint);
      canvas.drawRect(const Rect.fromLTWH(4, 5, 6, 2), _paint);
      canvas.drawRect(const Rect.fromLTWH(2, 9, 8, 2), _paint);
    } else {
      canvas.drawRect(const Rect.fromLTWH(2, 1, 8, 2), _paint);
      canvas.drawRect(const Rect.fromLTWH(4, 5, 6, 2), _paint);
      canvas.drawRect(const Rect.fromLTWH(7, 9, 3, 2), _paint);
    }
  }
}

class RenderSize14 extends RenderSortIcon {
  RenderSize14(
      {required Color color,
      required DaviSortDirection direction,
      required bool debug})
      : super(color: color, direction: direction, debug: debug);

  @override
  double get iconSize => 14;

  @override
  void paintIcon(Canvas canvas) {
    if (_direction == DaviSortDirection.ascending) {
      canvas.drawRect(const Rect.fromLTWH(8, 2, 4, 2), _paint);
      canvas.drawRect(const Rect.fromLTWH(5, 6, 7, 2), _paint);
      canvas.drawRect(const Rect.fromLTWH(2, 10, 10, 2), _paint);
    } else {
      canvas.drawRect(const Rect.fromLTWH(2, 2, 10, 2), _paint);
      canvas.drawRect(const Rect.fromLTWH(5, 6, 7, 2), _paint);
      canvas.drawRect(const Rect.fromLTWH(8, 10, 4, 2), _paint);
    }
  }
}

class RenderSize16Tall extends RenderSortIcon {
  RenderSize16Tall(
      {required Color color,
      required DaviSortDirection direction,
      required bool debug})
      : super(color: color, direction: direction, debug: debug);

  @override
  double get iconSize => 16;

  @override
  void paintIcon(Canvas canvas) {
    if (_direction == DaviSortDirection.ascending) {
      canvas.drawRect(const Rect.fromLTWH(10, 2, 4, 2), _paint);
      canvas.drawRect(const Rect.fromLTWH(6, 7, 8, 2), _paint);
      canvas.drawRect(const Rect.fromLTWH(2, 12, 12, 2), _paint);
    } else {
      canvas.drawRect(const Rect.fromLTWH(2, 2, 12, 2), _paint);
      canvas.drawRect(const Rect.fromLTWH(6, 7, 8, 2), _paint);
      canvas.drawRect(const Rect.fromLTWH(10, 12, 4, 2), _paint);
    }
  }
}

class RenderSize16Short extends RenderSortIcon {
  RenderSize16Short(
      {required Color color,
      required DaviSortDirection direction,
      required bool debug})
      : super(color: color, direction: direction, debug: debug);

  @override
  double get iconSize => 16;

  @override
  void paintIcon(Canvas canvas) {
    if (_direction == DaviSortDirection.ascending) {
      canvas.drawRect(const Rect.fromLTWH(10, 3, 4, 2), _paint);
      canvas.drawRect(const Rect.fromLTWH(6, 7, 8, 2), _paint);
      canvas.drawRect(const Rect.fromLTWH(2, 11, 12, 2), _paint);
    } else {
      canvas.drawRect(const Rect.fromLTWH(2, 3, 12, 2), _paint);
      canvas.drawRect(const Rect.fromLTWH(6, 7, 8, 2), _paint);
      canvas.drawRect(const Rect.fromLTWH(10, 11, 4, 2), _paint);
    }
  }
}

class RenderSize19 extends RenderSortIcon {
  RenderSize19(
      {required Color color,
      required DaviSortDirection direction,
      required bool debug})
      : super(color: color, direction: direction, debug: debug);

  @override
  double get iconSize => 19;

  @override
  void paintIcon(Canvas canvas) {
    if (_direction == DaviSortDirection.ascending) {
      canvas.drawRect(const Rect.fromLTWH(12, 2, 5, 3), _paint);
      canvas.drawRect(const Rect.fromLTWH(7, 8, 10, 3), _paint);
      canvas.drawRect(const Rect.fromLTWH(2, 14, 15, 3), _paint);
    } else {
      canvas.drawRect(const Rect.fromLTWH(2, 2, 15, 3), _paint);
      canvas.drawRect(const Rect.fromLTWH(7, 8, 10, 3), _paint);
      canvas.drawRect(const Rect.fromLTWH(12, 14, 5, 3), _paint);
    }
  }
}
