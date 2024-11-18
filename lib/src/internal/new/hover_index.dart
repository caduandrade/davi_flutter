import 'package:flutter/material.dart';
import 'package:meta/meta.dart';

@internal
class HoverIndex extends ChangeNotifier {

  bool _enabled = true;

  bool get enabled => _enabled;

  set enabled(bool value) {
    if(_enabled!=value){
      _enabled=value;
      notifyListeners();
    }
  }

  int? _value;

  int? get value => _enabled?_value:null;

  set value(int? value) {
    if (_value != value) {
      print('HoverIndex: $value');
      _value = value;
      notifyListeners();
    }
  }
}
