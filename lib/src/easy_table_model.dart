import 'package:easy_table/src/easy_table_column.dart';
import 'package:flutter/widgets.dart';

/// The [EasyTable] model.
///
/// The type [ROW] represents the data of each row.
class EasyTableModel<ROW> extends ChangeNotifier {
  factory EasyTableModel(
      {List<EasyTableColumn<ROW>> columns = const [],
      List<ROW> rows = const []}) {
    EasyTableModel<ROW> model = EasyTableModel._(rows);
    for (EasyTableColumn<ROW> column in columns) {
      model.addColumn(column);
    }
    return model;
  }

  EasyTableModel._(this._rows);

  final List<EasyTableColumn<ROW>> _columns = [];
  final List<ROW> _rows;

  int get columnsLength => _columns.length;

  int get rowsLength => _rows.length;

  bool get isRowsEmpty => _rows.isEmpty;
  bool get isRowsNotEmpty => _rows.isNotEmpty;

  ROW rowAt(int index) => _rows[index];

  void addRow(ROW row) {
    _rows.add(row);
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

  EasyTableColumn<ROW> columnAt(int index) => _columns[index];

  void addColumn(EasyTableColumn<ROW> column) {
    _columns.add(column);
    column.addListener(notifyListeners);
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
}
