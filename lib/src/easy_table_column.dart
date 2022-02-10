import 'package:easy_table/src/easy_table_cell.dart';
import 'package:easy_table/src/easy_table_cell_builder.dart';
import 'package:easy_table/src/easy_table_header_cell_builder.dart';
import 'package:easy_table/src/theme/easy_table_theme.dart';
import 'package:easy_table/src/theme/easy_table_theme_data.dart';
import 'package:easy_table/src/easy_table_value_mapper.dart';
import 'package:flutter/widgets.dart';

/// The [EasyTable] column.
abstract class EasyTableColumn<ROW> extends ChangeNotifier {
  /// Builds a column by defining the Widget.
  factory EasyTableColumn.builder(EasyTableCellBuilder<ROW> cellBuilder,
      {String? name,
      dynamic id,
      double width = 100,
      EasyTableHeaderCellBuilder? headerCellBuilder =
          HeaderCellBuilders.defaultHeaderCellBuilder}) {
    return _EasyTableColumnBuilder(
        cellBuilder: cellBuilder,
        name: name,
        id: id,
        width: width,
        headerCellBuilder: headerCellBuilder);
  }

  /// Builds a column by mapping the value of a row.
  factory EasyTableColumn.auto(EasyTableValueMapper<ROW> valueMapper,
      {int? fractionDigits,
      dynamic id,
      String? name,
      double width = 100,
      EasyTableHeaderCellBuilder? headerCellBuilder =
          HeaderCellBuilders.defaultHeaderCellBuilder}) {
    return _EasyTableColumnAuto(
        valueMapper: valueMapper,
        id: id,
        name: name,
        width: width,
        fractionDigits: fractionDigits,
        headerCellBuilder: headerCellBuilder);
  }

  EasyTableColumn(
      {this.id, required double width, this.name, this.headerCellBuilder})
      : _width = width;

  final dynamic id;
  final String? name;
  double _width;
  final EasyTableHeaderCellBuilder? headerCellBuilder;

  double get width => _width;
  set width(double value) {
    //TODO negative check
    _width = value;
    notifyListeners();
  }

  Widget? buildCellWidget(BuildContext context, ROW row);
}

class _EasyTableColumnBuilder<ROW> extends EasyTableColumn<ROW> {
  _EasyTableColumnBuilder(
      {required this.cellBuilder,
      dynamic id,
      String? name,
      required double width,
      EasyTableHeaderCellBuilder? headerCellBuilder})
      : super(
            id: id,
            name: name,
            width: width,
            headerCellBuilder: headerCellBuilder);

  final EasyTableCellBuilder<ROW> cellBuilder;

  @override
  Widget? buildCellWidget(BuildContext context, ROW row) {
    return cellBuilder(context, row);
  }
}

class _EasyTableColumnAuto<ROW> extends EasyTableColumn<ROW> {
  _EasyTableColumnAuto(
      {required this.valueMapper,
      dynamic id,
      this.fractionDigits,
      String? name,
      required double width,
      EasyTableHeaderCellBuilder? headerCellBuilder})
      : super(
            id: id,
            name: name,
            width: width,
            headerCellBuilder: headerCellBuilder);

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
