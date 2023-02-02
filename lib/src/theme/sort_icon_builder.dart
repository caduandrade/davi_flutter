import 'package:davi/src/sort_direction.dart';
import 'package:davi/src/theme/sort_icon_colors.dart';
import 'package:flutter/widgets.dart';

typedef SortIconBuilder = Widget Function(
    DaviSortDirection direction, SortIconColors colors);
