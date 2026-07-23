import 'dart:convert';
import 'dart:typed_data';

import '../../shared/game_config.dart';
import '../models/player_info.dart';
import 'world_snapshot.dart';

/// Why a host refused a client. Sent instead of a silent socket drop so the
/// join screen can show a clear reason (TZ: "Версии не совпадают…").
enum RejectReason { versionMismatch, roomFull }

/// A single logical message on the LAN wire. WebSocket already frames messages,
/// so one [NetMessage] maps to one binary frame; the first byte is the type tag.
///
/// Sealed so both the host accept-loop and the client receive-loop can switch
/// exhaustively. Sources speak bytes; interactors speak [NetMessage] via
/// [NetCodec].
sealed class NetMessage {
  const NetMessage();
}

/// Client→host: the very first frame after connecting. Carries the protocol
/// version (checked before anything else) and the chosen display name.
class ClientHello extends NetMessage {
  const ClientHello({required this.protocolVersion, required this.name});
  final int protocolVersion;
  final String name;
}

/// Client→host: move my dog to a world point.
class ClientMove extends NetMessage {
  const ClientMove(this.x, this.y);
  final double x;
  final double y;
}

/// Client→host: my dog barks (host gates on cooldown).
class ClientBark extends NetMessage {
  const ClientBark();
}

/// Host→client: accepted. Assigns the client's stable [assignedId] and colour.
class HostWelcome extends NetMessage {
  const HostWelcome({
    required this.protocolVersion,
    required this.assignedId,
    required this.colorIndex,
    required this.roomName,
  });
  final int protocolVersion;
  final int assignedId;
  final int colorIndex;
  final String roomName;
}

/// Host→client: refused, with a machine-readable [reason].
class HostReject extends NetMessage {
  const HostReject(this.reason);
  final RejectReason reason;
}

/// Host→client: the current lobby roster and whether the match has started.
class HostLobby extends NetMessage {
  const HostLobby({required this.players, required this.started});
  final List<PlayerInfo> players;
  final bool started;
}

/// Host→client: a full world frame.
class HostSnapshot extends NetMessage {
  const HostSnapshot(this.snapshot);
  final WorldSnapshot snapshot;
}

/// UDP broadcast (host→LAN): advertises an open room so clients can auto-discover
/// it. The host's IP is read from the datagram's sender address, not the payload.
class RoomAnnounce extends NetMessage {
  const RoomAnnounce({
    required this.protocolVersion,
    required this.port,
    required this.roomName,
    required this.playerCount,
    required this.maxPlayers,
  });
  final int protocolVersion;
  final int port;
  final String roomName;
  final int playerCount;
  final int maxPlayers;
}

/// Binary (de)serialiser for every [NetMessage]. Little-endian throughout.
/// Positions ride as int16 world pixels (the world is 1000×1000, well inside the
/// int16 range) and each sheep as 5 bytes (x,y,status) — a 300-sheep frame is
/// ~1.5 KB, trivial for LAN at 20 Hz.
class NetCodec {
  NetCodec._();

  // Message type tags.
  static const int _tHello = 1;
  static const int _tMove = 2;
  static const int _tBark = 3;
  static const int _tWelcome = 10;
  static const int _tReject = 11;
  static const int _tLobby = 12;
  static const int _tSnapshot = 20;
  static const int _tAnnounce = 30;

  static Uint8List encode(NetMessage msg) {
    final w = _Writer();
    switch (msg) {
      case ClientHello():
        w.u8(_tHello);
        w.u16(msg.protocolVersion);
        w.str(msg.name);
      case ClientMove():
        w.u8(_tMove);
        w.i16(msg.x.round());
        w.i16(msg.y.round());
      case ClientBark():
        w.u8(_tBark);
      case HostWelcome():
        w.u8(_tWelcome);
        w.u16(msg.protocolVersion);
        w.u8(msg.assignedId);
        w.u8(msg.colorIndex);
        w.str(msg.roomName);
      case HostReject():
        w.u8(_tReject);
        w.u8(msg.reason.index);
      case HostLobby():
        w.u8(_tLobby);
        w.u8(msg.started ? 1 : 0);
        w.u8(msg.players.length);
        for (final p in msg.players) {
          w.u8(p.id);
          w.u8(p.colorIndex);
          w.str(p.name);
        }
      case HostSnapshot():
        w.u8(_tSnapshot);
        _writeSnapshot(w, msg.snapshot);
      case RoomAnnounce():
        w.u8(_tAnnounce);
        w.u16(msg.protocolVersion);
        w.u16(msg.port);
        w.u8(msg.playerCount);
        w.u8(msg.maxPlayers);
        w.str(msg.roomName);
    }
    return w.take();
  }

  static NetMessage decode(Uint8List bytes) {
    final r = _Reader(bytes);
    final type = r.u8();
    switch (type) {
      case _tHello:
        final v = r.u16();
        return ClientHello(protocolVersion: v, name: r.str());
      case _tMove:
        return ClientMove(r.i16().toDouble(), r.i16().toDouble());
      case _tBark:
        return const ClientBark();
      case _tWelcome:
        final v = r.u16();
        final id = r.u8();
        final color = r.u8();
        return HostWelcome(
          protocolVersion: v,
          assignedId: id,
          colorIndex: color,
          roomName: r.str(),
        );
      case _tReject:
        return HostReject(RejectReason.values[r.u8()]);
      case _tLobby:
        final started = r.u8() == 1;
        final n = r.u8();
        final players = <PlayerInfo>[
          for (var i = 0; i < n; i++)
            PlayerInfo(id: r.u8(), colorIndex: r.u8(), name: r.str()),
        ];
        return HostLobby(players: players, started: started);
      case _tSnapshot:
        return HostSnapshot(_readSnapshot(r));
      case _tAnnounce:
        final v = r.u16();
        final port = r.u16();
        final playerCount = r.u8();
        final maxPlayers = r.u8();
        return RoomAnnounce(
          protocolVersion: v,
          port: port,
          playerCount: playerCount,
          maxPlayers: maxPlayers,
          roomName: r.str(),
        );
      default:
        throw FormatException('Unknown net message type $type');
    }
  }

