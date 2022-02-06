import 'package:flutter/material.dart';

class EasyTableScrollController extends ScrollController {
  @override
  ScrollPosition createScrollPosition(ScrollPhysics physics,
      ScrollContext context, ScrollPosition? oldPosition) {
    return EasyTableScrollPosition(
      physics: physics,
      context: context,
      initialPixels: initialScrollOffset,
      keepScrollOffset: keepScrollOffset,
      oldPosition: oldPosition,
      debugLabel: debugLabel,
    );
  }
}

class EasyTableScrollPosition extends ScrollPositionWithSingleContext {
  EasyTableScrollPosition({
    required ScrollPhysics physics,
    required ScrollContext context,
    double? initialPixels = 0.0,
    bool keepScrollOffset = true,
    ScrollPosition? oldPosition,
    String? debugLabel,
  }) : super(
            physics: physics,
            context: context,
            initialPixels: initialPixels,
            keepScrollOffset: keepScrollOffset,
            oldPosition: oldPosition);

  @override
  double get pixels => super.pixels.floorToDouble();
}

/// Signature for a function that creates a widget for a given column and row.
///
/// Used by [EasyTable].
typedef EasyTableCellWidgetBuilder<COLUMN, ROW> = Widget Function(
    BuildContext context, COLUMN column, ROW row);

class EasyTable<COLUMN, ROW> extends StatefulWidget {
  const EasyTable(
      {Key? key,
      required this.columns,
      required this.rows,
      required this.cellBuilder})
      : super(key: key);

  final double columnDividerThickness = 2;
  final List<COLUMN> columns;
  final List<ROW> rows;
  final EasyTableCellWidgetBuilder<COLUMN, ROW> cellBuilder;

  @override
  State<StatefulWidget> createState() => EasyTableState<COLUMN, ROW>();
}

class EasyTableState<COLUMN, ROW> extends State<EasyTable<COLUMN, ROW>> {
  @override
  Widget build(BuildContext context) {
    CustomScrollView verticalScroll =
        CustomScrollView(slivers: [_header(), _list()]);
    List<Widget> children = [Positioned.fill(child: verticalScroll)];
    children.add(Positioned(
        child:
            Container(width: widget.columnDividerThickness, color: Colors.red),
        left: 50,
        top: 0,
        bottom: 0));
    return Stack(children: children);
  }

  Widget _header() {
    return SliverPersistentHeader(delegate: _HeaderDelegate(), pinned: true);
  }

  Widget _list() {
    SliverChildBuilderDelegate delegate =
        SliverChildBuilderDelegate(_listWidget, childCount: widget.rows.length);
    return SliverList(delegate: delegate);
  }

  Widget? _listWidget(BuildContext context, int index) {
    final EdgeInsetsGeometry padding =
        EdgeInsets.only(right: widget.columnDividerThickness);
    List<Widget> cells = [];
    ROW row = widget.rows[index];
    for (int columnIndex = 0;
        columnIndex < widget.columns.length;
        columnIndex++) {
      COLUMN column = widget.columns[columnIndex];
      Widget cell = ConstrainedBox(
          constraints: const BoxConstraints.tightFor(width: 50),
          child: widget.cellBuilder(context, column, row));
      if (columnIndex < widget.columns.length - 1) {
        cell = Padding(child: cell, padding: padding);
      }
      cells.add(cell);
    }
    return Row(children: cells);
  }
}

class _HeaderDelegate extends SliverPersistentHeaderDelegate {
  @override
  Widget build(
      BuildContext context, double shrinkOffset, bool overlapsContent) {
    return Container(color: Colors.yellow, width: 100);
  }

  @override
  double get maxExtent => 20;

  @override
  double get minExtent => 20;

  @override
  bool shouldRebuild(covariant SliverPersistentHeaderDelegate oldDelegate) {
    return true;
  }
}
