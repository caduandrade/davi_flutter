import 'package:davi/src/internal/new/hover_notifier.dart';
import 'package:flutter/widgets.dart';
import 'package:meta/meta.dart';

@internal
class HoverListenableBuilder extends StatefulWidget {
  const HoverListenableBuilder(
      {Key? key,
      required this.hoverNotifier,
      required this.rowIndex,
      required this.builder})
      : super(key: key);

  final HoverNotifier hoverNotifier;
  final int rowIndex;
  final WidgetBuilder builder;

  @override
  State<StatefulWidget> createState() => HoverListenableBuilderState();
}

@internal
class HoverListenableBuilderState extends State<HoverListenableBuilder> {
  late int? _hoverIndex;

  @override
  void initState() {
    super.initState();
    _hoverIndex = widget.hoverNotifier.index;
    widget.hoverNotifier.addListener(_valueChanged);
  }

  @override
  void didUpdateWidget(HoverListenableBuilder oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.hoverNotifier != widget.hoverNotifier) {
      oldWidget.hoverNotifier.removeListener(_valueChanged);
      _hoverIndex = widget.hoverNotifier.index;
      widget.hoverNotifier.addListener(_valueChanged);
    }
  }

  @override
  void dispose() {
    widget.hoverNotifier.removeListener(_valueChanged);
    super.dispose();
  }

  void _valueChanged() {
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

  @override
  Widget build(BuildContext context) {
    return widget.builder(context);
  }
}
