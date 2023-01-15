/// Signature for listening to the last visible row index.
/// Only model lines will be counted.
/// The [Davi.lastRowWidget] index will be ignored,
/// for that, use [Davi.onLastRowWidget].
typedef OnLastVisibleRowListener = void Function(int? lastVisibleRowIndex);
