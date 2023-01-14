import 'package:davi/src/row_data.dart';
import 'package:flutter/widgets.dart';

/// Signature for a function that builds a background for a row.
///
/// Used by [EasyTableColumn].
typedef CellBackgroundBuilder<ROW> = Color? Function(RowData<ROW> data);
