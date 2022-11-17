/// Signature for listening to the last visible row index.
/// Only model lines will be counted.
/// The [EasyTable.lastRowWidget] index will be ignored,
/// for that, use [EasyTable.onLastRowWidget].
typedef OnLastVisibleRowListener = void Function(int? lastVisibleRowIndex);
