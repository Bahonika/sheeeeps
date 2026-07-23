import 'package:flutter/material.dart';

import 'pasture_app.dart';

/// Web entry point (build with `flutter build web -t lib/main_pasture.dart`).
/// The desktop `main.dart` (solo + LAN co-op) is untouched; this target ships the
/// thin online-pasture client only.
void main() {
  runApp(const PastureApp());
}
