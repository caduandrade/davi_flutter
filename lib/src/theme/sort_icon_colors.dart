import 'package:flutter/material.dart';

class SortIconColors {
  const SortIconColors({required this.ascending, required this.descending});

  factory SortIconColors.all(Color color) {
    return SortIconColors(ascending: color, descending: color);
  }

  final Color ascending;
  final Color descending;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is SortIconColors &&
          runtimeType == other.runtimeType &&
          ascending == other.ascending &&
          descending == other.descending;

  @override
  int get hashCode => ascending.hashCode ^ descending.hashCode;
}
