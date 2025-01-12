/// Signature for listening to the last visible row index.
/// Only model lines will be counted.
/// The [Davi.trailingWidget] index will be ignored,
/// for that, use [Davi.onTrailingWidget].
typedef LastVisibleRowListener = void Function(int? lastVisibleRowIndex);
