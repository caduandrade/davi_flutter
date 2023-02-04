import 'package:davi/src/sort_direction.dart';
import 'package:davi/src/theme/sort_icon.dart';
import 'package:davi/src/theme/sort_icon_colors.dart';
import 'package:flutter/widgets.dart';

/// Default sort icon builders.
class SortIconBuilders {
  static Widget size12(DaviSortDirection direction, SortIconColors colors) {
    return build(
        direction: direction, colors: colors, size: SortIconSize.size12);
  }

  static Widget size12Inverted(
      DaviSortDirection direction, SortIconColors colors) {
    return build(
        direction: direction,
        colors: colors,
        size: SortIconSize.size12,
        inverted: true);
  }

  static Widget size14(DaviSortDirection direction, SortIconColors colors) {
    return build(
        direction: direction, colors: colors, size: SortIconSize.size14);
  }

  static Widget size14Inverted(
      DaviSortDirection direction, SortIconColors colors) {
    return build(
        direction: direction,
        colors: colors,
        size: SortIconSize.size14,
        inverted: true);
  }

  static Widget size16Tall(DaviSortDirection direction, SortIconColors colors) {
    return build(
        direction: direction, colors: colors, size: SortIconSize.size16Tall);
  }

  static Widget size16TallInverted(
      DaviSortDirection direction, SortIconColors colors) {
    return build(
        direction: direction,
        colors: colors,
        size: SortIconSize.size16Tall,
        inverted: true);
  }

  static Widget size16Short(
      DaviSortDirection direction, SortIconColors colors) {
    return build(
        direction: direction, colors: colors, size: SortIconSize.size16Short);
  }

  static Widget size16ShortInverted(
      DaviSortDirection direction, SortIconColors colors) {
    return build(
        direction: direction,
        colors: colors,
        size: SortIconSize.size16Short,
        inverted: true);
  }

  static Widget size19(DaviSortDirection direction, SortIconColors colors) {
    return build(
        direction: direction, colors: colors, size: SortIconSize.size19);
  }

  static Widget size19Inverted(
      DaviSortDirection direction, SortIconColors colors) {
    return build(
        direction: direction,
        colors: colors,
        size: SortIconSize.size19,
        inverted: true);
  }

  static Widget build(
      {required DaviSortDirection direction,
      required SortIconColors colors,
      required SortIconSize size,
      bool inverted = false}) {
    return SortIcon(
        direction: direction,
        size: size,
        color: direction == DaviSortDirection.ascending
            ? colors.ascending
            : colors.descending,
        inverted: inverted);
  }
}
