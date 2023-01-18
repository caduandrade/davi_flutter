import 'package:davi/src/row.dart';
import 'package:flutter/widgets.dart';

/// Signature for a function that builds a widget for a given row.
///
/// Used by [DaviColumn].
typedef DaviCellBuilder<DATA> = Widget Function(
    BuildContext context, DaviRow<DATA> row);
