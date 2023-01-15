import 'package:davi/src/row.dart';
import 'package:flutter/material.dart';

/// Signature for a function that defines a row color.
/// The theme value will be used if it returns [NULL].
typedef DaviRowColor<DATA> = Color? Function(DaviRow<DATA> row);
