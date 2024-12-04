/// Defines the behavior of the grid when a cell collision occurs.
enum CellCollisionBehavior {
  /// Ignores the colliding cell and does not render it.
  ///
  /// This behavior prioritizes the cells that are already rendered,
  /// avoiding visual overlap or redundancy.
  ignore,

  /// Ignores the colliding cell, does not render it,
  /// and logs a warning in debug mode when a collision occurs.
  ///
  /// Useful for debugging while ensuring no overlapping cells are rendered.
  ignoreAndWarn,

  /// Allows all colliding cells to be rendered, resulting in visual overlap.
  ///
  /// This behavior is useful in scenarios where overlapping cells are intentional
  /// or necessary, such as layering multiple data sets.
  overlap,

  /// Allows all colliding cells to be rendered and logs a warning in debug mode
  /// when a collision occurs.
  ///
  /// Useful for scenarios where overlap is intentional but collision events
  /// still need to be monitored for debugging purposes.
  overlapAndWarn,

  /// Throws a [StateError] when a collision is detected.
  ///
  /// This strict behavior ensures that any collision is treated as a critical error,
  /// forcing the developer to resolve it immediately. Use with caution, as it may
  /// disrupt the rendering process.
  strict,
}
