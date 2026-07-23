import 'dart:async';
import 'dart:math' as math;
import 'dart:typed_data';
import 'dart:ui' as ui;

import 'package:yx_scope/yx_scope.dart'; // for AsyncLifecycle

import '../../shared/aabb.dart';
import '../../shared/game_config.dart';
import '../../shared/game_palette.dart';

/// Data layer: generates every pixel-art sprite in code at startup as
/// `dart:ui` Images — no asset files ship with the game.
///
/// All sprites are raw RGBA buffers (nearest-neighbour, no AA/gradients) blitted
/// into packed atlases. The background is a single [worldSize] x [worldSize]
/// image with grass tiled across it and the fence walls baked on top.
///
/// Everything deterministic: the only randomness (grass speckle) is seeded from
/// [GameConfig.worldSeed], so a restart reproduces the exact same textures.
class SpriteSource implements AsyncLifecycle {
  static const int tile = 16; // each sprite tile is 16x16 px
  static const int directions = 4; // 0=down, 1=up, 2=left, 3=right
  static const int walkFrames = 2; // 2-frame walk cycle

  late final ui.Image _sheepAtlas;
  late final List<ui.Image> _dogAtlases;
  late final ui.Image _background;

  ui.Image get sheepAtlas => _sheepAtlas;
  ui.Image get background => _background;

  /// Dog atlas recoloured for palette [colorIndex] (0..dogColorCount-1). Every
  /// dog picks its atlas by its player colour — the sprite is generated per hue,
  /// so no runtime tinting and no artist are needed.
  ui.Image dogAtlas(int colorIndex) =>
      _dogAtlases[colorIndex % _dogAtlases.length];

  @override
  Future<void> init() async {
    _sheepAtlas = await _buildSheepAtlas();
    _dogAtlases = [
      for (var c = 0; c < GameConfig.dogColorCount; c++)
        await _buildDogAtlas(c),
    ];
    _background = await _buildBackground();
  }

  @override
  Future<void> dispose() async {
    _sheepAtlas.dispose();
    for (final a in _dogAtlases) {
      a.dispose();
    }
    _background.dispose();
  }

  // ── Source rects ───────────────────────────────────────────────────────────

  ui.Rect sheepRect(int variant, int dir, int frame) => ui.Rect.fromLTWH(
        (dir * walkFrames + frame) * tile.toDouble(),
        variant * tile.toDouble(),
        tile.toDouble(),
        tile.toDouble(),
      );

  ui.Rect dogRect(int dir, int frame) => ui.Rect.fromLTWH(
        (dir * walkFrames + frame) * tile.toDouble(),
        0,
        tile.toDouble(),
        tile.toDouble(),
      );

  // ── Atlas builders ─────────────────────────────────────────────────────────

  Future<ui.Image> _buildSheepAtlas() {
    const cols = directions * walkFrames; // 8
    final w = cols * tile; // 128
    final h = GameConfig.sheepVariants * tile; // 48
    final atlas = Uint8List(w * h * 4);

    for (var v = 0; v < GameConfig.sheepVariants; v++) {
      for (var d = 0; d < directions; d++) {
        for (var f = 0; f < walkFrames; f++) {
          final t = _sheepTile(v, d, f);
          _blit(atlas, w, t, (d * walkFrames + f) * tile, v * tile);
        }
      }
    }
    return _imageFromPixels(atlas, w, h);
  }

  Future<ui.Image> _buildDogAtlas(int colorIndex) {
    const cols = directions * walkFrames; // 8
    final w = cols * tile; // 128
    const h = tile; // 16
    final atlas = Uint8List(w * h * 4);

    final body = GamePalette.dogColors[colorIndex];
    final dark = GamePalette.dogColorsDark[colorIndex];
    final tail = GamePalette.dogColorsTail[colorIndex];

    for (var d = 0; d < directions; d++) {
      for (var f = 0; f < walkFrames; f++) {
        final t = _dogTile(d, f, body: body, dark: dark, tail: tail);
        _blit(atlas, w, t, (d * walkFrames + f) * tile, 0);
      }
    }
    return _imageFromPixels(atlas, w, h);
  }

  // ── Sheep tile ─────────────────────────────────────────────────────────────

