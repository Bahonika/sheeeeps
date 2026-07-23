/// Pixel-art colour palette as 0xAARRGGBB integers.
///
/// Pure Shared value type: consumed by the Data layer sprite generator (raw RGBA
/// bytes) and by Presentation overlays (`Color(argb)`). No Flutter import so the
/// same constants stay usable from any layer.
class GamePalette {
  GamePalette._();

  // Grass tile — three close greens plus sparse speckles.
  static const int grassBase = 0xFF4E8A3C;
  static const int grassDark = 0xFF437B34;
  static const int grassLight = 0xFF5C9B47;
  static const int grassSpeck = 0xFF6BAE52;

  // Fence / walls — dark posts with a lighter rail.
  static const int fencePost = 0xFF3A2A1C;
  static const int fenceRail = 0xFF5A4632;
  static const int fenceShadow = 0xFF2A1E14;

  // Sheep body variants (2–3 shades) + head/legs.
  static const List<int> sheepBody = <int>[
    0xFFF2EFE6, // cream
    0xFFE8E4D6, // greyish
    0xFFFBFAF4, // near-white
  ];
  static const int sheepShade = 0xFFCFC9B8;
  static const int sheepHead = 0xFF2E2A26;
  static const int sheepLeg = 0xFF3A3630;

  // Dog — dark brown body, black snout, tan tail tip (single-player default).
  static const int dogBody = 0xFF5A3A22;
  static const int dogDark = 0xFF3E2716;
  static const int dogSnout = 0xFF1E1410;
  static const int dogTail = 0xFF6E4A2E;

  /// Multiplayer dog jacket colours — 16 high-contrast hues, one per player (the
  /// pasture holds up to 16 shepherds; LAN co-op uses only the first four). The
  /// sprite body is recoloured procedurally to [dogColors]; the darker rear shade
  /// and lighter tail tip are derived from each ([dogColorsDark]/[dogColorsTail])
  /// so every dog keeps the same shaded, readable silhouette. No artist needed.
  static const List<int> dogColors = <int>[
    0xFF3B74E0, // 0  blue
    0xFFD8433F, // 1  red
    0xFF37A24C, // 2  green
    0xFFE0A324, // 3  amber
    0xFF9B59B6, // 4  purple
    0xFF25B7C4, // 5  cyan
    0xFFE8722C, // 6  orange
    0xFFE86AA6, // 7  pink
    0xFF8CC63F, // 8  lime
    0xFF1FA085, // 9  teal
    0xFF5C6BC0, // 10 indigo
    0xFF9C6B3F, // 11 brown
    0xFFC94FD8, // 12 magenta
    0xFF4FB0F0, // 13 sky
    0xFFB7A521, // 14 olive
    0xFF6E7B8B, // 15 slate
  ];
  static const List<int> dogColorsDark = <int>[
    0xFF244C97, // 0  blue rear
    0xFF8F2A27, // 1  red rear
    0xFF236B31, // 2  green rear
    0xFF977018, // 3  amber rear
    0xFF5D356D, // 4  purple rear
    0xFF166E76, // 5  cyan rear
    0xFF8B441A, // 6  orange rear
    0xFF8B4064, // 7  pink rear
    0xFF547726, // 8  lime rear
    0xFF136050, // 9  teal rear
    0xFF374073, // 10 indigo rear
    0xFF5E4026, // 11 brown rear
    0xFF792F82, // 12 magenta rear
    0xFF2F6A90, // 13 sky rear
    0xFF6E6314, // 14 olive rear
    0xFF424A53, // 15 slate rear
  ];
  static const List<int> dogColorsTail = <int>[
    0xFF6D97EC, // 0  blue tail tip
    0xFFE87A76, // 1  red tail tip
    0xFF6BC07C, // 2  green tail tip
    0xFFEFC96A, // 3  amber tail tip
    0xFFC39BD3, // 4  purple tail tip
    0xFF7CD4DC, // 5  cyan tail tip
    0xFFF1AA80, // 6  orange tail tip
    0xFFF1A6CA, // 7  pink tail tip
    0xFFBADD8C, // 8  lime tail tip
    0xFF79C6B6, // 9  teal tail tip
    0xFF9DA6D9, // 10 indigo tail tip
    0xFFC4A68C, // 11 brown tail tip
    0xFFDF95E8, // 12 magenta tail tip
    0xFF95D0F6, // 13 sky tail tip
    0xFFD4C97A, // 14 olive tail tip
    0xFFA8B0B9, // 15 slate tail tip
  ];

  /// Flutter-side (`Color(argb)`) accessor used by lobby chips and name labels.
  static int dogColor(int index) => dogColors[index % dogColors.length];

  // Bark ring.
  static const int barkRing = 0xFFFFF3B0;

  // Pen-entrance highlight tint (subtle marker on the ground).
  static const int penGlow = 0x33FFE9A8;
}
