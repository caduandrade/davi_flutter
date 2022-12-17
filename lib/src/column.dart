import 'dart:math' as math;

import 'package:easy_table/src/cell_background.dart';
import 'package:easy_table/src/cell_builder.dart';
import 'package:easy_table/src/cell_style.dart';
import 'package:easy_table/src/model.dart';
import 'package:easy_table/src/pin_status.dart';
import 'package:easy_table/src/value_mapper.dart';
import 'package:flutter/widgets.dart';

/// Signature for sort column function.
typedef EasyTableColumnSort<ROW> = int Function(ROW a, ROW b);

/// The [EasyTable] column.
///
/// The [name] argument is optional and is used by the default
/// cell header widget.
///
/// The optional value mappings [intValue], [doubleValue], [stringValue],
/// [iconValue] and [objectValue] allows automatic cell configuration
/// by identifying and displaying data types in the row object.
///
/// The [cellBuilder] builds a cell widget for each row in that column.
/// A default [cellBuilder] will be used if the column has any value
/// mapping defined.
///
/// This column is sortable if the argument [sortable] is [TRUE] and
/// a [sort] has been defined for ascending sort. Descending sort
/// is applied by inverting the arguments in [sort].
///
/// The default value of [sortable] is [TRUE].
///
/// If the [sort] is not set, it will be created automatically
/// for the value mappings.
///
/// The [fractionDigits] is the optional decimal-point string-representation
/// used by the default cell width when the [doubleValue] is set.
class EasyTableColumn<ROW> extends ChangeNotifier with ColumnSortMixin {
  factory EasyTableColumn(
      {dynamic id,
      double width = 100,
      double? grow,
      String? name,
      int? fractionDigits,
      bool sortable = true,
      bool resizable = true,
      PinStatus pinStatus = PinStatus.none,
      EdgeInsets? headerPadding,
      EdgeInsets? cellPadding,
      Alignment? headerAlignment,
      Alignment? cellAlignment,
      TextStyle? cellTextStyle,
      TextOverflow? cellOverflow,
      CellBackgroundBuilder<ROW>? cellBackground,
      TextStyle? headerTextStyle,
      bool cellClip = false,
      Widget? leading,
      EasyTableCellBuilder<ROW>? cellBuilder,
      EasyTableColumnSort<ROW>? sort,
      EasyTableIntValueMapper<ROW>? intValue,
      EasyTableDoubleValueMapper<ROW>? doubleValue,
      EasyTableStringValueMapper<ROW>? stringValue,
      EasyTableIconValueMapper<ROW>? iconValue,
      EasyTableObjectValueMapper<ROW>? objectValue,
      CellStyleBuilder<ROW>? cellStyleBuilder}) {
    if (sort == null) {
      if (intValue != null) {
        sort = (a, b) {
          int? v1 = intValue(a);
          int? v2 = intValue(b);
          if (v1 == null && v2 == null) {
            return 0;
          }
          if (v1 == null) {
            return -1;
          }
          if (v2 == null) {
            return 1;
          }
          return v1.compareTo(v2);
        };
      } else if (doubleValue != null) {
        sort = (a, b) {
          double? v1 = doubleValue(a);
          double? v2 = doubleValue(b);
          if (v1 == null && v2 == null) {
            return 0;
          }
          if (v1 == null) {
            return -1;
          }
          if (v2 == null) {
            return 1;
          }
          return v1.compareTo(v2);
        };
      } else if (stringValue != null) {
        sort = (a, b) {
          String? v1 = stringValue(a);
          String? v2 = stringValue(b);
          if (v1 == null && v2 == null) {
            return 0;
          }
          if (v1 == null) {
            return -1;
          }
          if (v2 == null) {
            return 1;
          }
          return v1.compareTo(v2);
        };
      } else if (objectValue != null) {
        sort = (a, b) {
          Object? v1 = objectValue(a);
          Object? v2 = objectValue(b);
          if (v1 == null && v2 == null) {
            return 0;
          }
          if (v1 == null) {
            return -1;
          }
          if (v2 == null) {
            return 1;
          }
          if (a is Comparable && b is Comparable) {
            return a.compareTo(b);
          }
          return 0;
        };
      }
    }
    //TODO check multiple value mappers
    return EasyTableColumn._(
        id: id,
        width: width,
        grow: grow,
        name: name,
        fractionDigits: fractionDigits,
        cellBuilder: cellBuilder,
        leading: leading,
        sort: sort,
        pinStatus: pinStatus,
        stringValueMapper: stringValue,
        intValueMapper: intValue,
        doubleValueMapper: doubleValue,
        objectValueMapper: objectValue,
        iconValueMapper: iconValue,
        sortable: sortable,
        resizable: resizable,
        headerPadding: headerPadding,
        cellPadding: cellPadding,
        cellBackground: cellBackground,
        cellOverflow: cellOverflow,
        headerAlignment: headerAlignment,
        cellAlignment: cellAlignment,
        headerTextStyle: headerTextStyle,
        cellTextStyle: cellTextStyle,
        cellStyleBuilder: cellStyleBuilder,
        cellClip: cellClip);
  }

