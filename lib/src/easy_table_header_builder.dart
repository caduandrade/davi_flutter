import 'package:easy_table/src/easy_table_column.dart';
import 'package:flutter/widgets.dart';

typedef EasyTableHeaderBuilder = Widget Function(
    BuildContext context, EasyTableColumn column, int columnIndex);
