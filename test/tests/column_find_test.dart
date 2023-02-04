import 'package:davi/davi.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  group('DaviModel', () {
    test('getColumn', () {
      DaviModel<int> model = DaviModel(rows: [
        1,
        2,
        3
      ], columns: [
        DaviColumn<int>(id: 'id', name: 'name'),
        DaviColumn<int>()
      ]);

      DaviColumn<int>? column = model.getColumn(null);
      expect(column, null);

      column = model.getColumn('cadu');
      expect(column, null);

      column = model.getColumn('id');
      expect(column != null, true);
      expect(column!.name, 'name');
    });
  });
}
