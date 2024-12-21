import 'dart:ui';

/// Signature for a custom cell painting function with access to the row data.
///
/// This typedef allows developers to provide a custom rendering function
/// for a cell in the DataGrid. The function receives a [Canvas], [Size],
/// and the row data of type [DATA], enabling full control over the visual
/// representation of the cell.
///
/// - The [Canvas] parameter provides a drawing surface for the cell.
///   Use it to draw shapes, text, images, etc.
/// - The [Size] parameter represents the dimensions of the cell,
///   allowing developers to adapt their drawing to the available space.
/// - The [DATA] parameter represents the row data, allowing developers
///   to use contextual information to customize the cell's visuals.
///
/// Example usage:
/// ```dart
/// CellPainter<MyRowData> customPainter = (Canvas canvas, Size size, MyRowData data) {
///   final Paint paint = Paint()..color = Colors.blue;
///   canvas.drawRect(
///     Rect.fromLTWH(0, 0, size.width, size.height),
///     paint,
///   );
///   // Use `data` to customize the painting
///   if (data.isSelected) {
///     final Paint highlightPaint = Paint()..color = Colors.green;
///     canvas.drawCircle(Offset(size.width / 2, size.height / 2), 10, highlightPaint);
///   }
/// };
/// ```
typedef CellPainter<DATA> = void Function(Canvas canvas, Size size, DATA data);
