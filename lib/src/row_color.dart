import 'package:easy_table/src/row_data.dart';
import 'package:flutter/material.dart';

/// Signature for a function that defines a row color.
typedef EasyTableRowColor<ROW> = Color? Function(RowData<ROW> data);
