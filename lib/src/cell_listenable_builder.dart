import 'package:flutter/widgets.dart';

/// A function that provides a [Listenable] for a specific cell in a column.
/// The function receives the row's data ([DATA]) and the row index ([rowIndex])
/// and returns the corresponding [Listenable].
typedef DaviCellListenableBuilder<DATA> = Listenable? Function(
    DATA data, int rowIndex);
