import 'package:flutter/material.dart';

class RowCursor extends ChangeNotifier {

  MouseCursor _cursor = MouseCursor.defer;

  MouseCursor get cursor =>_cursor;

  set cursor(MouseCursor value) {
    if(_cursor!=value){
      _cursor=value;
      notifyListeners();
    }
  }
}