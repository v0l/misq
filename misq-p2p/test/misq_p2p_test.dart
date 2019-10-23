import 'dart:io';

import 'package:flutter_test/flutter_test.dart';
import 'package:misq_p2p/internal/bisq_version.dart';
import 'package:misq_p2p/internal/repository/seeds.dart';

import 'package:misq_p2p/misq_p2p.dart';
import 'package:misq_p2p/proto_dart/proto/proto_v1.1.7.pbserver.dart';

void main() {
  test('[MAINNET] Test seed node communication', () async {
    final con = BisqConnection(BisqVersion.Mainnet);
    await con.connectTor("5quyxpxheyvzmb2d.onion:8000"); //mainnet seed node

    await for (var msg in con.onMessage) {
      if (msg.whichMessage() == NetworkEnvelope_Message.getDataResponse) {
        break; //end test once first getData is received
      }
    }
  }, timeout: Timeout.none);

  test('[REGTEST] Test seed node communication', () async {
    final con = BisqConnection(BisqVersion.Regtest);
    await con.connect(InternetAddress.loopbackIPv4, 2002); //local regtest seed node

    await for (var msg in con.onMessage) {
      if (msg.whichMessage() == NetworkEnvelope_Message.getDataResponse) {
        break; //end test once first getData is received
      }
    }
  }, timeout: Timeout.none);

  testWidgets('[MAINNET] Test seed repoistory', (w) async {
    print(await SeedRepository(BitcoinNetwork.Mainnet).getSeedNodes());
  });
  testWidgets('[TESTNET] Test seed repoistory', (w) async {
    print(await SeedRepository(BitcoinNetwork.Testnet).getSeedNodes());
  });
  testWidgets('[REGTEST] Test seed repoistory', (w) async {
    print(await SeedRepository(BitcoinNetwork.Regtest).getSeedNodes());
  });

  testWidgets('[REGTEST] Test network manager', (w) async {
    final mgr = BisqNetwork(version: BisqVersion.Regtest);
    await mgr.run();

    await mgr.waitForExit; // wait until daemon exits
  }, timeout: Timeout.none);
}
