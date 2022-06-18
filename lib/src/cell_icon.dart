import 'package:flutter/material.dart';

/// Icon to be painted in the cell.
class CellIcon {
  CellIcon({required this.icon, this.size = 24, this.color = Colors.black});

  final IconData icon;
  final double size;
  final Color color;
}
