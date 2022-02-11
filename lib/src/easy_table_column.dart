import 'package:easy_table/src/easy_table_cell.dart';
import 'package:easy_table/src/easy_table_cell_builder.dart';
import 'package:easy_table/src/easy_table_header_cell_builder.dart';
import 'package:easy_table/src/theme/easy_table_theme.dart';
import 'package:easy_table/src/theme/easy_table_theme_data.dart';
import 'package:easy_table/src/easy_table_value_mapper.dart';
import 'package:flutter/widgets.dart';

typedef SortFunction<ROW> = int Function(ROW a, ROW b);

/// The [EasyTable] column.
abstract class EasyTableColumn<ROW> extends ChangeNotifier {
  /// Builds a column by defining the Widget.
  factory EasyTableColumn.cellBuilder(EasyTableCellBuilder<ROW> cellBuilder,
      {String? name,
      dynamic id,
      double width = 100,
      EasyTableHeaderCellBuilder? headerCellBuilder =
          HeaderCellBuilders.defaultHeaderCellBuilder,
      SortFunction<ROW>? sortFunction}) {
    return _CellBuilder(
        cellBuilder: cellBuilder,
        name: name,
        id: id,
        width: width,
        headerCellBuilder: headerCellBuilder,
        sortFunction: sortFunction);
  }

  /// Builds a column by mapping the value of a row.
  factory EasyTableColumn.valueMapper(EasyTableValueMapper<ROW> valueMapper,
      {int? fractionDigits,
      dynamic id,
      String? name,
      double width = 100,
      EasyTableHeaderCellBuilder? headerCellBuilder =
          HeaderCellBuilders.defaultHeaderCellBuilder,
      SortFunction<ROW>? sortFunction}) {
    return _ValueMapper(
        valueMapper: valueMapper,
        id: id,
        name: name,
        width: width,
        fractionDigits: fractionDigits,
        headerCellBuilder: headerCellBuilder,
        sortFunction: sortFunction);
  }

  EasyTableColumn(
      {this.id,
      required double width,
      this.name,
      this.headerCellBuilder,
      this.sortFunction})
      : _width = width;

  final dynamic id;
  final String? name;
  double _width;
  final EasyTableHeaderCellBuilder? headerCellBuilder;
  final SortFunction<ROW>? sortFunction;

  double get width => _width;
  set width(double value) {
    //TODO negative check
    _width = value;
    notifyListeners();
  }

  Widget? buildCellWidget(BuildContext context, ROW row);

  @override
  String toString() {
    return 'EasyTableColumn{name: $name}';
  }
}

class _CellBuilder<ROW> extends EasyTableColumn<ROW> {
  _CellBuilder(
      {required this.cellBuilder,
      dynamic id,
      String? name,
      required double width,
      EasyTableHeaderCellBuilder? headerCellBuilder,
      SortFunction<ROW>? sortFunction})
      : super(
            id: id,
            name: name,
            width: width,
            headerCellBuilder: headerCellBuilder,
            sortFunction: sortFunction);

  final EasyTableCellBuilder<ROW> cellBuilder;

  @override
  Widget? buildCellWidget(BuildContext context, ROW row) {
    return cellBuilder(context, row);
  }
}

class _ValueMapper<ROW> extends EasyTableColumn<ROW> {
  _ValueMapper(
      {required this.valueMapper,
      dynamic id,
      this.fractionDigits,
      String? name,
      required double width,
      EasyTableHeaderCellBuilder? headerCellBuilder,
      SortFunction<ROW>? sortFunction})
      : super(
            id: id,
            name: name,
            width: width,
            headerCellBuilder: headerCellBuilder,
            sortFunction: sortFunction);

  final EasyTableValueMapper<ROW> valueMapper;
  final int? fractionDigits;

  @override
  Widget? buildCellWidget(BuildContext context, ROW row) {
    dynamic cellValue = valueMapper(row);
    EasyTableThemeData theme = EasyTableTheme.of(context);
    final TextStyle? textStyle = theme.cell.textStyle;
    if (cellValue is String) {
      return EasyTableCell(value: cellValue, textStyle: textStyle);
    } else if (cellValue is int) {
      return EasyTableCell.int(value: cellValue, textStyle: textStyle);
    } else if (cellValue is double) {
      return EasyTableCell.double(
          value: cellValue,
          fractionDigits: fractionDigits,
          textStyle: textStyle);
    } else if (cellValue == null) {
      return EasyTableCell(textStyle: textStyle);
    }
    return EasyTableCell(value: cellValue.toString(), textStyle: textStyle);
  }
}
