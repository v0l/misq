import 'dart:io';

import 'package:flutter_test/flutter_test.dart';
import 'package:flutter/services.dart' show rootBundle;
import 'package:misq_p2p/internal/repository/peers.dart';
import 'package:misq_p2p/internal/repository/seeds.dart';
import 'package:misq_p2p/internal/version.dart';

import 'package:misq_p2p/misq_p2p.dart';
import 'package:misq_p2p/proto_dart/proto/proto_v1.1.7.pbserver.dart';

void main() {
  test('[MAINNET] Test seed node communication', () async {
    final con = BisqConnection(BisqVersion.Mainnet);
    await con.connectTor("5quyxpxheyvzmb2d.onion:8000"); //mainnet seed node

    await for (var msg in con.onMessage) {
      if (msg.response.whichMessage() == NetworkEnvelope_Message.getDataResponse) {
        break; //end test once first getData is received
      }
    }
  }, timeout: Timeout.none);

  test('[REGTEST] Test seed node communication', () async {
    final con = BisqConnection(BisqVersion.Regtest);
    await con.connect(InternetAddress.loopbackIPv4, 2002); //local regtest seed node

    await for (var msg in con.onMessage) {
      if (msg.response.whichMessage() == NetworkEnvelope_Message.getDataResponse) {
        break; //end test once first getData is received
      }
    }
  }, timeout: Timeout.none);

  testSeedRepo();
  testPeerRepo();

  testWidgets('[REGTEST] Test network manager', (w) async {
    final mgr = BisqNetwork(version: BisqVersion.Regtest);
    await mgr.run(rootBundle);

    await mgr.waitForExit; // wait until daemon exits
  }, timeout: Timeout.none);
}

void testSeedRepo() {
  testWidgets('[MAINNET] Test seed repository', (w) async {
    final sr = SeedRepository(BisqVersion.Mainnet, rootBundle);
    await sr.load();
    print(sr.seeds);
  });
  testWidgets('[TESTNET] Test seed repository', (w) async {
    final sr = SeedRepository(BisqVersion.Testnet, rootBundle);
    await sr.load();
    print(sr.seeds);
  });
  testWidgets('[REGTEST] Test seed repository', (w) async {
    final sr = SeedRepository(BisqVersion.Regtest, rootBundle);
    await sr.load();
    print(sr.seeds);
  });
}

void testPeerRepo() {
  testWidgets('[MAINNET] Test peer repository', (w) async {
    final sr = PeerRepository(BisqVersion.Mainnet);
    await sr.load();
  });
  testWidgets('[TESTNET] Test peer repository', (w) async {
    final sr = PeerRepository(BisqVersion.Testnet);
    await sr.load();
  });
  testWidgets('[REGTEST] Test peer repository', (w) async {
    final sr = PeerRepository(BisqVersion.Regtest);
    await sr.load();
  });
}
