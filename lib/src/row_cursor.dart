import 'package:easy_table/src/row_data.dart';
import 'package:flutter/material.dart';

/// Signature for a function that defines a row cursor.
typedef EasyTableRowCursor<DATA> = MouseCursor? Function(RowData<DATA> data);
