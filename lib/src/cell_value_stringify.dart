/// A typedef for a function that converts a dynamic value into a String.
///
/// This function is used to convert any dynamic value returned by the `cellValue`
/// function defined for a column into its string representation. The `dynamic value`
/// will never be `null` when passed to this function. If the value for a cell is null,
/// the cell will be rendered without calling this function, and no string conversion will
/// occur (the cell will typically be empty, such as an empty string).
typedef CellValueStringify = String Function(dynamic value);
