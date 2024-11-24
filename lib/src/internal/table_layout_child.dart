import 'package:davi/src/internal/header_widget.dart';
import 'package:davi/src/internal/layout_child_id.dart';
import 'package:davi/src/internal/new/davi_context.dart';
import 'package:davi/src/internal/new/table_content.dart';
import 'package:davi/src/internal/scroll_offsets.dart';
import 'package:davi/src/internal/table_corner.dart';
import 'package:davi/src/internal/table_layout.dart';
import 'package:davi/src/internal/table_layout_parent_data.dart';
import 'package:davi/src/internal/table_layout_settings.dart';
import 'package:davi/src/internal/table_scrollbar.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:meta/meta.dart';

@internal
class TableLayoutChild<DATA> extends ParentDataWidget<TableLayoutParentData> {
  factory TableLayoutChild.header(
      {required DaviContext daviContext,
      required TableLayoutSettings layoutSettings,
      required bool resizable,
      required HorizontalScrollOffsets horizontalScrollOffsets}) {
    return TableLayoutChild._(
        id: LayoutChildId.header,
        child: HeaderWidget(
            daviContext: daviContext,
            layoutSettings: layoutSettings,
            horizontalScrollOffsets: horizontalScrollOffsets,
            resizable: resizable));
  }

  factory TableLayoutChild.cells(
      {required DaviContext<DATA> daviContext,
      required TableLayoutSettings layoutSettings,
      required bool scrolling,
      required HorizontalScrollOffsets horizontalScrollOffsets,
      required ScrollController verticalScrollController}) {
    return TableLayoutChild._(
        id: LayoutChildId.cells,
        child: TableContent(
            daviContext: daviContext,
            scrolling: scrolling,
            layoutSettings: layoutSettings,
            horizontalScrollOffsets: horizontalScrollOffsets,
            verticalScrollController: verticalScrollController));
  }

  factory TableLayoutChild.bottomCorner() {
    return TableLayoutChild._(
        id: LayoutChildId.bottomCorner, child: const TableCorner(top: false));
  }

  factory TableLayoutChild.topCorner() {
    return TableLayoutChild._(
        id: LayoutChildId.topCorner, child: const TableCorner(top: true));
  }

  factory TableLayoutChild.leftPinnedHorizontalScrollbar(Widget scrollbar) {
    return TableLayoutChild._(
        id: LayoutChildId.leftPinnedHorizontalScrollbar, child: scrollbar);
  }

  factory TableLayoutChild.unpinnedHorizontalScrollbar(
      TableScrollbar scrollbar) {
    return TableLayoutChild._(
        id: LayoutChildId.unpinnedHorizontalScrollbar, child: scrollbar);
  }

  factory TableLayoutChild.verticalScrollbar({required Widget child}) {
    return TableLayoutChild._(
        id: LayoutChildId.verticalScrollbar, child: child);
  }

  TableLayoutChild._({
    required this.id,
    required Widget child,
  }) : super(key: ValueKey<LayoutChildId>(id), child: child);

  final LayoutChildId id;

  @override
  void applyParentData(RenderObject renderObject) {
    assert(renderObject.parentData is TableLayoutParentData);
    final TableLayoutParentData parentData =
        renderObject.parentData! as TableLayoutParentData;
    if (id != parentData.id) {
      parentData.id = id;
      renderObject.parent?.markNeedsLayout();
    }
  }

  @override
  Type get debugTypicalAncestorWidgetClass => TableLayout;

  @override
  void debugFillProperties(DiagnosticPropertiesBuilder properties) {
    super.debugFillProperties(properties);
    properties.add(DiagnosticsProperty<Object>('id', id));
  }
}
