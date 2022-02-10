import 'package:easy_table/src/easy_table_cell_builder.dart';
import 'package:easy_table/src/easy_table_column.dart';
import 'package:easy_table/src/easy_table_header_cell_builder.dart';
import 'package:easy_table/src/easy_table_value_mapper.dart';
import 'package:flutter/widgets.dart';

/// The [EasyTable] model.
///
/// The type [ROW] represents the data of each row.
class EasyTableModel<ROW> extends ChangeNotifier {
  factory EasyTableModel(
      {List<ROW> rows = const [],
      List<EasyTableColumn<ROW>> columns = const []}) {
    EasyTableModel<ROW> model = EasyTableModel._(rows);
    for (EasyTableColumn<ROW> column in columns) {
      model.addColumn(column);
    }
    return model;
  }

  EasyTableModel._(this._rows);

  final List<EasyTableColumn<ROW>> _columns = [];
  final List<ROW> _rows;

  int get rowsLength => _rows.length;
  bool get isRowsEmpty => _rows.isEmpty;
  bool get isRowsNotEmpty => _rows.isNotEmpty;

  ROW rowAt(int index) => _rows[index];

  void addRow(ROW row) {
    _rows.add(row);
    notifyListeners();
  }

  void addRows(List<ROW> rows) {
    _rows.addAll(rows);
    notifyListeners();
  }

  void removeRows() {
    _rows.clear();
    notifyListeners();
  }

  void removeRowAt(int index) {
    _rows.removeAt(index);
    notifyListeners();
  }

  void removeRow(ROW row) {
    _rows.remove(row);
    notifyListeners();
  }

  int get columnsLength => _columns.length;
  bool get isColumnsEmpty => _columns.isEmpty;
  bool get isColumnsNotEmpty => _columns.isNotEmpty;

  EasyTableColumn<ROW> columnAt(int index) => _columns[index];

  void addColumn(EasyTableColumn<ROW> column) {
    _columns.add(column);
    column.addListener(notifyListeners);
    notifyListeners();
  }

  void addColumns(List<EasyTableColumn<ROW>> columns) {
    for (EasyTableColumn<ROW> column in columns) {
      _columns.add(column);
      column.addListener(notifyListeners);
    }
    notifyListeners();
  }

  void removeColumns() {
    _columns.clear();
    notifyListeners();
  }

  void removeColumnAt(int index) {
    _columns.removeAt(index);
    notifyListeners();
  }

  void removeColumn(EasyTableColumn<ROW> column) {
    _columns.remove(column);
    column.removeListener(notifyListeners);
    notifyListeners();
  }

  double get columnsWidth {
    double w = 0;
    for (EasyTableColumn column in _columns) {
      w += column.width;
    }
    return w;
  }

  ColumnAppender<ROW> columnAppender() {
    return ColumnAppender<ROW>._(this);
  }
}

class ColumnAppender<ROW> {
  ColumnAppender._(this._model);

  final EasyTableModel<ROW> _model;

  EasyTableColumn<ROW> valueMapper(EasyTableValueMapper<ROW> valueMapper,
      {int? fractionDigits,
      dynamic id,
      String? name,
      double width = 100,
      EasyTableHeaderCellBuilder? headerCellBuilder =
          HeaderCellBuilders.defaultHeaderCellBuilder}) {
    EasyTableColumn<ROW> column = EasyTableColumn.valueMapper(valueMapper,
        fractionDigits: fractionDigits,
        id: id,
        name: name,
        width: width,
        headerCellBuilder: headerCellBuilder);
    _model.addColumn(column);
    return column;
  }

  EasyTableColumn<ROW> cellBuilder(EasyTableCellBuilder<ROW> cellBuilder,
      {String? name,
      dynamic id,
      double width = 100,
      EasyTableHeaderCellBuilder? headerCellBuilder =
          HeaderCellBuilders.defaultHeaderCellBuilder}) {
    EasyTableColumn<ROW> column = EasyTableColumn.cellBuilder(cellBuilder,
        name: name, id: id, width: width, headerCellBuilder: headerCellBuilder);
    _model.addColumn(column);
    return column;
  }
}
