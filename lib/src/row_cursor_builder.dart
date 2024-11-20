import 'package:flutter/material.dart';

/// Signature for a function that defines a row cursor.
/// The theme value will be used if it returns [NULL].
typedef RowCursorBuilder<DATA> = MouseCursor? Function(DATA data, int index, bool hovered);
