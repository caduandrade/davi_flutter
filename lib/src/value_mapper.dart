import 'package:davi/src/cell_icon.dart';

/// Signature for a function that maps an [int] value of a row.
///
/// Used by [DaviColumn].
typedef DaviIntValueMapper<DATA> = int? Function(DATA data);

/// Signature for a function that maps a [double] value of a row.
///
/// Used by [DaviColumn].
typedef DaviDoubleValueMapper<DATA> = double? Function(DATA data);

/// Signature for a function that maps a [String] value of a row.
///
/// Used by [DaviColumn].
typedef DaviStringValueMapper<DATA> = String? Function(DATA data);

/// Signature for a function that maps an [Object] value of a row.
///
/// Used by [DaviColumn].
typedef DaviObjectValueMapper<DATA> = Object? Function(DATA data);

/// Signature for a function that maps a [CellIcon] value of a row.
///
/// Used by [DaviColumn].
typedef DaviIconValueMapper<DATA> = CellIcon? Function(DATA data);
