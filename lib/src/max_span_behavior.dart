/// Defines the behavior when a cell's span exceeds the maximum allowed limits.
///
/// This enum determines how the grid handles scenarios where a cell's
/// `rowSpan` or `columnSpan` surpasses the values of `maxRowSpan` or
/// `maxColumnSpan`. The chosen behavior ensures that the grid remains
/// consistent and performant while giving developers flexibility in
/// handling such cases.
enum MaxSpanBehavior {
  /// Truncates the span to the maximum allowed value and issues a warning
  /// in debug mode. This behavior ensures that the grid remains usable
  /// without throwing exceptions.
  truncateWithWarning,

  /// Throws an exception when a span exceeds the allowed limit.
  /// Use this behavior to strictly enforce span constraints
  /// and identify configuration issues during development.
  throwException,
}
