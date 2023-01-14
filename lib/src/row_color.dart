import 'package:davi/src/row_data.dart';
import 'package:flutter/material.dart';

/// Signature for a function that defines a row color.
/// The theme value will be used if it returns [NULL].
typedef EasyTableRowColor<ROW> = Color? Function(RowData<ROW> data);