  Uint8List _sheepTile(int variant, int dir, int frame) {
    final t = Uint8List(tile * tile * 4);
    final body = GamePalette.sheepBody[variant];

    // Oval body ~10 wide x 8 tall, centred in the tile. Lower half darker.
    const cx = 7.5;
    const cy = 7.5;
    const rx = 5.0;
    const ry = 4.0;
    for (var y = 0; y < tile; y++) {
      for (var x = 0; x < tile; x++) {
        final dx = (x - cx) / rx;
        final dy = (y - cy) / ry;
        if (dx * dx + dy * dy <= 1.0) {
          _px(t, x, y, y >= 8 ? GamePalette.sheepShade : body);
        }
      }
    }

    // Dark head nub (2-3 px) at the front edge for this direction.
    for (final p in _headPixels(dir)) {
      _px(t, p[0], p[1], GamePalette.sheepHead);
    }

    // Four legs near the body base; two of them step per frame.
    _legs(t, GamePalette.sheepLeg, frame, baseY: 11);

    return t;
  }

  // ── Dog tile ───────────────────────────────────────────────────────────────

  Uint8List _dogTile(
    int dir,
    int frame, {
    required int body,
    required int dark,
    required int tail,
  }) {
    final t = Uint8List(tile * tile * 4);

    // Longer body: elongated along the facing axis (fills more of the tile).
    final vertical = dir == 0 || dir == 1;
    final rx = vertical ? 4.0 : 6.0;
    final ry = vertical ? 6.0 : 4.0;
    const cx = 7.5;
    const cy = 7.5;
    for (var y = 0; y < tile; y++) {
      for (var x = 0; x < tile; x++) {
        final dx = (x - cx) / rx;
        final dy = (y - cy) / ry;
        if (dx * dx + dy * dy <= 1.0) {
          _px(t, x, y, _dogRear(dir, x, y) ? dark : body);
        }
      }
    }

    // Snout at the front (always near-black for readability), tail nub at back.
    for (final p in _dogSnoutPixels(dir)) {
      _px(t, p[0], p[1], GamePalette.dogSnout);
    }
    for (final p in _dogTailPixels(dir)) {
      _px(t, p[0], p[1], tail);
    }

    _legs(t, dark, frame, baseY: 12);

    return t;
  }

  /// True for the rear half of the dog relative to its facing direction, so the
  /// darker shade reads as depth behind the head.
  bool _dogRear(int dir, int x, int y) {
    switch (dir) {
      case 0: // facing down → rear is top
        return y < 7.5;
      case 1: // facing up → rear is bottom
        return y > 7.5;
      case 2: // facing left → rear is right
        return x > 7.5;
      default: // facing right → rear is left
        return x < 7.5;
    }
  }

  // ── Shared tile helpers ──────────────────────────────────────────────────────

  /// Four leg pixels along the body base; indices {0,2} step down on frame 0 and
  /// {1,3} step down on frame 1, so the two frames differ visibly.
  void _legs(Uint8List t, int color, int frame, {required int baseY}) {
    const xs = <int>[4, 6, 9, 11];
    for (var i = 0; i < xs.length; i++) {
      _px(t, xs[i], baseY, color);
      final stepped = frame == 0 ? i.isEven : i.isOdd;
      _px(t, xs[i], baseY + (stepped ? 2 : 1), color);
    }
  }

  List<List<int>> _headPixels(int dir) {
    switch (dir) {
      case 0: // down → bottom
        return const <List<int>>[[7, 12], [8, 12], [8, 13]];
      case 1: // up → top
        return const <List<int>>[[7, 3], [8, 3], [8, 2]];
      case 2: // left → left
        return const <List<int>>[[3, 7], [3, 8], [2, 8]];
      default: // right → right
        return const <List<int>>[[12, 7], [12, 8], [13, 8]];
    }
  }

  List<List<int>> _dogSnoutPixels(int dir) {
    switch (dir) {
      case 0: // down
        return const <List<int>>[[7, 14], [8, 14], [8, 13]];
      case 1: // up
        return const <List<int>>[[7, 1], [8, 1], [8, 2]];
      case 2: // left
        return const <List<int>>[[1, 7], [1, 8], [2, 8]];
      default: // right
        return const <List<int>>[[14, 7], [14, 8], [13, 8]];
    }
  }

  List<List<int>> _dogTailPixels(int dir) {
    switch (dir) {
      case 0: // down → tail at top
        return const <List<int>>[[7, 1], [8, 1]];
      case 1: // up → tail at bottom
        return const <List<int>>[[7, 14], [8, 14]];
      case 2: // left → tail at right
        return const <List<int>>[[14, 7], [14, 8]];
      default: // right → tail at left
        return const <List<int>>[[1, 7], [1, 8]];
    }
  }

  // ── Background ───────────────────────────────────────────────────────────────

