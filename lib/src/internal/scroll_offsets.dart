import 'package:easy_table/src/pin_status.dart';
import 'package:meta/meta.dart';

@internal
class TableScrollOffsets {
  TableScrollOffsets(
      {required this.leftPinnedContentArea,
      required this.unpinnedContentArea,
      required this.vertical}) {
    _horizontal = {
      PinStatus.left: leftPinnedContentArea,
      PinStatus.none: unpinnedContentArea
    };
  }

  final double leftPinnedContentArea;
  final double unpinnedContentArea;
  final double vertical;
  late final Map<PinStatus, double> _horizontal;

  double getHorizontal(PinStatus pinStatus) {
    return _horizontal[pinStatus]!;
  }

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is TableScrollOffsets &&
          runtimeType == other.runtimeType &&
          leftPinnedContentArea == other.leftPinnedContentArea &&
          unpinnedContentArea == other.unpinnedContentArea &&
          vertical == other.vertical;

  @override
  int get hashCode =>
      leftPinnedContentArea.hashCode ^
      unpinnedContentArea.hashCode ^
      vertical.hashCode;
}
