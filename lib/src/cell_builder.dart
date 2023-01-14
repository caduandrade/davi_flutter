import 'package:davi/src/row_data.dart';
import 'package:flutter/widgets.dart';

/// Signature for a function that builds a widget for a given row.
///
/// Used by [EasyTableColumn].
typedef EasyTableCellBuilder<ROW> = Widget Function(
    BuildContext context, RowData<ROW> data);
