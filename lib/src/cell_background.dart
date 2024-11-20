import 'package:flutter/widgets.dart';

/// Signature for a function that builds a background for a row.
///
/// Used by [DaviColumn].
typedef CellBackgroundBuilder<DATA> = Color? Function(DATA data, int index, bool hovered);
