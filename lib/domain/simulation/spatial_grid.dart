import 'dart:typed_data';

/// Uniform spatial hash over the square world, rebuilt each frame with a
/// counting sort (zero allocation once capacity is stable).
///
/// Replaces the O(n²) neighbour scan the TZ forbids: after [rebuild], the sheep
/// ids sharing a cell are contiguous in [sorted], delimited by [cellStart].
/// Callers iterate a 3×3 block of cells around a query point.
class SpatialGrid {
  final double cellSize;
  final int cols;
  final int rows;

  late Int32List _cellStart; // length cells+1 (prefix offsets into _sorted)
  late Int32List _cellCount; // scratch counts per cell
  late Int32List _sorted; // sheep ids grouped by cell
  int _capacity = 0;

  SpatialGrid({required double worldSize, required this.cellSize})
      : cols = (worldSize / cellSize).ceil(),
        rows = (worldSize / cellSize).ceil() {
    final cells = cols * rows;
    _cellStart = Int32List(cells + 1);
    _cellCount = Int32List(cells);
  }

  int _cellIndex(double x, double y) {
    var cx = (x / cellSize).floor();
    var cy = (y / cellSize).floor();
    if (cx < 0) cx = 0;
    if (cy < 0) cy = 0;
    if (cx >= cols) cx = cols - 1;
    if (cy >= rows) cy = rows - 1;
    return cy * cols + cx;
  }

  /// Bucket [count] agents by cell using a counting sort over (x, y).
  void rebuild(Float32List x, Float32List y, int count) {
    if (count > _capacity) {
      _sorted = Int32List(count);
      _capacity = count;
    }
    final cells = cols * rows;
    for (var c = 0; c < cells; c++) {
      _cellCount[c] = 0;
    }
    for (var i = 0; i < count; i++) {
      _cellCount[_cellIndex(x[i], y[i])]++;
    }
    var acc = 0;
    for (var c = 0; c < cells; c++) {
      _cellStart[c] = acc;
      acc += _cellCount[c];
      _cellCount[c] = _cellStart[c]; // running write cursor
    }
    _cellStart[cells] = acc;
    for (var i = 0; i < count; i++) {
      final c = _cellIndex(x[i], y[i]);
      _sorted[_cellCount[c]++] = i;
    }
  }

  int colOf(double x) {
    final c = (x / cellSize).floor();
    return c < 0 ? 0 : (c >= cols ? cols - 1 : c);
  }

  int rowOf(double y) {
    final r = (y / cellSize).floor();
    return r < 0 ? 0 : (r >= rows ? rows - 1 : r);
  }

  /// Start offset (inclusive) into [sorted] for cell (col, row).
  int startOf(int col, int row) => _cellStart[row * cols + col];

  /// End offset (exclusive) into [sorted] for cell (col, row).
  int endOf(int col, int row) => _cellStart[row * cols + col + 1];

  /// Sheep ids grouped by cell; slice with [startOf]/[endOf].
  Int32List get sorted => _sorted;
}
