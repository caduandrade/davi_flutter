import 'package:davi/src/internal/divider_paint_manager.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  group('DividerPaintManager', () {
    test('setup', () {
      DividerPaintManager manager = DividerPaintManager();
      manager.reset(firstRowIndex: 0, lastRowIndex: 2, columnsLength: 3);

      List<DividerVertex> vertices = manager.allVerticalVerticesFrom(column: 0);
      expect(vertices.length, 5);
      testVertex(vertex: vertices[0], edge: true, index: -1, stop: false);
      testVertex(vertex: vertices[1], edge: false, index: 0, stop: false);
      testVertex(vertex: vertices[2], edge: false, index: 1, stop: false);
      testVertex(vertex: vertices[3], edge: false, index: 2, stop: false);
      testVertex(vertex: vertices[4], edge: true, index: -1, stop: false);

      List<DividerSegment> segments =
          manager.verticalSegments(column: 0).toList();
      expect(segments.length, 1);
      testVertex(
          vertex: segments.first.start, edge: true, index: -1, stop: false);
      testVertex(
          vertex: segments.first.end, edge: true, index: -1, stop: false);
    });

    test('addStopsForEntireRow suppresses that row\'s horizontal segments',
        () {
      DividerPaintManager manager = DividerPaintManager();
      manager.reset(firstRowIndex: 0, lastRowIndex: 2, columnsLength: 3);

      manager.addStopsForEntireRow(rowIndex: 1, horizontal: true);

      List<DividerSegment> segments =
          manager.horizontalSegments(row: 1).toList();
      expect(segments, isEmpty);

      // Row 0 is untouched.
      segments = manager.horizontalSegments(row: 0).toList();
      expect(segments.length, 1);
    });
  });
}

void testVertex(
    {required DividerVertex vertex,
    required bool edge,
    required int index,
    required bool stop}) {
  expect(vertex.edge, edge);
  expect(vertex.index, index);
  expect(vertex.stop, stop);
}
