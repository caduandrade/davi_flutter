import 'package:flutter/widgets.dart';

/// Signature for a function that builds a widget for a given row.
///
/// Used by [DaviColumn].
typedef DaviCellBuilder<DATA> = Widget Function(
    BuildContext context, DATA data, int index, bool hovered);
