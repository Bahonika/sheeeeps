import 'dart:typed_data';

import 'package:flutter_test/flutter_test.dart';
import 'package:sheeeeps/domain/models/player_info.dart';
import 'package:sheeeeps/domain/net/net_message.dart';
import 'package:sheeeeps/domain/net/world_snapshot.dart';

void main() {
  T roundTrip<T extends NetMessage>(NetMessage msg) {
    final decoded = NetCodec.decode(NetCodec.encode(msg));
    expect(decoded, isA<T>());
    return decoded as T;
  }

  group('NetCodec control messages', () {
    test('ClientHello preserves version and name', () {
      final m = roundTrip<ClientHello>(
        const ClientHello(protocolVersion: 7, name: 'Дэн'),
      );
      expect(m.protocolVersion, 7);
      expect(m.name, 'Дэн'); // UTF-8 round-trips
    });

    test('ClientMove rounds coordinates to int16', () {
      final m = roundTrip<ClientMove>(const ClientMove(123.7, 456.2));
      expect(m.x, 124);
      expect(m.y, 456);
    });

    test('ClientBark tag decodes', () {
      roundTrip<ClientBark>(const ClientBark());
    });

    test('HostWelcome carries id/colour/room', () {
      final m = roundTrip<HostWelcome>(const HostWelcome(
        protocolVersion: 1,
        assignedId: 2,
        colorIndex: 3,
        roomName: 'Комната',
      ));
      expect(m.assignedId, 2);
      expect(m.colorIndex, 3);
      expect(m.roomName, 'Комната');
    });

    test('HostReject preserves the reason', () {
      final m = roundTrip<HostReject>(
        const HostReject(RejectReason.versionMismatch),
      );
      expect(m.reason, RejectReason.versionMismatch);
    });

    test('HostLobby preserves the roster and started flag', () {
      final m = roundTrip<HostLobby>(HostLobby(
        started: true,
        players: const [
          PlayerInfo(id: 0, name: 'Хост', colorIndex: 0),
          PlayerInfo(id: 1, name: 'Гость', colorIndex: 1),
        ],
      ));
      expect(m.started, isTrue);
      expect(m.players, hasLength(2));
      expect(m.players[1].name, 'Гость');
      expect(m.players[1].colorIndex, 1);
    });
  });

  group('NetCodec snapshot', () {
    test('a 300-sheep, 4-dog snapshot round-trips within int16 rounding', () {
      const n = 300;
      final sx = Float32List(n);
      final sy = Float32List(n);
      final st = Uint8List(n);
      for (var i = 0; i < n; i++) {
        sx[i] = (i % 1000).toDouble();
        sy[i] = ((i * 3) % 1000).toDouble();
        st[i] = WorldSnapshot.packStatus(i % 3, i % 2);
      }
      final snap = WorldSnapshot(
        elapsed: 42.5,
        pennedCount: 17,
        sheepTotal: n,
        won: false,
        dogs: [
          for (var d = 0; d < 4; d++)
            DogSnapshot(
              id: d,
              colorIndex: d,
              x: 100.0 + d * 50,
              y: 200.0 + d * 10,
              vx: -30.0 * d,
              vy: 12.0 * d,
              barkCooldownRemaining: 0,
              barkSeq: d,
            ),
        ],
        sheepX: sx,
        sheepY: sy,
        sheepStatus: st,
      );

      final bytes = NetCodec.encode(HostSnapshot(snap));
      final decoded = NetCodec.decode(bytes) as HostSnapshot;
      final r = decoded.snapshot;

      expect(r.elapsed, closeTo(42.5, 1e-4));
      expect(r.pennedCount, 17);
      expect(r.won, isFalse);
      expect(r.sheepTotal, n);
      expect(r.dogs, hasLength(4));
      expect(r.dogs[2].x, 200);
      expect(r.dogs[2].vx, -60);
      for (var i = 0; i < n; i++) {
        expect(r.sheepX[i], sx[i]);
        expect(WorldSnapshot.variantOf(r.sheepStatus[i]), i % 3);
        expect(WorldSnapshot.phaseOf(r.sheepStatus[i]), i % 2);
      }

      // Wire size stays modest: header + 4 dogs + 300×5 bytes ≈ 1.5 KB.
      expect(bytes.length, lessThan(2000));
    });

    test('v2 pasture snapshot round-trips round + per-dog score/flags', () {
      const n = 500;
      final sx = Float32List(n);
      final sy = Float32List(n);
      final st = Uint8List(n);
      for (var i = 0; i < n; i++) {
        sx[i] = (i % 1000).toDouble();
        sy[i] = ((i * 7) % 1000).toDouble();
        st[i] = WorldSnapshot.packStatus(i % 3, i % 2);
      }
      final snap = WorldSnapshot(
        elapsed: 88.25,
        pennedCount: 500,
        sheepTotal: n,
        won: true,
        roundPhase: 1,
        celebrationRemaining: 7.5,
        dayRecordSeconds: 61.0,
        dogs: [
          for (var d = 0; d < 16; d++)
            DogSnapshot(
              id: d,
              colorIndex: d,
              x: 50.0 + d,
              y: 60.0 + d,
              vx: 0,
              vy: 0,
              barkCooldownRemaining: 0,
              barkSeq: d,
              flags: d.isEven ? DogSnapshot.flagAsleep : 0,
              roundScore: d * 3,
            ),
        ],
        sheepX: sx,
        sheepY: sy,
        sheepStatus: st,
      );

      final bytes = NetCodec.encode(HostSnapshot(snap));
      final r = (NetCodec.decode(bytes) as HostSnapshot).snapshot;

      expect(r.roundPhase, 1);
      expect(r.celebrationRemaining, closeTo(7.5, 1e-4));
      expect(r.dayRecordSeconds, closeTo(61.0, 1e-4));
      expect(r.dogs, hasLength(16));
      expect(r.dogs[6].roundScore, 18);
      expect(r.dogs[6].isAsleep, isTrue);
      expect(r.dogs[7].isAsleep, isFalse);

      // TZ budget: a full 500-sheep, 16-dog frame must fit in ≈2.5–3 KB.
      expect(bytes.length, lessThan(3072));
    });
  });
}
