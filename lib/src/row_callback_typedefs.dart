import 'package:flutter/gestures.dart';

/// Signature for when a row tap has occurred.
typedef RowTapCallback<DATA> = void Function(DATA data);

typedef RowTapUpCallback<DATA> = void Function(DATA data, TapUpDetails details);

/// Signature for when a row double tap has occurred.
typedef RowDoubleTapCallback<DATA> = void Function(DATA data);
