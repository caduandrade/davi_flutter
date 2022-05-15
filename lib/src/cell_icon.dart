import 'package:flutter/material.dart';

/// Icon to be painted in the cell.
class CellIcon {
  CellIcon(
      {required this.icon,
      this.size = 24,
      this.color = Colors.black,
      this.alignment,
      this.background});

  final IconData icon;
  final double size;
  final Color color;
  final Color? background;
  final Alignment? alignment;
}