  EasyTableColumn._(
      {required this.id,
      required double width,
      double? grow,
      required this.name,
      required this.headerPadding,
      required this.cellPadding,
      required this.headerAlignment,
      required this.cellAlignment,
      required this.cellBackground,
      required this.headerTextStyle,
      required this.cellTextStyle,
      required this.cellOverflow,
      required this.fractionDigits,
      required this.cellBuilder,
      required this.leading,
      required this.sort,
      required this.pinStatus,
      required this.stringValueMapper,
      required this.intValueMapper,
      required this.iconValueMapper,
      required this.doubleValueMapper,
      required this.objectValueMapper,
      required this.resizable,
      required this.cellClip,
      required bool sortable,
      required this.cellStyleBuilder})
      : _width = width,
        _grow = grow != null ? math.max(1, grow) : null,
        _sortable = sortable;

  final dynamic id;
  final String? name;
  final Widget? leading;
  final EdgeInsets? cellPadding;
  final EdgeInsets? headerPadding;
  final Alignment? headerAlignment;
  final Alignment? cellAlignment;
  final TextOverflow? cellOverflow;
  final CellBackgroundBuilder<ROW>? cellBackground;
  final TextStyle? cellTextStyle;
  final TextStyle? headerTextStyle;
  final int? fractionDigits;
  final PinStatus pinStatus;
  final EasyTableCellBuilder<ROW>? cellBuilder;
  final EasyTableColumnSort<ROW>? sort;
  final EasyTableIntValueMapper<ROW>? intValueMapper;
  final EasyTableDoubleValueMapper<ROW>? doubleValueMapper;
  final EasyTableStringValueMapper<ROW>? stringValueMapper;
  final EasyTableObjectValueMapper<ROW>? objectValueMapper;
  final EasyTableIconValueMapper<ROW>? iconValueMapper;
  final CellStyleBuilder<ROW>? cellStyleBuilder;
  final bool cellClip;
  final bool _sortable;
  double _width;
  double? _grow;

  /// The grow factor to use for this column.
  ///
  /// Can be positive or null. If null, the column is not stretchable.
  double? get grow => _grow;

  set grow(double? value) {
    if (value != null) {
      value = math.max(1, value);
    }
    if (_grow != value) {
      _grow = value;
      notifyListeners();
    }
  }

  double get width => _width;

  set width(double value) {
    value = math.max(16, value);
    if (_width != value) {
      _width = value;
      notifyListeners();
    }
  }

  bool get sortable => _sortable && sort != null;

  bool resizable;

  @override
  String toString() {
    return 'EasyTableColumn{name: $name}';
  }
}
