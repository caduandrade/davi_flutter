import 'dart:ui';

import 'package:meta/meta.dart';

@internal
class RowsPaintingSettings {
  RowsPaintingSettings({required this.divisorColor});

  final Color? divisorColor;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is RowsPaintingSettings &&
          runtimeType == other.runtimeType &&
          divisorColor == other.divisorColor;

  @override
  int get hashCode => divisorColor.hashCode;
}
