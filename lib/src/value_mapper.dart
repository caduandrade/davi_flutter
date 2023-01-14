import 'package:davi/src/cell_icon.dart';

/// Signature for a function that maps an [int] value of a row.
///
/// Used by [DaviColumn].
typedef DaviIntValueMapper<ROW> = int? Function(ROW row);

/// Signature for a function that maps a [double] value of a row.
///
/// Used by [DaviColumn].
typedef DaviDoubleValueMapper<ROW> = double? Function(ROW row);

/// Signature for a function that maps a [String] value of a row.
///
/// Used by [DaviColumn].
typedef DaviStringValueMapper<ROW> = String? Function(ROW row);

/// Signature for a function that maps an [Object] value of a row.
///
/// Used by [DaviColumn].
typedef DaviObjectValueMapper<ROW> = Object? Function(ROW row);

/// Signature for a function that maps a [CellIcon] value of a row.
///
/// Used by [DaviColumn].
typedef DaviIconValueMapper<ROW> = CellIcon? Function(ROW row);
