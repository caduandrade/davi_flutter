import 'dart:ffi';

import 'package:easy_table/easy_table.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {

  EasyTableModel<String> model(){
    return EasyTableModel(columns: [EasyTableColumn(stringValue: (value)=>value)]);
  }

  group('TableLayoutSettings.effectiveVisibleRowsLength', () {
    test('Counter value should be incremented', () {

      DateTime start= DateTime.now();
      EasyTableThemeData t =EasyTableThemeData();
      EasyTableThemeData t2 =EasyTableThemeData(header: HeaderThemeData(visible: false));
      for(int i = 0 ; i < 5000 ;i++){

      }
      int time = DateTime.now().millisecondsSinceEpoch-start.millisecondsSinceEpoch;
      print(time);

      expect(1, 1);
    });

    test('Counter value should be incremented', () {
      expect(1, 1);
    });
  });
}
