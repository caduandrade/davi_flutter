import 'package:easy_table/src/easy_table_cell.dart';
import 'package:easy_table/src/easy_table_column.dart';
import 'package:flutter/widgets.dart';

/// Signature for a function that builds a widget for a column header.
///
/// Used by [EasyTableColumn].
typedef EasyTableHeaderCellBuilder = Widget Function(
    BuildContext context, EasyTableColumn column, int columnIndex);

/// Default header cell builders.
class HeaderCellBuilders {
  static Widget defaultHeaderCellBuilder(
      BuildContext context, EasyTableColumn column, int columnIndex) {
    return EasyTableCell(
        value: column.name,
        textStyle: const TextStyle(fontWeight: FontWeight.bold));
  }
}
