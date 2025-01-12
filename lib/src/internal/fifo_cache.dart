import 'package:meta/meta.dart';

@internal
class FifoCache<K, V> {
  FifoCache({int maxSize = 100}) : _maxSize = maxSize > 0 ? maxSize : 1;

  int _maxSize;
  final Map<K, V> _map = {};
  final List<K> _order = [];

  set maxSize(int value) {
    if (value > 0) {
      _maxSize = value;
    }
  }

  void put(K key, V value) {
    if (_map.containsKey(key)) {
      _order.remove(key);
    }

    if (_order.length > _maxSize) {
      var oldestKey = _order.removeAt(0);
      _map.remove(oldestKey);
    }

    _order.add(key);
    _map[key] = value;
  }

  V? get(K key) {
    return _map[key];
  }

  void remove(K key) {
    if (_map.containsKey(key)) {
      _map.remove(key);
      _order.remove(key);
    }
  }
}
