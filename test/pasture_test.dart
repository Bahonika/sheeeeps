import 'dart:typed_data';

import 'package:flutter_test/flutter_test.dart';
import 'package:sheeeeps/di/server_scope.dart';
import 'package:sheeeeps/domain/net/net_message.dart';
import 'package:sheeeeps/domain/state/round_state.dart';
import 'package:sheeeeps/domain/state_managers/round_state_manager.dart';
import 'package:sheeeeps/shared/game_config.dart';
import 'package:web_socket_channel/web_socket_channel.dart';

Future<void> _until(bool Function() cond, Duration timeout) async {
  final end = DateTime.now().add(timeout);
  while (!cond()) {
    if (DateTime.now().isAfter(end)) fail('condition not met within $timeout');
    await Future<void>.delayed(const Duration(milliseconds: 20));
  }
}

void main() {
  group('RoundStateManager', () {
    test('runs the round timer, tallies credit, celebrates and records', () async {
      final rm = RoundStateManager();
      await rm.init();

      await rm.startRound(100);
      expect(rm.state, isA<RoundHerding>());
      expect(rm.state.total, 100);

      await rm.tick(1.0, 30);
      expect((rm.state as RoundHerding).elapsed, closeTo(1.0, 1e-9));
      expect(rm.state.penned, 30);

      await rm.credit(5);
      await rm.credit(5);
      await rm.credit(7);
      expect(rm.state.scoreOf(5), 2);
      expect(rm.state.scoreOf(7), 1);

      // The whole flock penned → celebrate; round time = accumulated timer.
      await rm.tick(2.0, 100);
      expect(rm.state, isA<RoundCelebrating>());
      final c = rm.state as RoundCelebrating;
      expect(c.roundTime, closeTo(3.0, 1e-6));
      expect(c.dayRecordSeconds, closeTo(3.0, 1e-6));
      expect(c.remaining, GameConfig.celebrationDuration);
      expect(c.scoreOf(5), 2); // scores carried into the celebration

      // Credit is ignored during the celebration.
      await rm.credit(5);
      expect(rm.state.scoreOf(5), 2);

      // Countdown runs out.
      await rm.tickCelebration(GameConfig.celebrationDuration);
      expect((rm.state as RoundCelebrating).remaining, 0);

      // A fresh round clears scores but keeps the day record.
      await rm.startRound(100);
      expect(rm.state.scoreOf(5), 0);
      expect(rm.state.dayRecordSeconds, closeTo(3.0, 1e-6));

      await rm.dispose();
    });

    test('mirror adopts a server round verbatim (client path)', () async {
      final rm = RoundStateManager();
      await rm.init();
      await rm.mirror(
        phase: 1,
        timer: 42.0,
        penned: 500,
        total: 500,
        scores: {3: 10, 4: 5},
        celebrationRemaining: 6.0,
        dayRecordSeconds: 42.0,
      );
      expect(rm.state, isA<RoundCelebrating>());
      expect(rm.state.scoreOf(3), 10);
      expect((rm.state as RoundCelebrating).remaining, 6.0);
      await rm.dispose();
    });
  });

  group('headless pasture server', () {
    Uint8List toBytes(dynamic d) =>
        d is Uint8List ? d : Uint8List.fromList((d as List).cast<int>());

    test('a client connects, is welcomed and receives a live snapshot', () async {
      final holder = ServerScopeHolder(port: 0);
      await holder.create();
      final port = holder.scope!.socket.boundPort!;

      final ch = WebSocketChannel.connect(Uri.parse('ws://127.0.0.1:$port'));
      await ch.ready;
      final msgs = <NetMessage>[];
      final sub = ch.stream.listen((d) {
        try {
          msgs.add(NetCodec.decode(toBytes(d)));
        } on Object {
          /* ignore */
        }
      });

      ch.sink.add(NetCodec.encode(ClientHello(
        protocolVersion: GameConfig.protocolVersion,
        name: 'Тест-пастух',
      )));

      await _until(
        () => msgs.whereType<HostSnapshot>().isNotEmpty,
        const Duration(seconds: 5),
      );

      final welcome = msgs.whereType<HostWelcome>().toList();
      expect(welcome, isNotEmpty);
      expect(welcome.first.assignedId, greaterThanOrEqualTo(1));

      final snap = msgs.whereType<HostSnapshot>().last.snapshot;
      expect(snap.sheepTotal, GameConfig.pastureSheepCount);
      expect(snap.dogs, isNotEmpty); // the joiner got a dog immediately
      expect(snap.roundPhase, anyOf(0, 1));

      await sub.cancel();
      await ch.sink.close();
      await holder.drop();
    });

    test('a wrong protocol version is politely rejected', () async {
      final holder = ServerScopeHolder(port: 0);
      await holder.create();
      final port = holder.scope!.socket.boundPort!;

      final ch = WebSocketChannel.connect(Uri.parse('ws://127.0.0.1:$port'));
      await ch.ready;
      final msgs = <NetMessage>[];
      final sub = ch.stream.listen((d) {
        try {
          msgs.add(NetCodec.decode(toBytes(d)));
        } on Object {
          /* ignore */
        }
      });

      ch.sink.add(NetCodec.encode(const ClientHello(
        protocolVersion: 999,
        name: 'старьё',
      )));

      await _until(
        () => msgs.whereType<HostReject>().isNotEmpty,
        const Duration(seconds: 4),
      );
      expect(msgs.whereType<HostReject>().first.reason,
          RejectReason.versionMismatch);

      await sub.cancel();
      await ch.sink.close();
      await holder.drop();
    });
  });
}
