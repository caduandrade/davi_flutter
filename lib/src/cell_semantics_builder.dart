import 'package:flutter/rendering.dart';
import 'package:flutter/widgets.dart';

/// Signature for a function that builds semantics for a given row.
///
/// Used by [DaviColumn].
typedef DaviCellSemanticsBuilder<DATA> = SemanticsProperties Function(
    BuildContext context, DATA data, int index, bool hovered);
