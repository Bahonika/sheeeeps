@TestOn('vm')
library;

import 'package:flutter_test/flutter_test.dart';
import 'package:sheeeeps/data/sources/lan_client_source.dart';
import 'package:sheeeeps/data/sources/lan_discovery_source.dart';
import 'package:sheeeeps/data/sources/lan_host_source.dart';
import 'package:sheeeeps/domain/interactors/client_net_interactor.dart';
import 'package:sheeeeps/domain/interactors/game_loop_interactor.dart';
import 'package:sheeeeps/domain/interactors/host_net_interactor.dart';
import 'package:sheeeeps/domain/interactors/input_interactor.dart';
import 'package:sheeeeps/domain/models/player_info.dart';
import 'package:sheeeeps/domain/state/lobby_state.dart';
import 'package:sheeeeps/domain/state_managers/dogs_state_manager.dart';
import 'package:sheeeeps/domain/state_managers/flock_state_manager.dart';
import 'package:sheeeeps/domain/state_managers/game_state_manager.dart';
import 'package:sheeeeps/domain/state_managers/lobby_state_manager.dart';
import 'package:sheeeeps/domain/state_managers/nav_state_manager.dart';

Future<void> _pump([int ms = 40]) =>
    Future<void>.delayed(Duration(milliseconds: ms));

// A port unlikely to clash with a real running room (which uses 7777).
const int _testPort = 7787;

void main() {
  test('full host↔client session: join, start, snapshot mirroring', () async {
    // ── Host side ──────────────────────────────────────────────────────────
    final hostLobby = LobbyStateManager(const LobbyState(
      roomName: 'Комната Хост',
      localPlayerId: 0,
      players: [PlayerInfo(id: 0, name: 'Хост', colorIndex: 0)],
    ));
    final hostDogs = DogsStateManager();
    final hostFlock = FlockStateManager();
    final hostGame = GameStateManager();
    final hostInput = InputInteractor(dogs: hostDogs, flock: hostFlock);
    final hostLoop = GameLoopInteractor(
      dogs: hostDogs,
      flock: hostFlock,
      game: hostGame,
      lobby: hostLobby,
    );
    final hostSource = LanHostSource();
    final announcer = LanDiscoverySource();
    final hostNav = NavStateManager();
    final hostNet = HostNetInteractor(
      host: hostSource,
      announcer: announcer,
      lobby: hostLobby,
      dogs: hostDogs,
      flock: hostFlock,
      game: hostGame,
      input: hostInput,
      loop: hostLoop,
      nav: hostNav,
      gamePort: _testPort,
    );

    // ── Client side ────────────────────────────────────────────────────────
    final clientLobby = LobbyStateManager(const LobbyState(
      roomName: '',
      localPlayerId: -1,
      players: [],
    ));
    final clientDogs = DogsStateManager();
    final clientFlock = FlockStateManager();
    final clientGame = GameStateManager();
    final clientNav = NavStateManager();
    final clientSource = LanClientSource();
    final clientNet = ClientNetInteractor(
      client: clientSource,
      lobby: clientLobby,
      dogs: clientDogs,
      flock: clientFlock,
      game: clientGame,
      nav: clientNav,
      playerName: 'Гость',
      host: '127.0.0.1',
      port: _testPort,
    );

    try {
      await hostNet.init();
      expect(hostSource.boundPort, _testPort, reason: 'host bound the test port');
      await clientNet.init();

      // Handshake + lobby sync.
      for (var i = 0; i < 20 && clientLobby.state.players.length < 2; i++) {
        await _pump();
      }
      expect(hostLobby.state.players.length, 2, reason: 'host saw the joiner');
      expect(clientLobby.state.players.length, 2, reason: 'client got roster');
      expect(clientLobby.state.localPlayerId, greaterThanOrEqualTo(1),
          reason: 'client got an assigned id');

      // Host starts: seeds two dogs and the flock, flips started.
      await hostNet.startGame();
      expect(hostDogs.state.count, 2);
      expect(clientLobby.state.started, isFalse); // not yet propagated
      for (var i = 0; i < 20 && !clientLobby.state.started; i++) {
        await _pump();
      }
      expect(clientLobby.state.started, isTrue);

      // Let snapshots stream and drive client interpolation.
      for (var i = 0; i < 40; i++) {
        clientNet.update(1 / 60);
        await _pump(16);
      }

      expect(clientDogs.state.count, 2, reason: 'client mirrors both dogs');
      expect(clientFlock.state.buffers.count, greaterThan(0),
          reason: 'client mirrors the flock');
      expect(clientGame.state.total, greaterThan(0),
          reason: 'client mirrors the scoreboard');

      // A client move command reaches the host and steers that client's dog.
      final clientId = clientLobby.state.localPlayerId;
      final before = hostDogs.state.byId(clientId)!;
      clientNet.moveTo(before.x + 300, before.y);
      await _pump();
      expect(hostDogs.state.byId(clientId)!.hasTarget, isTrue,
          reason: 'client input drove the host simulation');
    } finally {
      await clientNet.dispose();
      await clientSource.dispose();
      await hostNet.dispose();
      await hostSource.dispose();
      await announcer.dispose();
      await hostLobby.dispose();
      await hostDogs.dispose();
      await hostFlock.dispose();
      await hostGame.dispose();
      await clientLobby.dispose();
      await clientDogs.dispose();
      await clientFlock.dispose();
      await clientGame.dispose();
    }
  });
}
