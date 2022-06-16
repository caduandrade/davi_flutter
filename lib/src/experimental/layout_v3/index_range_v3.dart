class IndexRangeV3 {

  IndexRangeV3({required this.first,required this.last});

  final int first;
  final int last;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is IndexRangeV3 &&
          runtimeType == other.runtimeType &&
          first == other.first &&
          last == other.last;

  @override
  int get hashCode => first.hashCode ^ last.hashCode;

  @override
  String toString() {
    return 'IndexRangeV3{first: $first, last: $last}';
  }
}