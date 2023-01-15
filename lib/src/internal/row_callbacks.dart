import 'package:davi/src/row_callback_typedefs.dart';
import 'package:meta/meta.dart';

@internal
class RowCallbacks<DATA> {
  const RowCallbacks(
      {required this.onRowDoubleTap,
      required this.onRowTap,
      required this.onRowSecondaryTap});

  final RowDoubleTapCallback<DATA>? onRowDoubleTap;
  final RowTapCallback<DATA>? onRowTap;
  final RowTapCallback<DATA>? onRowSecondaryTap;

  bool get hasCallback =>
      onRowDoubleTap != null || onRowTap != null || onRowSecondaryTap != null;
}
