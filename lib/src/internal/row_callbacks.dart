import 'package:davi/src/row_callback_typedefs.dart';
import 'package:meta/meta.dart';

@internal
class RowCallbacks<ROW> {
  const RowCallbacks(
      {required this.onRowDoubleTap,
      required this.onRowTap,
      required this.onRowSecondaryTap});

  final RowDoubleTapCallback<ROW>? onRowDoubleTap;
  final RowTapCallback<ROW>? onRowTap;
  final RowTapCallback<ROW>? onRowSecondaryTap;

  bool get hasCallback =>
      onRowDoubleTap != null || onRowTap != null || onRowSecondaryTap != null;
}
