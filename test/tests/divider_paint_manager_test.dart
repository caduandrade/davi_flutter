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
    });

    test(
        'verticalSegments - rowIndex: 0, columnIndex: 0, rowSpan: 1, columnSpan: 2',
        () {
      DividerPaintManager manager = DividerPaintManager();
      manager.reset(firstRowIndex: 0, lastRowIndex: 2, columnsLength: 3);

      manager.addStopsForCell(
          rowIndex: 0, columnIndex: 0, rowSpan: 1, columnSpan: 2);

      List<DividerVertex> vertices = manager.allVerticalVerticesFrom(column: 0);
      expect(vertices.length, 5);
      testVertex(vertex: vertices[0], edge: true, index: -1, stop: true);
      testVertex(vertex: vertices[1], edge: false, index: 0, stop: false);
      testVertex(vertex: vertices[2], edge: false, index: 1, stop: false);
      testVertex(vertex: vertices[3], edge: false, index: 2, stop: false);
      testVertex(vertex: vertices[4], edge: true, index: -1, stop: false);

      vertices = manager.allVerticalVerticesFrom(column: 1);
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
          vertex: segments.first.start, edge: false, index: 0, stop: false);
      testVertex(
          vertex: segments.first.end, edge: true, index: -1, stop: false);
    });

    test(
        'verticalSegments - 4x4 rowIndex: 2, columnIndex: 1, rowSpan: 1, columnSpan: 2',
        () {
      DividerPaintManager manager = DividerPaintManager();
      manager.reset(firstRowIndex: 0, lastRowIndex: 3, columnsLength: 4);

      manager.addStopsForCell(
          rowIndex: 2, columnIndex: 1, rowSpan: 1, columnSpan: 2);

      List<DividerVertex> vertices = manager.allVerticalVerticesFrom(column: 0);
      expect(vertices.length, 6);
      testVertex(vertex: vertices[0], edge: true, index: -1, stop: false);
      testVertex(vertex: vertices[1], edge: false, index: 0, stop: false);
      testVertex(vertex: vertices[2], edge: false, index: 1, stop: false);
      testVertex(vertex: vertices[3], edge: false, index: 2, stop: false);
      testVertex(vertex: vertices[4], edge: false, index: 3, stop: false);
      testVertex(vertex: vertices[5], edge: true, index: -1, stop: false);

      vertices = manager.allVerticalVerticesFrom(column: 1);
      expect(vertices.length, 6);
      testVertex(vertex: vertices[0], edge: true, index: -1, stop: false);
      testVertex(vertex: vertices[1], edge: false, index: 0, stop: false);
      testVertex(vertex: vertices[2], edge: false, index: 1, stop: true);
      testVertex(vertex: vertices[3], edge: false, index: 2, stop: false);
      testVertex(vertex: vertices[4], edge: false, index: 3, stop: false);
      testVertex(vertex: vertices[5], edge: true, index: -1, stop: false);

      vertices = manager.allVerticalVerticesFrom(column: 2);
      expect(vertices.length, 6);
      testVertex(vertex: vertices[0], edge: true, index: -1, stop: false);
      testVertex(vertex: vertices[1], edge: false, index: 0, stop: false);
      testVertex(vertex: vertices[2], edge: false, index: 1, stop: false);
      testVertex(vertex: vertices[3], edge: false, index: 2, stop: false);
      testVertex(vertex: vertices[4], edge: false, index: 3, stop: false);
      testVertex(vertex: vertices[5], edge: true, index: -1, stop: false);

      List<DividerSegment> segments =
          manager.verticalSegments(column: 0).toList();
      expect(segments.length, 1);
      testVertex(
          vertex: segments.first.start, edge: true, index: -1, stop: false);
      testVertex(
          vertex: segments.first.end, edge: true, index: -1, stop: false);

      segments = manager.verticalSegments(column: 1).toList();
      expect(segments.length, 2);
      testVertex(
          vertex: segments.first.start, edge: true, index: -1, stop: false);
      testVertex(vertex: segments.first.end, edge: false, index: 1, stop: true);
      testVertex(vertex: segments[1].start, edge: false, index: 2, stop: false);
      testVertex(vertex: segments[1].end, edge: true, index: -1, stop: false);
    });

    test(
        'horizontalSegments - 3x3 rowIndex: 2, columnIndex: 0, rowSpan: 2, columnSpan: 1',
        () {
      DividerPaintManager manager = DividerPaintManager();
      manager.reset(firstRowIndex: 2, lastRowIndex: 3, columnsLength: 3);

      manager.addStopsForCell(
          rowIndex: 2, columnIndex: 0, rowSpan: 2, columnSpan: 1);

      List<DividerVertex> vertices = manager.allHorizontalVerticesFrom(row: 2);
      expect(vertices.length, 5);
      testVertex(vertex: vertices[0], edge: true, index: -1, stop: true);
      testVertex(vertex: vertices[1], edge: false, index: 0, stop: false);
      testVertex(vertex: vertices[2], edge: false, index: 1, stop: false);
      testVertex(vertex: vertices[3], edge: false, index: 2, stop: false);
      testVertex(vertex: vertices[4], edge: true, index: -1, stop: false);

      List<DividerSegment> segments =
          manager.horizontalSegments(row: 2).toList();
      expect(segments.length, 1);
      testVertex(
          vertex: segments.first.start, edge: false, index: 0, stop: false);
      testVertex(
          vertex: segments.first.end, edge: true, index: -1, stop: false);
    });

    test(
        'horizontalSegments - rowIndex: 0, columnIndex: 0, rowSpan: 2, columnSpan: 1',
        () {
      DividerPaintManager manager = DividerPaintManager();
      manager.reset(firstRowIndex: 0, lastRowIndex: 2, columnsLength: 3);

      manager.addStopsForCell(
          rowIndex: 0, columnIndex: 0, rowSpan: 2, columnSpan: 1);

      List<DividerVertex> vertices = manager.allHorizontalVerticesFrom(row: 0);
      expect(vertices.length, 5);
      testVertex(vertex: vertices[0], edge: true, index: -1, stop: true);
      testVertex(vertex: vertices[1], edge: false, index: 0, stop: false);
      testVertex(vertex: vertices[2], edge: false, index: 1, stop: false);
      testVertex(vertex: vertices[3], edge: false, index: 2, stop: false);
      testVertex(vertex: vertices[4], edge: true, index: -1, stop: false);

      vertices = manager.allHorizontalVerticesFrom(row: 1);
      expect(vertices.length, 5);
      testVertex(vertex: vertices[0], edge: true, index: -1, stop: false);
      testVertex(vertex: vertices[1], edge: false, index: 0, stop: false);
      testVertex(vertex: vertices[2], edge: false, index: 1, stop: false);
      testVertex(vertex: vertices[3], edge: false, index: 2, stop: false);
      testVertex(vertex: vertices[4], edge: true, index: -1, stop: false);

      List<DividerSegment> segments =
          manager.horizontalSegments(row: 0).toList();
      expect(segments.length, 1);
      testVertex(
          vertex: segments.first.start, edge: false, index: 0, stop: false);
      testVertex(
          vertex: segments.first.end, edge: true, index: -1, stop: false);
    });

    test(
        'horizontalSegments - rowIndex: 0, columnIndex: 1, rowSpan: 2, columnSpan: 1',
        () {
      DividerPaintManager manager = DividerPaintManager();
      manager.reset(firstRowIndex: 0, lastRowIndex: 2, columnsLength: 3);

      manager.addStopsForCell(
          rowIndex: 0, columnIndex: 1, rowSpan: 2, columnSpan: 1);

      List<DividerVertex> vertices = manager.allHorizontalVerticesFrom(row: 0);
      expect(vertices.length, 5);
      testVertex(vertex: vertices[0], edge: true, index: -1, stop: false);
      testVertex(vertex: vertices[1], edge: false, index: 0, stop: true);
      testVertex(vertex: vertices[2], edge: false, index: 1, stop: false);
      testVertex(vertex: vertices[3], edge: false, index: 2, stop: false);
      testVertex(vertex: vertices[4], edge: true, index: -1, stop: false);

      vertices = manager.allHorizontalVerticesFrom(row: 1);
      expect(vertices.length, 5);
      testVertex(vertex: vertices[0], edge: true, index: -1, stop: false);
      testVertex(vertex: vertices[1], edge: false, index: 0, stop: false);
      testVertex(vertex: vertices[2], edge: false, index: 1, stop: false);
      testVertex(vertex: vertices[3], edge: false, index: 2, stop: false);
      testVertex(vertex: vertices[4], edge: true, index: -1, stop: false);

      List<DividerSegment> segments =
          manager.horizontalSegments(row: 0).toList();
      expect(segments.length, 2);
      testVertex(
          vertex: segments.first.start, edge: true, index: -1, stop: false);
      testVertex(vertex: segments.first.end, edge: false, index: 0, stop: true);
      testVertex(vertex: segments[1].start, edge: false, index: 1, stop: false);
      testVertex(vertex: segments[1].end, edge: true, index: -1, stop: false);
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
