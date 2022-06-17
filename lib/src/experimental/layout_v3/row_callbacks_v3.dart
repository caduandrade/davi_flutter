import 'package:easy_table/src/row_callback_typedefs.dart';
import 'package:meta/meta.dart';

@internal
class RowCallbacksV3<ROW> {
  const RowCallbacksV3(
      {required this.onRowDoubleTap,
      required this.onRowTap,
      required this.onRowSecondaryTap});

  final RowDoubleTapCallback<ROW>? onRowDoubleTap;
  final RowTapCallback<ROW>? onRowTap;
  final RowTapCallback<ROW>? onRowSecondaryTap;

  bool get hasCallback =>
      onRowDoubleTap != null || onRowTap != null || onRowSecondaryTap != null;
}
