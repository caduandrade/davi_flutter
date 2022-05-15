import 'package:flutter/material.dart';

/// Icon to be painted in the cell.
class CellIcon {
  CellIcon(
      {required this.icon,
      this.size = 22,
      this.color = Colors.black,
      this.alignment});

  final IconData icon;
  final double size;
  final Color color;
  final Alignment? alignment;
}
