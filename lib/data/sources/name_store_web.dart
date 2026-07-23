// localStorage is a web-only browser API; this file is only ever compiled for
// the web target (selected by the conditional export in name_store.dart).
// ignore_for_file: deprecated_member_use, avoid_web_libraries_in_flutter
import 'dart:html' as html;

/// Web implementation of [NameStore]: the player's name survives page reloads via
/// browser `localStorage` (TZ Stage 3 entry screen).
class NameStore {
  static const String _key = 'sheeeeps.name';

  String? load() => html.window.localStorage[_key];

  void save(String name) => html.window.localStorage[_key] = name;
}
