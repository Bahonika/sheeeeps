import 'dart:async';
import 'dart:io';
import 'dart:typed_data';

import 'package:yx_scope/yx_scope.dart';

/// Data-layer Service source: the client's WebSocket connection to a host. Raw
/// bytes in and out; the [ClientNetInteractor] handles the protocol. A dropped
/// socket surfaces on [closed] so the UI can show "host disconnected".
class LanClientSource implements AsyncLifecycle {
  WebSocket? _ws;
  StreamSubscription? _wsSub;

  final StreamController<Uint8List> _inbound =
      StreamController<Uint8List>.broadcast();
  final StreamController<void> _closed = StreamController<void>.broadcast();

  Stream<Uint8List> get inbound => _inbound.stream;

  /// Fires once when the connection drops (host quit / network lost).
  Stream<void> get closed => _closed.stream;

  /// Open `ws://[host]:[port]`. Throws on failure (host unreachable / refused).
  Future<void> connect(String host, int port) async {
    final ws = await WebSocket.connect('ws://$host:$port');
    _ws = ws;
    _wsSub = ws.listen(
      (data) {
        if (data is List<int> && !_inbound.isClosed) {
          _inbound.add(Uint8List.fromList(data));
        }
      },
      onDone: _emitClosed,
      onError: (_) => _emitClosed(),
      cancelOnError: true,
    );
  }

  void _emitClosed() {
    if (!_closed.isClosed) _closed.add(null);
  }

  void send(Uint8List bytes) => _ws?.add(bytes);

  Future<void> disconnect() async {
    await _wsSub?.cancel();
    _wsSub = null;
    await _ws?.close();
    _ws = null;
  }

  @override
  Future<void> init() async {}

  @override
  Future<void> dispose() async {
    await disconnect();
    await _inbound.close();
    await _closed.close();
  }
}
