// Data-layer Storage source: persists the player's chosen name across sessions.
//
// Conditional export — on the web it reads/writes `localStorage` (TZ Stage 3);
// on the VM/desktop it is a no-op stub, so `dart:html` never enters a non-web
// compile. The class surface is identical either way.
export 'name_store_stub.dart' if (dart.library.html) 'name_store_web.dart';
