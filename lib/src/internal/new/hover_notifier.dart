import 'package:flutter/material.dart';
import 'package:meta/meta.dart';

@internal
class HoverNotifier extends ChangeNotifier {

  bool _enabled = true;

  bool get enabled => _enabled;

  set enabled(bool value) {
    if(_enabled!=value){
      _enabled=value;
      if(!_enabled){
        _index=null;
        _cursor = null;
      }
      notifyListeners();
    }
  }

  int? _index;

  int? get index => _enabled?_index:null;

  MouseCursor? _cursor = MouseCursor.defer;

  MouseCursor get cursor {
    if(_enabled && _index != null && _cursor!=null) {
      return _cursor!;
    }
    return MouseCursor.defer;
  }

    set index(int? index) {
      if (_enabled && _index != index) {
        _index = index;
        if(_index==null){
          _cursor=null;
        }
        notifyListeners();
      }
    }

    set cursor(MouseCursor? cursor) {
      if (_enabled && _cursor!=cursor) {
        _cursor=cursor;
        notifyListeners();
      }
  }
  
}
