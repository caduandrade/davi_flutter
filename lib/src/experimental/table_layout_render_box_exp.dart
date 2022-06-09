import 'package:easy_table/src/experimental/content_area.dart';
import 'package:easy_table/src/experimental/content_area_id.dart';
import 'package:easy_table/src/experimental/table_callbacks.dart';
import 'package:easy_table/src/experimental/table_layout_parent_data_exp.dart';
import 'package:easy_table/src/experimental/table_layout_settings.dart';
import 'package:easy_table/src/experimental/table_paint_settings.dart';
import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';

class TableLayoutRenderBoxExp extends RenderBox
    with
        ContainerRenderObjectMixin<RenderBox, TableLayoutParentDataExp>,
        RenderBoxContainerDefaultsMixin<RenderBox, TableLayoutParentDataExp> {
  TableLayoutRenderBoxExp(
      {required TableLayoutSettings layoutSettings,
      required TablePaintSettings paintSettings,
      required TableCallbacks callbacks})
      : _layoutSettings = layoutSettings,
        _paintSettings = paintSettings,
        _callbacks = callbacks;

  late final TapGestureRecognizer _tapGestureRecognizer;
  late final HorizontalDragGestureRecognizer _horizontalDragGestureRecognizer;

  final ContentArea _leftPinnedContentArea = ContentArea(
      id: ContentAreaId.leftPinned,
      headerAreaDebugColor: Colors.yellow[300]!,
      scrollbarAreaDebugColor: Colors.yellow[200]!);
  final ContentArea _unpinnedContentArea = ContentArea(
      id: ContentAreaId.unpinned,
      headerAreaDebugColor: Colors.lime[300]!,
      scrollbarAreaDebugColor: Colors.lime[200]!);
  final ContentArea _rightPinnedContentArea = ContentArea(
      id: ContentAreaId.rightPinned,
      headerAreaDebugColor: Colors.orange[300]!,
      scrollbarAreaDebugColor: Colors.orange[200]!);

  TableLayoutSettings _layoutSettings;
  set layoutSettings(TableLayoutSettings value) {
    if (_layoutSettings != value) {
      _layoutSettings = value;
      markNeedsLayout();
    }
  }

  TablePaintSettings _paintSettings;
  set paintSettings(TablePaintSettings value) {
    if (_paintSettings != value) {
      _paintSettings = value;
      markNeedsPaint();
    }
  }

  TableCallbacks? _callbacks;
  set callbacks(TableCallbacks? value) {
    if (_callbacks != value) {
      _callbacks = value;
      _setCallbacksOnGestureRecognizers();
    }
  }

  @override
  void attach(PipelineOwner owner) {
    _tapGestureRecognizer = TapGestureRecognizer(debugOwner: this);
    _horizontalDragGestureRecognizer =
        HorizontalDragGestureRecognizer(debugOwner: this);
    _setCallbacksOnGestureRecognizers();
    super.attach(owner);
  }

  void _setCallbacksOnGestureRecognizers() {
    _tapGestureRecognizer.onTap = _callbacks?.onTap;
    _horizontalDragGestureRecognizer.onStart = _callbacks?.onDragStart;
    _horizontalDragGestureRecognizer.onUpdate = _callbacks?.onDragUpdate;
    _horizontalDragGestureRecognizer.onEnd = _callbacks?.onDragEnd;
  }

  @override
  void detach() {
    _tapGestureRecognizer.dispose();
    _horizontalDragGestureRecognizer.dispose();
    super.detach();
  }

  @override
  void setupParentData(RenderBox child) {
    if (child.parentData is! TableLayoutParentDataExp) {
      child.parentData = TableLayoutParentDataExp();
    }
  }

  @override
  void performLayout() {
    if (!constraints.hasBoundedHeight &&
        _layoutSettings.visibleRowsCount == null) {
      throw FlutterError.fromParts(<DiagnosticsNode>[
        ErrorSummary('EasyTable was given unbounded height.'),
        ErrorDescription(
            'EasyTable already is scrollable in the vertical axis.'),
        ErrorHint(
          'Consider using the "visibleRowsCount" property to limit the height'
          ' or use it in another Widget like Expanded or SliverFillRemaining.',
        ),
      ]);
    }
    if (!constraints.hasBoundedWidth) {
      throw FlutterError('EasyTable was given unbounded width.');
    }

    List<RenderBox> children = [];
    visitChildren((child) => children.add(child as RenderBox));

    _leftPinnedContentArea.bounds =
        Rect.fromLTWH(0, 0, 100, constraints.maxHeight);
    _unpinnedContentArea.bounds =
        Rect.fromLTWH(150, 0, 100, constraints.maxHeight);
    _rightPinnedContentArea.bounds =
        Rect.fromLTWH(400, 0, 100, constraints.maxHeight);

    if (constraints.hasBoundedHeight) {
      size = Size(constraints.maxWidth, constraints.maxHeight);
    } else {
      // unbounded height
      size = Size(constraints.maxWidth, constraints.maxHeight);
    }
  }

  @override
  double computeMinIntrinsicHeight(double width) {
    double height = 0;
    if (_layoutSettings.hasHeader) {
      height += _layoutSettings.headerHeight;
    }
    return height;
  }

  @override
  double computeMaxIntrinsicHeight(double width) {
    double height = computeMinIntrinsicHeight(width);
    if (_layoutSettings.visibleRowsCount != null) {
      height += _layoutSettings.visibleRowsCount! * _layoutSettings.rowHeight;
    }
    return height;
  }

  @override
  bool hitTest(BoxHitTestResult result, {required Offset position}) {
    //TODO check area
    result.add(BoxHitTestEntry(this, position));
    return true;
  }

  @override
  bool hitTestChildren(BoxHitTestResult result, {required Offset position}) {
    //TODO check area
    return defaultHitTestChildren(result, position: position);
  }

  @override
  void handleEvent(PointerEvent event, BoxHitTestEntry entry) {
    assert(debugHandleEvent(event, entry));
    if (event is PointerDownEvent) {
      _tapGestureRecognizer.addPointer(event);
      _horizontalDragGestureRecognizer.addPointer(event);
    }
  }

  @override
  void paint(PaintingContext context, Offset offset) {
    defaultPaint(context, offset);
    if (_paintSettings.debugAreas) {
      if (_layoutSettings.hasHeader) {
        _forEachContentArea((area) => area.paintDebugAreas(
            canvas: context.canvas,
            offset: offset,
            layoutSettings: _layoutSettings));
      }
    }
  }

  void _forEachContentArea(_ContentAreaFunction function) {
    function(_leftPinnedContentArea);
    function(_unpinnedContentArea);
    function(_rightPinnedContentArea);
  }
}

typedef _ContentAreaFunction = void Function(ContentArea area);

/// Utility extension to facilitate obtaining parent data.
extension _TableLayoutParentDataGetter on RenderObject {
  TableLayoutParentDataExp _parentData() {
    return parentData as TableLayoutParentDataExp;
  }
}