  Future<ui.Image> _buildBackground() {
    final size = GameConfig.worldSize.toInt();

    // Deterministic 16x16 grass tile.
    final grass = _grassTile();

    // Tile the grass across the whole world (opaque everywhere).
    final bg = Uint8List(size * size * 4);
    for (var y = 0; y < size; y++) {
      final gy = y % tile;
      for (var x = 0; x < size; x++) {
        final gx = x % tile;
        final si = (gy * tile + gx) * 4;
        final di = (y * size + x) * 4;
        bg[di] = grass[si];
        bg[di + 1] = grass[si + 1];
        bg[di + 2] = grass[si + 2];
        bg[di + 3] = grass[si + 3];
      }
    }

    // Bake the fence walls on top.
    for (final wall in GameConfig.buildWalls()) {
      _bakeFence(bg, size, wall);
    }

    return _imageFromPixels(bg, size, size);
  }

  Uint8List _grassTile() {
    final t = Uint8List(tile * tile * 4);
    for (var y = 0; y < tile; y++) {
      for (var x = 0; x < tile; x++) {
        _px(t, x, y, GamePalette.grassBase);
      }
    }

    // Deterministic speckle — seeded so restarts reproduce the exact texture.
    final rnd = math.Random(GameConfig.worldSeed);
    void scatter(int count, int color) {
      for (var i = 0; i < count; i++) {
        _px(t, rnd.nextInt(tile), rnd.nextInt(tile), color);
      }
    }

    scatter(6, GamePalette.grassDark);
    scatter(6, GamePalette.grassLight);
    scatter(8, GamePalette.grassSpeck);
    return t;
  }

  /// Draws a readable dark fence over [wall]: a rail base, repeating posts along
  /// the wall's long axis, and a shadow line on the far edges.
  void _bakeFence(Uint8List bg, int size, Aabb wall) {
    final l = wall.left.round().clamp(0, size).toInt();
    final t = wall.top.round().clamp(0, size).toInt();
    final r = wall.right.round().clamp(0, size).toInt();
    final b = wall.bottom.round().clamp(0, size).toInt();
    final horizontal = (r - l) >= (b - t);

    for (var y = t; y < b; y++) {
      for (var x = l; x < r; x++) {
        var color = GamePalette.fenceRail;
        // Posts repeat every 10 px along the long axis (3 px wide).
        if (horizontal) {
          if ((x - l) % 10 < 3) color = GamePalette.fencePost;
        } else {
          if ((y - t) % 10 < 3) color = GamePalette.fencePost;
        }
        // Shadow line on the far (bottom/right) edges.
        if (x >= r - 2 || y >= b - 2) color = GamePalette.fenceShadow;

        final di = (y * size + x) * 4;
        bg[di] = (color >> 16) & 0xFF;
        bg[di + 1] = (color >> 8) & 0xFF;
        bg[di + 2] = color & 0xFF;
        bg[di + 3] = (color >> 24) & 0xFF;
      }
    }
  }

  // ── Raw-pixel primitives ─────────────────────────────────────────────────────

  /// Sets one RGBA pixel in a 16x16 tile buffer. `argb` is 0xAARRGGBB; bytes are
  /// written R,G,B,A. Out-of-bounds writes are ignored.
  void _px(Uint8List t, int x, int y, int argb) {
    if (x < 0 || x >= tile || y < 0 || y >= tile) return;
    final i = (y * tile + x) * 4;
    t[i] = (argb >> 16) & 0xFF;
    t[i + 1] = (argb >> 8) & 0xFF;
    t[i + 2] = argb & 0xFF;
    t[i + 3] = (argb >> 24) & 0xFF;
  }

  /// Copies a 16x16 tile buffer into [dst] (width [dstW]) at (ox, oy).
  void _blit(Uint8List dst, int dstW, Uint8List t, int ox, int oy) {
    for (var y = 0; y < tile; y++) {
      for (var x = 0; x < tile; x++) {
        final si = (y * tile + x) * 4;
        final di = ((oy + y) * dstW + (ox + x)) * 4;
        dst[di] = t[si];
        dst[di + 1] = t[si + 1];
        dst[di + 2] = t[si + 2];
        dst[di + 3] = t[si + 3];
      }
    }
  }

  Future<ui.Image> _imageFromPixels(Uint8List rgba, int w, int h) {
    final c = Completer<ui.Image>();
    ui.decodeImageFromPixels(rgba, w, h, ui.PixelFormat.rgba8888, c.complete);
    return c.future;
  }
}
