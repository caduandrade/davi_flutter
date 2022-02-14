import 'dart:math' as math;
import 'package:easy_table/src/easy_table_cell.dart';
import 'package:easy_table/src/easy_table_cell_builder.dart';
import 'package:easy_table/src/theme/easy_table_theme.dart';
import 'package:easy_table/src/theme/easy_table_theme_data.dart';
import 'package:easy_table/src/easy_table_value_mapper.dart';
import 'package:flutter/widgets.dart';

/// Signature for sort column function.
typedef EasyTableColumnSortFunction<ROW> = int Function(ROW a, ROW b);

/// The [EasyTable] column.
///
/// The [name] argument is optional and is used by the default
/// cell header widget.
///
/// The optional value mappings [intValue], [doubleValue], [stringValue] and
/// [objectValue] allows automatic cell configuration by identifying
/// and displaying data types in the row object.
///
/// The [cellBuilder] builds a cell widget for each row in that column.
/// A default [cellBuilder] will be used if the column has any value
/// mapping defined.
///
/// This column is sortable if the argument [sortable] is [TRUE] and
/// a [sortFunction] has been defined for ascending sort. Descending sort
/// is applied by inverting the arguments in [sortFunction].
///
/// The default value of [sortable] is [TRUE].
///
/// If the [sortFunction] is not set, it will be created automatically
/// for the value mappings.
///
/// The [fractionDigits] is the optional decimal-point string-representation
/// used by the default cell width when the [doubleValue] is set.
class EasyTableColumn<ROW> extends ChangeNotifier {
  factory EasyTableColumn(
      {dynamic id,
      double width = 100,
      String? name,
      int? fractionDigits,
      bool sortable = true,
      bool resizable = true,
      EasyTableCellBuilder<ROW>? cellBuilder,
      EasyTableColumnSortFunction<ROW>? sortFunction,
      EasyTableIntValueMapper<ROW>? intValue,
      EasyTableDoubleValueMapper<ROW>? doubleValue,
      EasyTableStringValueMapper<ROW>? stringValue,
      EasyTableObjectValueMapper<ROW>? objectValue}) {
    if (sortFunction == null) {
      if (intValue != null) {
        sortFunction = (a, b) => intValue(a).compareTo(intValue(b));
      } else if (doubleValue != null) {
        sortFunction = (a, b) => doubleValue(a).compareTo(doubleValue(b));
      } else if (stringValue != null) {
        sortFunction = (a, b) => stringValue(a).compareTo(stringValue(b));
      } else if (objectValue != null) {
        sortFunction = (a, b) {
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
        name: name,
        fractionDigits: fractionDigits,
        cellBuilder: cellBuilder,
        sortFunction: sortFunction,
        stringValueMapper: stringValue,
        intValueMapper: intValue,
        doubleValueMapper: doubleValue,
        objectValueMapper: objectValue,
        sortable: sortable,
        resizable: resizable);
  }

  EasyTableColumn._(
      {this.id,
      required double width,
      this.name,
      this.fractionDigits,
      this.cellBuilder,
      this.sortFunction,
      this.stringValueMapper,
      this.intValueMapper,
      this.doubleValueMapper,
      this.objectValueMapper,
      required this.resizable,
      required bool sortable})
      : _width = width,
        _sortable = sortable;

  final dynamic id;
  final String? name;
  final int? fractionDigits;
  final EasyTableCellBuilder<ROW>? cellBuilder;
  final EasyTableColumnSortFunction<ROW>? sortFunction;
  final EasyTableIntValueMapper<ROW>? intValueMapper;
  final EasyTableDoubleValueMapper<ROW>? doubleValueMapper;
  final EasyTableStringValueMapper<ROW>? stringValueMapper;
  final EasyTableObjectValueMapper<ROW>? objectValueMapper;
  final bool _sortable;
  double _width;

  double get width => _width;
  set width(double value) {
    //TODO resizeAreaWidth should be smaller
    value = math.max(16, value);
    if (_width != value) {
      _width = value;
      notifyListeners();
    }
  }

  bool get sortable => _sortable && sortFunction != null;

  bool resizable;

  Widget? buildCellWidget(BuildContext context, ROW row) {
    if (cellBuilder != null) {
      return cellBuilder!(context, row);
    }
    EasyTableThemeData theme = EasyTableTheme.of(context);
    final TextStyle? textStyle = theme.cell.textStyle;

    if (stringValueMapper != null) {
      final String value = stringValueMapper!(row);
      return EasyTableCell.string(value: value, textStyle: textStyle);
    } else if (intValueMapper != null) {
      final int value = intValueMapper!(row);
      return EasyTableCell.int(value: value, textStyle: textStyle);
    } else if (doubleValueMapper != null) {
      final double value = doubleValueMapper!(row);
      return EasyTableCell.double(
          value: value, fractionDigits: fractionDigits, textStyle: textStyle);
    } else if (objectValueMapper != null) {
      final Object value = objectValueMapper!(row);
      return EasyTableCell.string(
          value: value.toString(), textStyle: textStyle);
    }
    return Container();
  }

  @override
  String toString() {
    return 'EasyTableColumn{name: $name}';
  }
}
