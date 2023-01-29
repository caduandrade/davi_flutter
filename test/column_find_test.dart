import 'package:davi/davi.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  group('Model', () {
    test('column find', () {
      DaviModel<int> model = DaviModel(rows: [
        1,
        2,
        3
      ], columns: [
        DaviColumn<int>(id: 'id', name: 'name'),
        DaviColumn<int>()
      ]);

      DaviColumn<int>? column = model.findColumn(null);
      expect(column, null);

      column = model.findColumn('cadu');
      expect(column, null);

      column = model.findColumn('id');
      expect(column != null, true);
      expect(column!.name, 'name');
    });
  });
}
