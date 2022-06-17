import 'package:easy_table/src/row_callback_typedefs.dart';
import 'package:meta/meta.dart';

/// Signature for when a row tap has occurred.
@internal
typedef IndexRowTapCallback = void Function(int rowIndex);

/// Signature for when a row double tap has occurred.
@internal
typedef IndexRowDoubleTapCallback = void Function(int rowIndex);

@internal
class RowCallbacksV2 {
  const RowCallbacksV2(
      {required this.onRowDoubleTap,
      required this.onRowTap,
      required this.onRowSecondaryTap});

  final IndexRowDoubleTapCallback onRowDoubleTap;
  final IndexRowTapCallback onRowTap;
  final IndexRowTapCallback onRowSecondaryTap;
}
