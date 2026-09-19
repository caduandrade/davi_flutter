import 'package:davi/src/internal/row_extent_manager.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  group('RowExtentManager - uniform height (ported RowRange scenarios)', () {
    RowExtentManager build() {
      final manager = RowExtentManager();
      manager.resize(
          rowsLength: 100, estimatedHeight: 10, dividerThickness: 0);
      return manager;
    }

    test('Zero height', () {
      final manager = build();
      expect(
          manager.visibleRowCount(scrollOffset: 0, availableHeight: 0), 0);
    });
    test('Negative height', () {
      final manager = build();
      expect(
          manager.visibleRowCount(scrollOffset: 0, availableHeight: -10), 0);
    });
    test('Scenario 1', () {
      final manager = build();
      expect(manager.indexAtOffset(0), 0);
      expect(manager.visibleRowCount(scrollOffset: 0, availableHeight: 30), 3);
    });
    test('Scenario 2', () {
      final manager = build();
      expect(manager.indexAtOffset(1), 0);
      expect(manager.visibleRowCount(scrollOffset: 1, availableHeight: 30), 4);
    });
    test('Scenario 3', () {
      final manager = build();
      expect(manager.indexAtOffset(9), 0);
      expect(manager.visibleRowCount(scrollOffset: 9, availableHeight: 30), 4);
    });
    test('Scenario 4', () {
      final manager = build();
      expect(manager.indexAtOffset(10), 1);
      expect(
          manager.visibleRowCount(scrollOffset: 10, availableHeight: 30), 3);
    });
    test('Scenario 5', () {
      final manager = build();
      expect(manager.indexAtOffset(15), 1);
      expect(
          manager.visibleRowCount(scrollOffset: 15, availableHeight: 30), 4);
    });
    test('Scenario 6', () {
      final manager = build();
      expect(manager.indexAtOffset(20), 2);
      expect(
          manager.visibleRowCount(scrollOffset: 20, availableHeight: 30), 3);
    });
    test('Scenario 7', () {
      final manager = build();
      expect(manager.indexAtOffset(21), 2);
      expect(
          manager.visibleRowCount(scrollOffset: 21, availableHeight: 30), 4);
    });
    test('Scenario 8', () {
      final manager = build();
      expect(manager.indexAtOffset(51), 5);
      expect(
          manager.visibleRowCount(scrollOffset: 51, availableHeight: 30), 4);
    });
    test('Scenario 9', () {
      final manager = build();
      expect(manager.indexAtOffset(59), 5);
      expect(
          manager.visibleRowCount(scrollOffset: 59, availableHeight: 30), 4);
    });
    test('Scenario 10', () {
      final manager = build();
      expect(manager.indexAtOffset(60), 6);
      expect(
          manager.visibleRowCount(scrollOffset: 60, availableHeight: 30), 3);
    });
  });

  group('RowExtentManager - variable height', () {
    test('unmeasured rows use the seed estimate', () {
      final manager = RowExtentManager();
      manager.resize(rowsLength: 5, estimatedHeight: 20, dividerThickness: 5);
      expect(manager.heightOf(2), 20);
      expect(manager.extentOf(2), 25);
      expect(manager.offsetOf(0), 0);
      expect(manager.offsetOf(1), 25);
      expect(manager.offsetOf(2), 50);
      // 5 rows * 25 - one trailing divider not counted.
      expect(manager.totalHeight, 120);
    });

    test('setHeight corrects offsets of every row after it', () {
      final manager = RowExtentManager();
      manager.resize(rowsLength: 4, estimatedHeight: 20, dividerThickness: 0);

      manager.setHeight(1, 60);

      expect(manager.heightOf(0), 20);
      expect(manager.heightOf(1), 60);
      expect(manager.offsetOf(0), 0);
      expect(manager.offsetOf(1), 20);
      expect(manager.offsetOf(2), 80);
      expect(manager.offsetOf(3), 100);
      expect(manager.totalHeight, 120);
      expect(manager.indexAtOffset(79), 1);
      expect(manager.indexAtOffset(80), 2);
    });

    test('setHeight with the same value is a no-op', () {
      final manager = RowExtentManager();
      manager.resize(rowsLength: 3, estimatedHeight: 20, dividerThickness: 0);
      manager.setHeight(0, 20);
      expect(manager.totalHeight, 60);
    });

    test('resize discards previous measurements', () {
      final manager = RowExtentManager();
      manager.resize(rowsLength: 3, estimatedHeight: 20, dividerThickness: 0);
      manager.setHeight(0, 100);
      expect(manager.heightOf(0), 100);

      manager.resize(rowsLength: 3, estimatedHeight: 20, dividerThickness: 0);
      expect(manager.heightOf(0), 20);
    });

    test('visibleRowCount grows a taller measured row correctly', () {
      final manager = RowExtentManager();
      manager.resize(rowsLength: 5, estimatedHeight: 10, dividerThickness: 0);
      manager.setHeight(1, 100);

      // Row 0 (0-10), row 1 (10-110): a 50px viewport starting at 0 only
      // needs rows 0 and 1.
      expect(
          manager.visibleRowCount(scrollOffset: 0, availableHeight: 50), 2);
    });
  });

  group('RowExtentManager - viewportRowCount (conservative, position-stable)',
      () {
    test('matches the old fixed rowHeight formula: ceil(h/rowHeight) + 1',
        () {
      final manager = RowExtentManager();
      manager.resize(
          rowsLength: 20, estimatedHeight: 40, dividerThickness: 10);
      // 200 / 50 = 4 exactly -> +1 cushion row = 5.
      expect(
          manager.viewportRowCount(scrollOffset: 0, availableHeight: 200), 5);
    });

    test('stays the same for any scroll offset within the first row', () {
      final manager = RowExtentManager();
      manager.resize(
          rowsLength: 20, estimatedHeight: 40, dividerThickness: 10);
      final int atZero =
          manager.viewportRowCount(scrollOffset: 0, availableHeight: 200);
      final int mid =
          manager.viewportRowCount(scrollOffset: 5, availableHeight: 200);
      final int nearEnd =
          manager.viewportRowCount(scrollOffset: 49, availableHeight: 200);
      expect(mid, atZero);
      expect(nearEnd, atZero);
    });

    test('changes once the first row actually changes', () {
      final manager = RowExtentManager();
      manager.resize(
          rowsLength: 20, estimatedHeight: 40, dividerThickness: 10);
      // Make row 1 much taller so starting from it (instead of row 0) needs
      // fewer rows to cover the same viewport height.
      manager.setHeight(1, 190);

      final int startingAtRow0 =
          manager.viewportRowCount(scrollOffset: 49, availableHeight: 200);
      final int startingAtRow1 =
          manager.viewportRowCount(scrollOffset: 50, availableHeight: 200);
      expect(startingAtRow1, isNot(startingAtRow0));
    });
  });

  group('RowExtentManager - rows past rowsLength (filler rows)', () {
    test('heightOf/extentOf/offsetOf extrapolate past real data', () {
      final manager = RowExtentManager();
      manager.resize(rowsLength: 2, estimatedHeight: 10, dividerThickness: 5);
      manager.setHeight(0, 40);

      // real rows: 0 (0-40), divider, 1 (45-55).
      expect(manager.offsetOf(2), 60);
      // virtual row 2 uses the seed estimate, not the measured height of 0.
      expect(manager.heightOf(2), 10);
      expect(manager.offsetOf(3), 75); // 60 + (10 + 5)
    });

    test('visibleRowCount fills the viewport past real data', () {
      final manager = RowExtentManager();
      manager.resize(rowsLength: 2, estimatedHeight: 10, dividerThickness: 0);

      // 2 real rows cover 20px; a 45px viewport needs 3 filler rows beyond
      // that (10px each) to be fully covered.
      expect(
          manager.visibleRowCount(scrollOffset: 0, availableHeight: 45), 5);
    });
  });

  group('RowExtentManager - updateGeometry', () {
    test('preserves already-measured rows, only reseeds unmeasured ones', () {
      final manager = RowExtentManager();
      manager.resize(rowsLength: 3, estimatedHeight: 20, dividerThickness: 1);
      manager.setHeight(1, 150); // row 1 is measured; 0 and 2 are not.

      manager.updateGeometry(estimatedHeight: 40, dividerThickness: 10);

      expect(manager.heightOf(0), 40); // unmeasured -> reseeded
      expect(manager.heightOf(1), 150); // measured -> preserved
      expect(manager.heightOf(2), 40); // unmeasured -> reseeded
      // offsets reflect the new dividerThickness (10) between all rows.
      expect(manager.offsetOf(1), 50); // 40 + 10
      expect(manager.offsetOf(2), 210); // 50 + 150 + 10
    });

    test('a measured height matching the old seed exactly is still kept',
        () {
      final manager = RowExtentManager();
      manager.resize(rowsLength: 2, estimatedHeight: 20, dividerThickness: 0);
      // Real content happens to measure to exactly the seed estimate.
      manager.setHeight(0, 20);

      manager.updateGeometry(estimatedHeight: 99, dividerThickness: 0);

      // Row 0 was measured (even though delta was 0), so it must NOT be
      // reseeded to the new, unrelated estimate of 99.
      expect(manager.heightOf(0), 20);
      // Row 1 was never measured, so it does adopt the new estimate.
      expect(manager.heightOf(1), 99);
    });

    test('a no-op call (same values) does not bump generation', () {
      final manager = RowExtentManager();
      manager.resize(rowsLength: 2, estimatedHeight: 20, dividerThickness: 5);
      final int generationAfterResize = manager.generation;

      manager.updateGeometry(estimatedHeight: 20, dividerThickness: 5);

      expect(manager.generation, generationAfterResize);
    });
  });

  group('RowExtentManager - change notifications', () {
    test('resize() and updateGeometry() notify synchronously', () {
      final manager = RowExtentManager();
      int notifications = 0;
      manager.addListener(() => notifications++);

      manager.resize(rowsLength: 2, estimatedHeight: 20, dividerThickness: 0);
      expect(notifications, 1);

      manager.updateGeometry(estimatedHeight: 30, dividerThickness: 0);
      expect(notifications, 2);
    });

    test('setHeight() defers and coalesces notifications to a microtask',
        () async {
      final manager = RowExtentManager();
      manager.resize(rowsLength: 3, estimatedHeight: 20, dividerThickness: 0);
      int notifications = 0;
      manager.addListener(() => notifications++);

      // Several measurements within the same synchronous pass (mirroring
      // CellsLayoutRenderBox's measure pass, called mid-layout) must not
      // notify synchronously (that would trip Flutter's "Build scheduled
      // during frame" guard) and must coalesce into a single notification.
      manager.setHeight(0, 50);
      manager.setHeight(1, 60);
      manager.setHeight(2, 70);
      expect(notifications, 0);

      await Future<void>.delayed(Duration.zero);
      expect(notifications, 1);
    });
  });
}
