import 'package:davi/src/internal/new/hover_notifier.dart';
import 'package:flutter/widgets.dart';
import 'package:meta/meta.dart';

@internal
class CellListenableBuilder extends StatefulWidget {
  const CellListenableBuilder(
      {Key? key,
      required this.hoverNotifier,
      required this.cellListenable,
      required this.rowIndex,
      required this.builder})
      : super(key: key);

  final HoverNotifier hoverNotifier;
  final Listenable? cellListenable;
  final int rowIndex;
  final WidgetBuilder builder;

  @override
  State<StatefulWidget> createState() => CellListenableBuilderState();
}

@internal
class CellListenableBuilderState extends State<CellListenableBuilder> {
  late int? _hoverIndex;

  @override
  void initState() {
    super.initState();
    _hoverIndex = widget.hoverNotifier.index;
    widget.hoverNotifier.addListener(_hoverChanged);
    widget.cellListenable?.addListener(_rebuild);
  }

  @override
  void didUpdateWidget(CellListenableBuilder oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.hoverNotifier != widget.hoverNotifier) {
      oldWidget.hoverNotifier.removeListener(_hoverChanged);
      _hoverIndex = widget.hoverNotifier.index;
      widget.hoverNotifier.addListener(_hoverChanged);
    }
    if (oldWidget.cellListenable != widget.cellListenable) {
      oldWidget.cellListenable?.removeListener(_rebuild);
      widget.cellListenable?.addListener(_rebuild);
    }
  }

  @override
  void dispose() {
    widget.hoverNotifier.removeListener(_hoverChanged);
    widget.cellListenable?.removeListener(_rebuild);
    super.dispose();
  }

  void _hoverChanged() {
    if (_hoverIndex == null && widget.hoverNotifier.index == widget.rowIndex) {
      // row enter
      setState(() {
        _hoverIndex = widget.hoverNotifier.index;
      });
    }
    if (_hoverIndex == widget.rowIndex &&
        widget.hoverNotifier.index != widget.rowIndex) {
      // row exit
      setState(() {
        _hoverIndex = null;
      });
    }
  }

  void _rebuild() {
    setState(() {
      // just rebuild
    });
  }

  @override
  Widget build(BuildContext context) {
    return widget.builder(context);
  }
}
