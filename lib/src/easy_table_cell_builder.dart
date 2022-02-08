import 'package:flutter/widgets.dart';

/// Signature for a function that creates a widget for a given column and row.
///
/// Used by [EasyTable].
typedef EasyTableCellBuilder<ROW_VALUE> = Widget Function(
    BuildContext context, ROW_VALUE rowValue);
