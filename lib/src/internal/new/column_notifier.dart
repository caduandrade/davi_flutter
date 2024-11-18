

import 'package:flutter/widgets.dart';

class ColumnNotifier extends ChangeNotifier {

  bool _resizing=false;

  bool get resizing => _resizing;

  set resizing(bool value){
    if(_resizing!=value){
      _resizing=value;
      notifyListeners();
    }
  }
}