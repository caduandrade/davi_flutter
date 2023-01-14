import 'package:davi/src/cell_icon.dart';

/// Signature for a function that maps an [int] value of a row.
///
/// Used by [EasyTableColumn].
typedef EasyTableIntValueMapper<ROW> = int? Function(ROW row);

/// Signature for a function that maps a [double] value of a row.
///
/// Used by [EasyTableColumn].
typedef EasyTableDoubleValueMapper<ROW> = double? Function(ROW row);

/// Signature for a function that maps a [String] value of a row.
///
/// Used by [EasyTableColumn].
typedef EasyTableStringValueMapper<ROW> = String? Function(ROW row);

/// Signature for a function that maps an [Object] value of a row.
///
/// Used by [EasyTableColumn].
typedef EasyTableObjectValueMapper<ROW> = Object? Function(ROW row);

/// Signature for a function that maps a [CellIcon] value of a row.
///
/// Used by [EasyTableColumn].
typedef EasyTableIconValueMapper<ROW> = CellIcon? Function(ROW row);
