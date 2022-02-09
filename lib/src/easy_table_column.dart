import 'package:easy_table/src/easy_table_cell.dart';
import 'package:easy_table/src/easy_table_cell_builder.dart';
import 'package:easy_table/src/easy_table_header_cell_builder.dart';
import 'package:easy_table/src/easy_table_value_mapper.dart';
import 'package:flutter/widgets.dart';

abstract class EasyTableColumn<ROW_VALUE> {
  factory EasyTableColumn.builder(EasyTableCellBuilder<ROW_VALUE> cellBuilder,
      {String? name,
      dynamic id,
      double initialWidth = 100,
      EasyTableHeaderCellBuilder? headerCellBuilder =
          HeaderCellBuilders.defaultHeaderCellBuilder}) {
    return _EasyTableColumnBuilder(
        cellBuilder: cellBuilder,
        name: name,
        id: id,
        initialWidth: initialWidth,
        headerCellBuilder: headerCellBuilder);
  }
  factory EasyTableColumn.auto(EasyTableValueMapper<ROW_VALUE> valueMapper,
      {int? fractionDigits,
      dynamic id,
      String? name,
      double initialWidth = 100,
      EasyTableHeaderCellBuilder? headerCellBuilder =
          HeaderCellBuilders.defaultHeaderCellBuilder}) {
    return _EasyTableColumnAuto(
        valueMapper: valueMapper,
        id: id,
        name: name,
        initialWidth: initialWidth,
        fractionDigits: fractionDigits,
        headerCellBuilder: headerCellBuilder);
  }

  EasyTableColumn(
      {this.id, required this.initialWidth, this.name, this.headerCellBuilder});

  final dynamic id;
  final String? name;
  final double initialWidth;
  final EasyTableHeaderCellBuilder? headerCellBuilder;

  Widget? buildCellWidget(BuildContext context, ROW_VALUE rowValue);
}

class _EasyTableColumnBuilder<ROW_VALUE> extends EasyTableColumn<ROW_VALUE> {
  _EasyTableColumnBuilder(
      {required this.cellBuilder,
      dynamic id,
      String? name,
      required double initialWidth,
      EasyTableHeaderCellBuilder? headerCellBuilder})
      : super(
            id: id,
            name: name,
            initialWidth: initialWidth,
            headerCellBuilder: headerCellBuilder);

  final EasyTableCellBuilder<ROW_VALUE> cellBuilder;

  @override
  Widget? buildCellWidget(BuildContext context, ROW_VALUE rowValue) {
    return cellBuilder(context, rowValue);
  }
}

class _EasyTableColumnAuto<ROW_VALUE> extends EasyTableColumn<ROW_VALUE> {
  _EasyTableColumnAuto(
      {required this.valueMapper,
      dynamic id,
      this.fractionDigits,
      String? name,
      required double initialWidth,
      EasyTableHeaderCellBuilder? headerCellBuilder})
      : super(
            id: id,
            name: name,
            initialWidth: initialWidth,
            headerCellBuilder: headerCellBuilder);

  final EasyTableValueMapper<ROW_VALUE> valueMapper;
  final int? fractionDigits;

  @override
  Widget? buildCellWidget(BuildContext context, ROW_VALUE rowValue) {
    dynamic cellValue = valueMapper(rowValue);
    if (cellValue is String) {
      return EasyTableCell(value: cellValue);
    } else if (cellValue is int) {
      return EasyTableCell.int(value: cellValue);
    } else if (cellValue is double) {
      return EasyTableCell.double(
          value: cellValue, fractionDigits: fractionDigits);
    } else if (cellValue == null) {
      return const EasyTableCell();
    }
    return EasyTableCell(value: cellValue.toString());
  }
}
