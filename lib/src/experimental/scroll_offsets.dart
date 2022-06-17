import 'package:easy_table/src/experimental/pin_status.dart';

class TableScrollOffsets {
  TableScrollOffsets(
      {required this.leftPinnedContentArea,
      required this.unpinnedContentArea,
      required this.rightPinnedContentArea,
      required this.vertical}) {
    _horizontal = {
      PinStatus.leftPinned: leftPinnedContentArea,
      PinStatus.unpinned: unpinnedContentArea,
      PinStatus.rightPinned: rightPinnedContentArea
    };
  }

  final double leftPinnedContentArea;
  final double unpinnedContentArea;
  final double rightPinnedContentArea;
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
          rightPinnedContentArea == other.rightPinnedContentArea &&
          vertical == other.vertical;

  @override
  int get hashCode =>
      leftPinnedContentArea.hashCode ^
      unpinnedContentArea.hashCode ^
      rightPinnedContentArea.hashCode ^
      vertical.hashCode;
}