  static void _writeSnapshot(_Writer w, WorldSnapshot s) {
    w.u8(s.won ? 1 : 0);
    w.u8(s.roundPhase);
    w.f32(s.elapsed);
    w.f32(s.celebrationRemaining);
    w.f32(s.dayRecordSeconds);
    w.u16(s.pennedCount);
    w.u8(s.dogs.length);
    for (final d in s.dogs) {
      w.u8(d.id);
      w.u8(d.colorIndex);
      w.i16(d.x.round());
      w.i16(d.y.round());
      w.i16(d.vx.round());
      w.i16(d.vy.round());
      w.u8(_packCooldown(d.barkCooldownRemaining));
      w.u8(d.barkSeq & 0xFF);
      w.u8(d.flags & 0xFF);
      w.u16(d.roundScore);
    }
    w.u16(s.sheepTotal);
    for (var i = 0; i < s.sheepTotal; i++) {
      w.i16(s.sheepX[i].round());
      w.i16(s.sheepY[i].round());
      w.u8(s.sheepStatus[i]);
    }
  }

  // Bark cooldown rides as one byte: fraction of the full cooldown, 0..255.
  static int _packCooldown(double remaining) =>
      (remaining / GameConfig.barkCooldown * 255).round().clamp(0, 255);

  static double _unpackCooldown(int b) =>
      b / 255 * GameConfig.barkCooldown;

  static WorldSnapshot _readSnapshot(_Reader r) {
    final won = r.u8() == 1;
    final roundPhase = r.u8();
    final elapsed = r.f32();
    final celebrationRemaining = r.f32();
    final dayRecordSeconds = r.f32();
    final penned = r.u16();
    final dogCount = r.u8();
    final dogs = <DogSnapshot>[
      for (var i = 0; i < dogCount; i++)
        DogSnapshot(
          id: r.u8(),
          colorIndex: r.u8(),
          x: r.i16().toDouble(),
          y: r.i16().toDouble(),
          vx: r.i16().toDouble(),
          vy: r.i16().toDouble(),
          barkCooldownRemaining: _unpackCooldown(r.u8()),
          barkSeq: r.u8(),
          flags: r.u8(),
          roundScore: r.u16(),
        ),
    ];
    final total = r.u16();
    final sx = Float32List(total);
    final sy = Float32List(total);
    final st = Uint8List(total);
    for (var i = 0; i < total; i++) {
      sx[i] = r.i16().toDouble();
      sy[i] = r.i16().toDouble();
      st[i] = r.u8();
    }
    return WorldSnapshot(
      elapsed: elapsed,
      pennedCount: penned,
      sheepTotal: total,
      won: won,
      dogs: dogs,
      sheepX: sx,
      sheepY: sy,
      sheepStatus: st,
      roundPhase: roundPhase,
      celebrationRemaining: celebrationRemaining,
      dayRecordSeconds: dayRecordSeconds,
    );
  }
}

/// Growable little-endian byte writer. Strings are UTF-8 with a u8 length prefix.
class _Writer {
  // copy: true — `add` must copy each chunk, since the scratch buffer below is
  // reused across writes (copy:false would alias and corrupt earlier segments).
  final BytesBuilder _b = BytesBuilder();
  final ByteData _scratch = ByteData(4);

  void u8(int v) => _b.addByte(v & 0xFF);

  void u16(int v) {
    _scratch.setUint16(0, v, Endian.little);
    _b.add(_scratch.buffer.asUint8List(0, 2));
  }

  void i16(int v) {
    _scratch.setInt16(0, v.clamp(-32768, 32767), Endian.little);
    _b.add(_scratch.buffer.asUint8List(0, 2));
  }

  void f32(double v) {
    _scratch.setFloat32(0, v, Endian.little);
    _b.add(_scratch.buffer.asUint8List(0, 4));
  }

  void str(String s) {
    final bytes = utf8.encode(s);
    final len = bytes.length > 255 ? 255 : bytes.length;
    u8(len);
    _b.add(bytes.sublist(0, len));
  }

  Uint8List take() => _b.toBytes();
}

/// Little-endian byte reader mirroring [_Writer].
class _Reader {
  _Reader(this._bytes) : _data = ByteData.sublistView(_bytes);
  final Uint8List _bytes;
  final ByteData _data;
  int _pos = 0;

  int u8() => _bytes[_pos++];

  int u16() {
    final v = _data.getUint16(_pos, Endian.little);
    _pos += 2;
    return v;
  }

  int i16() {
    final v = _data.getInt16(_pos, Endian.little);
    _pos += 2;
    return v;
  }

  double f32() {
    final v = _data.getFloat32(_pos, Endian.little);
    _pos += 4;
    return v;
  }

  String str() {
    final len = u8();
    final s = utf8.decode(_bytes.sublist(_pos, _pos + len));
    _pos += len;
    return s;
  }
}
