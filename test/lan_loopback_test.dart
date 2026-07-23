@TestOn('vm')
library;

import 'dart:async';
import 'dart:typed_data';

import 'package:flutter_test/flutter_test.dart';
import 'package:sheeeeps/data/sources/lan_client_source.dart';
import 'package:sheeeeps/data/sources/lan_host_source.dart';
import 'package:sheeeeps/domain/net/net_message.dart';

/// End-to-end over a real loopback WebSocket: the host binds, the client
/// connects, and a full hello→welcome handshake round-trips through the actual
/// [NetCodec] and sockets — the plumbing the GUI can't be smoke-tested here.
void main() {
  test('client↔host handshake over a live WebSocket', () async {
    final host = LanHostSource();
    final client = LanClientSource();
    addTearDown(() async {
      await client.dispose();
      await host.dispose();
    });

    await host.start(0); // ephemeral port
    final port = host.boundPort!;
    expect(port, greaterThan(0));

    // Host: on the first client frame, expect a hello and reply with a welcome.
    final hostGotHello = Completer<ClientHello>();
    host.inbound.listen((frame) {
      final msg = NetCodec.decode(frame.bytes);
      if (msg is ClientHello) {
        hostGotHello.complete(msg);
        host.sendTo(
          frame.connectionId,
          NetCodec.encode(const HostWelcome(
            protocolVersion: 1,
            assignedId: 1,
            colorIndex: 1,
            roomName: 'Тест',
          )),
        );
      }
    });

    // Client: capture the first inbound frame.
    final clientGotWelcome = Completer<Uint8List>();
    await client.connect('127.0.0.1', port);
    client.inbound.listen(clientGotWelcome.complete);

    client.send(NetCodec.encode(
      const ClientHello(protocolVersion: 1, name: 'Гость'),
    ));

    final hello = await hostGotHello.future.timeout(const Duration(seconds: 5));
    expect(hello.name, 'Гость');
    expect(host.connectionCount, 1);

    final welcomeBytes =
        await clientGotWelcome.future.timeout(const Duration(seconds: 5));
    final welcome = NetCodec.decode(welcomeBytes);
    expect(welcome, isA<HostWelcome>());
    expect((welcome as HostWelcome).assignedId, 1);
    expect(welcome.roomName, 'Тест');
  });

  test('a dropped client surfaces on the host disconnect stream', () async {
    final host = LanHostSource();
    final client = LanClientSource();
    addTearDown(() async => host.dispose());

    await host.start(0);
    final disconnected = Completer<int>();
    host.disconnected.listen(disconnected.complete);

    await client.connect('127.0.0.1', host.boundPort!);
    // Give the server a tick to register the connection, then drop it.
    await Future<void>.delayed(const Duration(milliseconds: 50));
    await client.dispose();

    final id = await disconnected.future.timeout(const Duration(seconds: 5));
    expect(id, greaterThan(0));
  });
}
