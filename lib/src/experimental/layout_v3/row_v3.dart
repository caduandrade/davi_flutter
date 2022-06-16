import 'package:easy_table/src/experimental/layout_v3/column_layout/columns_layout_child_v3.dart';
import 'package:easy_table/src/experimental/layout_v3/column_layout/columns_layout_settings.dart';
import 'package:easy_table/src/experimental/layout_v3/column_layout/columns_layout_v3.dart';
import 'package:easy_table/src/internal/cell.dart';
import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';

class RowV3<ROW> extends StatefulWidget {
  RowV3({required this.rowIndex, required this.row})
      : super(key: ValueKey(rowIndex));

  final ROW row;
  final int rowIndex;

  @override
  State<StatefulWidget> createState() => RowV3State();
}

class RowV3State extends State<RowV3> {
  bool _enter = false;
  @override
  Widget build(BuildContext context) {
    List<ColumnsLayoutChildV3> children = [];
    for (int i = 0; i < 9; i++) {
      children.add(ColumnsLayoutChildV3(
          index: i,
          child: EasyTableCell(
              alignment: null,
              background: null,
              padding: null,
              child: Text('${widget.rowIndex}/$i'))));
    }
    ColumnsLayoutSettings layoutSettings = ColumnsLayoutSettings();
    Color? color = _enter ? Colors.blue[300] : null;
    return MouseRegion(
        onEnter: _onEnter,
        cursor: SystemMouseCursors.click,
        onExit: _onExit,
        child: Container(
            color: color,
            child: ColumnsLayoutV3(
                layoutSettings: layoutSettings, children: children)));
  }

  void _onEnter(PointerEnterEvent event) {
    setState(() => _enter = true);
  }

  void _onExit(PointerExitEvent event) {
    setState(() => _enter = false);
  }
}
