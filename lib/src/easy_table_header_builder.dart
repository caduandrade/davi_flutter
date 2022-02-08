import 'package:easy_table/src/easy_table_column.dart';
import 'package:flutter/widgets.dart';

typedef EasyTableHeaderBuilder = Widget Function(
    BuildContext context, EasyTableColumn column, int columnIndex);

class HeaderBuilders {
  static Widget defaultHeaderBuilder(
      BuildContext context, EasyTableColumn column, int columnIndex) {
    Widget? text;
    if (column.name != null) {
      text = Center(child: Text(column.name!));
    }
    return Container(
        child: text, padding: const EdgeInsets.fromLTRB(8, 4, 8, 4));
  }
}
