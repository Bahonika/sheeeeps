import 'dart:async';

import 'package:yx_scope/yx_scope.dart';

import '../../data/sources/lan_discovery_source.dart';
import '../../shared/game_config.dart';
import '../models/discovered_room.dart';
import '../net/net_message.dart';
import '../state_managers/browser_state_manager.dart';
import '../state_managers/nav_state_manager.dart';

/// 2nd-order coordinator for the "Join" screen. Listens for UDP room
/// announcements, keeps the [BrowserStateManager] list fresh, prunes rooms whose
/// host went quiet, and starts a client session when the player picks one (or
/// types an address manually).
///
/// Holds only service state (subscription, timers, a monotonic clock).
class RoomBrowserInteractor implements AsyncLifecycle {
  RoomBrowserInteractor({
    required LanDiscoverySource discovery,
    required BrowserStateManager browser,
    required NavStateManager nav,
  })  : _discovery = discovery,
        _browser = browser,
        _nav = nav;

  final LanDiscoverySource _discovery;
  final BrowserStateManager _browser;
  final NavStateManager _nav;

  final Stopwatch _clock = Stopwatch();
  StreamSubscription<DiscoveryDatagram>? _sub;
  Timer? _pruneTimer;

  double get _now => _clock.elapsedMilliseconds / 1000.0;

  @override
  Future<void> init() async {
    _clock.start();
    await _discovery.openBrowser(GameConfig.discoveryPort);
    _sub = _discovery.datagrams.listen(_onDatagram);
    _pruneTimer = Timer.periodic(
      const Duration(seconds: 1),
      (_) => _browser.pruneOlderThan(_now - GameConfig.roomStaleTimeout),
    );
  }

  @override
  Future<void> dispose() async {
    await _sub?.cancel();
    _sub = null;
    _pruneTimer?.cancel();
    _pruneTimer = null;
    _clock.stop();
  }

  void _onDatagram(DiscoveryDatagram dg) {
    final NetMessage msg;
    try {
      msg = NetCodec.decode(dg.bytes);
    } on FormatException {
      return; // stray packet on the discovery port
    }
    if (msg is! RoomAnnounce) return;
    _browser.upsert(DiscoveredRoom(
      host: dg.senderAddress,
      port: msg.port,
      roomName: msg.roomName,
      playerCount: msg.playerCount,
      maxPlayers: msg.maxPlayers,
      lastSeenClock: _now,
    ));
  }

  /// Enter a client session for a discovered room.
  void join(DiscoveredRoom room) => _nav.toClientSession(room.host, room.port);

  /// Enter a client session from a manually typed address.
  void joinManual(String host, int port) => _nav.toClientSession(host, port);

  void backToMenu() => _nav.toMenu();
}
