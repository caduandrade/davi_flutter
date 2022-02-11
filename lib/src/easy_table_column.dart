import 'package:easy_table/src/easy_table_cell.dart';
import 'package:easy_table/src/easy_table_cell_builder.dart';
import 'package:easy_table/src/easy_table_header_cell_builder.dart';
import 'package:easy_table/src/theme/easy_table_theme.dart';
import 'package:easy_table/src/theme/easy_table_theme_data.dart';
import 'package:easy_table/src/easy_table_value_mapper.dart';
import 'package:flutter/widgets.dart';

/// Signature for sort column function.
typedef EasyTableColumnSortFunction<ROW> = int Function(ROW a, ROW b);

/// The [EasyTable] column.
class EasyTableColumn<ROW> extends ChangeNotifier {
  factory EasyTableColumn(
      {dynamic id,
      double width = 100,
      String? name,
      int? fractionDigits,
      EasyTableCellBuilder<ROW>? cellBuilder,
      EasyTableHeaderCellBuilder? headerCellBuilder =
          HeaderCellBuilders.defaultHeaderCellBuilder,
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
        headerCellBuilder: headerCellBuilder,
        sortFunction: sortFunction,
        stringValueMapper: stringValue,
        intValueMapper: intValue,
        doubleValueMapper: doubleValue,
        objectValueMapper: objectValue);
  }

  EasyTableColumn._(
      {this.id,
      required double width,
      this.name,
      this.fractionDigits,
      this.cellBuilder,
      this.headerCellBuilder,
      this.sortFunction,
      this.stringValueMapper,
      this.intValueMapper,
      this.doubleValueMapper,
      this.objectValueMapper})
      : _width = width;

  final dynamic id;
  final String? name;
  final int? fractionDigits;
  final EasyTableCellBuilder<ROW>? cellBuilder;
  final EasyTableHeaderCellBuilder? headerCellBuilder;
  final EasyTableColumnSortFunction<ROW>? sortFunction;
  final EasyTableIntValueMapper<ROW>? intValueMapper;
  final EasyTableDoubleValueMapper<ROW>? doubleValueMapper;
  final EasyTableStringValueMapper<ROW>? stringValueMapper;
  final EasyTableObjectValueMapper<ROW>? objectValueMapper;

  double _width;

  double get width => _width;
  set width(double value) {
    //TODO negative check
    _width = value;
    notifyListeners();
  }

  bool get sortable => sortFunction != null;

  Widget? buildCellWidget(BuildContext context, ROW row) {
    if (cellBuilder != null) {
      return cellBuilder!(context, row);
    }
    EasyTableThemeData theme = EasyTableTheme.of(context);
    final TextStyle? textStyle = theme.cell.textStyle;

    if (stringValueMapper != null) {
      final String value = stringValueMapper!(row);
      return EasyTableCell(value: value, textStyle: textStyle);
    } else if (intValueMapper != null) {
      final int value = intValueMapper!(row);
      return EasyTableCell.int(value: value, textStyle: textStyle);
    } else if (doubleValueMapper != null) {
      final double value = doubleValueMapper!(row);
      return EasyTableCell.double(
          value: value, fractionDigits: fractionDigits, textStyle: textStyle);
    } else if (objectValueMapper != null) {
      final Object value = objectValueMapper!(row);
      return EasyTableCell(value: value.toString(), textStyle: textStyle);
    }
    return Container();
  }

  @override
  String toString() {
    return 'EasyTableColumn{name: $name}';
  }
}
