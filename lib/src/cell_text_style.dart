import 'package:flutter/widgets.dart';

/// Signature for a function that builds a text style for a cell.
///
/// Used by [DaviColumn].
typedef CellTextStyleBuilder<DATA> = TextStyle? Function(
    DATA data, int index, bool hovered);
