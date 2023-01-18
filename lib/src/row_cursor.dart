import 'package:davi/src/row.dart';
import 'package:flutter/material.dart';

/// Signature for a function that defines a row cursor.
/// The theme value will be used if it returns [NULL].
typedef DaviRowCursor<DATA> = MouseCursor? Function(DaviRow<DATA> row);
