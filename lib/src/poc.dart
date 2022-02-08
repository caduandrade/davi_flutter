import 'package:flutter/material.dart';

class Poc extends StatelessWidget {
  const Poc({Key? key}) : super(key: key);

  Widget _container(ScrollController controller) {
    Widget list = ListView.builder(
        controller: controller,
        itemExtent: 50,
        itemBuilder: (context, index) {
          return Text(
              '$index Lorem ipsum dolor sit amet, consectetur adipiscing elit, sed do eiusmod tempor incididunt ut labore et dolore magna aliqua. Ut enim ad minim veniam, quis nostrud exercitation ullamco laboris nisi ut aliquip ex ea commodo consequat. Duis aute irure dolor in reprehenderit in voluptate velit esse cillum dolore eu fugiat nulla pariatur. Excepteur sint occaecat cupidatat non proident, sunt in culpa qui officia deserunt mollit anim id est laborum.');
        },
        itemCount: 5000);
    return Container(width: 3500, child: list);
  }

  @override
  Widget build(BuildContext context) {
    ScrollController horizontalController = ScrollController();
    ScrollController verticalController = ScrollController();

    return Scaffold(
        body: Scrollbar(
            isAlwaysShown: true,
            controller: horizontalController,
            child: Scrollbar(
                isAlwaysShown: true,
                controller: verticalController,
                notificationPredicate: (p) {
                  //  print(p);
                  return true;
                },
                child: SingleChildScrollView(
                  scrollDirection: Axis.horizontal,
                  controller: horizontalController,
                  child: _container(verticalController),
                ))));
  }

  Widget _fixedTable() {
    return SliverPersistentHeader(
        delegate: _SliverColumnDelegate(), pinned: true);
  }

  Widget _scrollableTable() {
    return const SliverToBoxAdapter(
        child: HeaderAndRows(
            headerColor: Colors.red, rowsColor: Colors.orange, width: 1300));
  }
}

class HeaderAndRows extends StatefulWidget {
  const HeaderAndRows(
      {Key? key,
      required this.headerColor,
      required this.rowsColor,
      required this.width})
      : super(key: key);

  final Color headerColor;
  final Color rowsColor;
  final double width;

  @override
  State<StatefulWidget> createState() => HeaderAndRowsState();
}

class HeaderAndRowsState extends State<HeaderAndRows> {
  @override
  Widget build(BuildContext context) {
    return CustomScrollView(slivers: [_header(), _rows()]);
  }

  Widget _header() {
    return SliverPersistentHeader(
        delegate:
            _HeaderDelegate(color: widget.headerColor, width: widget.width),
        pinned: true);
  }

  Widget _rows() {
    return SliverToBoxAdapter(
        child:
            Dummy(color: widget.rowsColor, width: widget.width, height: 1500));
  }
}

class _HeaderDelegate extends SliverPersistentHeaderDelegate {
  _HeaderDelegate({required this.color, required this.width});

  final Color color;
  final double width;
  final double height = 24;

  @override
  Widget build(
      BuildContext context, double shrinkOffset, bool overlapsContent) {
    return Dummy(color: color, width: width, height: height);
  }

  @override
  double get maxExtent => height;

  @override
  double get minExtent => height;

  @override
  bool shouldRebuild(covariant _HeaderDelegate oldDelegate) {
    return color != oldDelegate.color || width != oldDelegate.width;
  }
}

class _SliverColumnDelegate extends SliverPersistentHeaderDelegate {
  @override
  Widget build(
      BuildContext context, double shrinkOffset, bool overlapsContent) {
    return const HeaderAndRows(
        headerColor: Colors.green, rowsColor: Colors.blue, width: 100);
  }

  @override
  double get maxExtent => 100;

  @override
  double get minExtent => 100;

  @override
  bool shouldRebuild(covariant SliverPersistentHeaderDelegate oldDelegate) {
    return true;
  }
}

class Dummy extends StatelessWidget {
  const Dummy(
      {Key? key,
      required this.color,
      required this.width,
      required this.height})
      : super(key: key);
  final Color color;
  final double width;
  final double height;

  @override
  Widget build(BuildContext context) {
    return SizedBox(child: _placeholder(), width: width, height: height);
  }

  Widget _placeholder() {
    return Placeholder(color: color);
  }

  Widget _container() {
    return Container(color: color, height: height, width: width);
  }
}

class SyncScrollController {
  List<ScrollController> _registeredScrollControllers = [];

  ScrollController? _scrollingController;
  bool _scrollingActive = false;

  SyncScrollController._() {}

  factory SyncScrollController({required List<ScrollController> controllers}) {
    SyncScrollController c = SyncScrollController._();
    controllers.forEach((controller) => c.registerScrollController(controller));
    return c;
  }

  void registerScrollController(ScrollController controller) {
    _registeredScrollControllers.add(controller);
  }

  void processNotification(
      ScrollNotification notification, ScrollController sender) {
    if (notification is ScrollStartNotification && !_scrollingActive) {
      _scrollingController = sender;
      _scrollingActive = true;
      return;
    }

    if (identical(sender, _scrollingController) && _scrollingActive) {
      if (notification is ScrollEndNotification) {
        _scrollingController = null;
        _scrollingActive = false;
        return;
      }

      if (notification is ScrollUpdateNotification) {
        _registeredScrollControllers.forEach((controller) => {
              if (_scrollingController != null &&
                  !identical(_scrollingController, controller))
                controller..jumpTo(_scrollingController!.offset)
            });
        return;
      }
    }
  }
}
