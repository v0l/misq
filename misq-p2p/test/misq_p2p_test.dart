import 'dart:io';

import 'package:flutter_test/flutter_test.dart';
import 'package:misq_p2p/internal/bisq_version.dart';

import 'package:misq_p2p/misq_p2p.dart';
import 'package:misq_p2p/proto_dart/proto/proto_v1.1.7.pbserver.dart';

void main() {
  test('Test (mainnet) seed node communication', () async {
    final con = BisqConnection(BisqVersion.Mainnet);
    await con.connectTor("5quyxpxheyvzmb2d.onion:8000"); //mainnet seed node

    await for (var msg in con.onMessage) {
      if (msg.whichMessage() == NetworkEnvelope_Message.getDataResponse) {
        break; //end test once first getData is recieved
      }
    }
  }, timeout: Timeout.none);

  test('Test (regtest) seed node communication', () async {
    final con = BisqConnection(BisqVersion.Regtest);
    await con.connect(InternetAddress.loopbackIPv4, 2002); //local regtest seed node

    await for (var msg in con.onMessage) {
      if (msg.whichMessage() == NetworkEnvelope_Message.getDataResponse) {
        break; //end test once first getData is recieved
      }
    }
  }, timeout: Timeout.none);
}
