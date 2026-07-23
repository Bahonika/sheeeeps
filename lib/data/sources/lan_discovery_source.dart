import 'dart:async';
import 'dart:io';
import 'dart:typed_data';

import 'package:yx_scope/yx_scope.dart';

/// One received UDP datagram plus the sender's IP (the host's LAN address, which
/// the discovery payload deliberately omits).
class DiscoveryDatagram {
  const DiscoveryDatagram(this.senderAddress, this.bytes);
  final String senderAddress;
  final Uint8List bytes;
}

/// Data-layer Service source for LAN room discovery over UDP. A single instance
/// plays one role: a host opens the broadcaster and periodically [sendBroadcast]s
/// its room announcement; a client opens the browser and listens on [datagrams].
/// The [HostNetInteractor] / room-browser interactor own the cadence (timers).
class LanDiscoverySource implements AsyncLifecycle {
  RawDatagramSocket? _socket;
  int _broadcastPort = 0;

  final StreamController<DiscoveryDatagram> _datagrams =
      StreamController<DiscoveryDatagram>.broadcast();

  /// Incoming announcements (client/browser role).
  Stream<DiscoveryDatagram> get datagrams => _datagrams.stream;

  /// Host role: bind an ephemeral socket with broadcast enabled. [port] is the
  /// discovery port announcements are sent to.
  Future<void> openBroadcaster(int port) async {
    final socket = await RawDatagramSocket.bind(InternetAddress.anyIPv4, 0);
    socket.broadcastEnabled = true;
    _socket = socket;
    _broadcastPort = port;
  }

  /// Send one announcement datagram to the LAN broadcast address.
  void sendBroadcast(Uint8List bytes) {
    _socket?.send(bytes, InternetAddress('255.255.255.255'), _broadcastPort);
  }

  /// Client role: bind the discovery [port] and stream incoming datagrams.
  Future<void> openBrowser(int port) async {
    final socket = await RawDatagramSocket.bind(
      InternetAddress.anyIPv4,
      port,
      reuseAddress: true,
    );
    _socket = socket;
    socket.listen((event) {
      if (event != RawSocketEvent.read) return;
      final dg = socket.receive();
      if (dg == null) return;
      _datagrams.add(
        DiscoveryDatagram(dg.address.address, Uint8List.fromList(dg.data)),
      );
    });
  }

  @override
  Future<void> init() async {}

  @override
  Future<void> dispose() async {
    _socket?.close();
    _socket = null;
    await _datagrams.close();
  }
}
