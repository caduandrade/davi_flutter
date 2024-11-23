import 'package:meta/meta.dart';

@internal
class FifoCache<K, V> {
  final int maxSize;
  final Map<K, V> _map = {};
  final List<K> _order = [];

  FifoCache(this.maxSize);

  void put(K key, V value) {
    if (_map.containsKey(key)) {
      _order.remove(key);
    } else if (_order.length == maxSize) {
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
