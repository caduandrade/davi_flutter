import 'package:easy_table/src/easy_table_cell.dart';
import 'package:easy_table/src/easy_table_column.dart';
import 'package:flutter/widgets.dart';

typedef EasyTableHeaderCellBuilder = Widget Function(
    BuildContext context, EasyTableColumn column, int columnIndex);

class HeaderCellBuilders {
  static Widget defaultHeaderCellBuilder(
      BuildContext context, EasyTableColumn column, int columnIndex) {
    return EasyTableCell(value: column.name);
  }
}
