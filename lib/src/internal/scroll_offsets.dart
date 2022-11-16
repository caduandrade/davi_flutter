import 'package:easy_table/src/internal/scroll_controllers.dart';
import 'package:easy_table/src/pin_status.dart';
import 'package:meta/meta.dart';

@internal
class HorizontalScrollOffsets {
  factory HorizontalScrollOffsets(ScrollControllers scrollControllers) {
    return HorizontalScrollOffsets._(
        leftPinned: scrollControllers.leftPinnedHorizontal.hasClients
            ? scrollControllers.leftPinnedHorizontal.offset
            : 0,
        unpinned: scrollControllers.unpinnedHorizontal.hasClients
            ? scrollControllers.unpinnedHorizontal.offset
            : 0);
  }

  HorizontalScrollOffsets._({required this.leftPinned, required this.unpinned});

  final double leftPinned;
  final double unpinned;

  double getOffset(PinStatus pinStatus) {
    if (pinStatus == PinStatus.none) {
      return unpinned;
    } else if (pinStatus == PinStatus.left) {
      return leftPinned;
    }
    throw ArgumentError('PinStatus not supported: $pinStatus');
  }

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is HorizontalScrollOffsets &&
          runtimeType == other.runtimeType &&
          leftPinned == other.leftPinned &&
          unpinned == other.unpinned;

  @override
  int get hashCode => leftPinned.hashCode ^ unpinned.hashCode;
}
