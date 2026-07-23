import 'dart:async';
import 'dart:typed_data';

import 'package:web_socket_channel/web_socket_channel.dart';
import 'package:yx_scope/yx_scope.dart';

/// Data-layer Service source: the pasture client's WebSocket connection to the
/// server. Cross-platform via `web_socket_channel` (dart:io's WebSocket cannot
/// compile for Flutter web), so the exact same client runs in a browser and on
/// the desktop/VM (used by the integration test). Raw bytes in and out; the
/// [PastureClientNetInteractor] speaks the protocol. A dropped socket surfaces on
/// [closed] so the UI can return to the entry screen.
class PastureClientSource implements AsyncLifecycle {
  WebSocketChannel? _channel;
  StreamSubscription<dynamic>? _sub;

  final StreamController<Uint8List> _inbound =
      StreamController<Uint8List>.broadcast();
  final StreamController<void> _closed = StreamController<void>.broadcast();

  Stream<Uint8List> get inbound => _inbound.stream;
  Stream<void> get closed => _closed.stream;

  /// Open [url] (ws:// or wss://). Awaits the handshake; throws if it fails.
  Future<void> connect(String url) async {
    final channel = WebSocketChannel.connect(Uri.parse(url));
    await channel.ready; // throws on connection failure
    _channel = channel;
    _sub = channel.stream.listen(
      (data) {
        if (_inbound.isClosed) return;
        if (data is Uint8List) {
          _inbound.add(data);
        } else if (data is List<int>) {
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

  void send(Uint8List bytes) => _channel?.sink.add(bytes);

  Future<void> disconnect() async {
    await _sub?.cancel();
    _sub = null;
    await _channel?.sink.close();
    _channel = null;
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
