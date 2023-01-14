import 'package:davi/src/row_data.dart';
import 'package:flutter/material.dart';

/// Signature for a function that defines a row cursor.
/// The theme value will be used if it returns [NULL].
typedef EasyTableRowCursor<DATA> = MouseCursor? Function(RowData<DATA> data);
