import 'dart:async';
import 'dart:io';
import 'dart:typed_data';

import 'package:yx_scope/yx_scope.dart';

/// One inbound binary frame from a specific client connection.
class HostInbound {
  const HostInbound(this.connectionId, this.bytes);
  final int connectionId;
  final Uint8List bytes;
}

/// Data-layer Service source: the host's in-process WebSocket server. It knows
/// nothing about the game — it accepts connections, surfaces their raw frames
/// tagged by a stable connection id, and sends/broadcasts bytes back. The
/// [HostNetInteractor] maps connections to players and speaks [NetMessage].
///
/// TCP/WebSocket is plenty for LAN co-op (TZ): ordered, reliable, no packet-loss
/// handling to build.
class LanHostSource implements AsyncLifecycle {
  HttpServer? _server;
  final Map<int, WebSocket> _connections = {};
  int _nextConnectionId = 1;

  final StreamController<HostInbound> _inbound =
      StreamController<HostInbound>.broadcast();
  final StreamController<int> _connected = StreamController<int>.broadcast();
  final StreamController<int> _disconnected = StreamController<int>.broadcast();

  /// Frames arriving from any client, tagged with the sender's connection id.
  Stream<HostInbound> get inbound => _inbound.stream;

  /// A new client finished the WebSocket handshake (connection id).
  Stream<int> get connected => _connected.stream;

  /// A client's socket closed (connection id).
  Stream<int> get disconnected => _disconnected.stream;

  /// Bind the server on [port]. Throws (e.g. port in use) — the caller reports it.
  Future<void> start(int port) async {
    final server = await HttpServer.bind(InternetAddress.anyIPv4, port);
    _server = server;
    server.listen(_onRequest);
  }

  Future<void> _onRequest(HttpRequest request) async {
    if (!WebSocketTransformer.isUpgradeRequest(request)) {
      // A plain HTTP GET /health lets a hosting supervisor probe liveness (TZ
      // Stage 3). Everything else that isn't a WebSocket upgrade is refused.
      final res = request.response;
      if (request.method == 'GET' && request.uri.path == '/health') {
        res.statusCode = HttpStatus.ok;
        res.headers.contentType = ContentType.text;
        res.write('ok');
      } else {
        res.statusCode = HttpStatus.forbidden;
      }
      await res.close();
      return;
    }
    final ws = await WebSocketTransformer.upgrade(request);
    final id = _nextConnectionId++;
    _connections[id] = ws;
    if (!_connected.isClosed) _connected.add(id);
    ws.listen(
      (data) {
        if (data is List<int> && !_inbound.isClosed) {
          _inbound.add(HostInbound(id, Uint8List.fromList(data)));
        }
      },
      onDone: () => _drop(id),
      onError: (_) => _drop(id),
      cancelOnError: true,
    );
  }

  void _drop(int id) {
    if (_connections.remove(id) != null && !_disconnected.isClosed) {
      _disconnected.add(id);
    }
  }

  void sendTo(int connectionId, Uint8List bytes) =>
      _connections[connectionId]?.add(bytes);

  void broadcast(Uint8List bytes) {
    for (final ws in _connections.values) {
      ws.add(bytes);
    }
  }

  int get connectionCount => _connections.length;

  /// The actually-bound port (useful when [start] was given port 0 in tests).
  int? get boundPort => _server?.port;

  /// Close one client's socket (e.g. after a reject).
  Future<void> kick(int connectionId) async {
    final ws = _connections.remove(connectionId);
    await ws?.close();
  }

  /// Best-guess LAN IPv4 to show in the lobby for manual entry. Falls back to
  /// the loopback address if no external interface is found.
  static Future<String> resolveLocalIp() async {
    final interfaces = await NetworkInterface.list(
      type: InternetAddressType.IPv4,
      includeLoopback: false,
    );
    for (final ni in interfaces) {
      for (final addr in ni.addresses) {
        if (!addr.isLoopback) return addr.address;
      }
    }
    return InternetAddress.loopbackIPv4.address;
  }

  @override
  Future<void> init() async {}

  @override
  Future<void> dispose() async {
    for (final ws in _connections.values) {
      await ws.close();
    }
    _connections.clear();
    await _server?.close(force: true);
    _server = null;
    await _inbound.close();
    await _connected.close();
    await _disconnected.close();
  }
}
