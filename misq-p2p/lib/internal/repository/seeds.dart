import 'dart:io';

import 'package:flutter/services.dart' show rootBundle;
import 'package:misq_p2p/internal/bisq_version.dart';
import 'package:misq_p2p/internal/const.dart';

class SeedAddress {
  final String address;
  final int port;
  final String owner;

  bool get isTor => address.contains(".onion");
  bool get isIPv4 => RegExp(IPv4Regex).hasMatch(address);
  bool get isIPv6 => !isIPv4 && !isTor; // dont want to use IPv6Regex, conputer might explode
  bool get isInternetAddress => isIPv4 || isIPv6;

  InternetAddress get internetAddress => isInternetAddress ? InternetAddress(address) : null;

  SeedAddress({
    this.address,
    this.port,
    this.owner,
  });

  /// Trys to parse lines from `seednodes` files
  /// in the format `addr:port (owner)`
  ///
  /// Otherwise returns `null`
  ///
  static SeedAddress tryParse(String line) {
    String owner;

    var tmpLine = line;
    if (line.contains(" ")) {
      final ownerSplit = line.split(" ");
      tmpLine = ownerSplit[0];
      owner = ownerSplit[1];
      if (owner.startsWith("(")) {
        owner = owner.substring(1, owner.length - 2); //remove parenthesis
      }
    }

    if (tmpLine.contains(":")) {
      final addrSplit = tmpLine.split(":");
      final port = int.tryParse(addrSplit[1]);
      if (port != null && addrSplit[0].isNotEmpty) {
        // Everything seems ok, return object
        return SeedAddress(
          address: addrSplit[0],
          port: port,
          owner: owner,
        );
      }
    }

    // cant figure this one out, return null
    return null;
  }

  String toString() => "$address:$port${owner != null ? " ($owner)" : ""}";
}

/// Seed ndoes files can be found here: https://github.com/bisq-network/bisq/blob/master/core/src/main/resources
///
class SeedRepository {
  final BitcoinNetwork network;
  List<SeedAddress> _seedNodes;

  SeedRepository(this.network);

  Future<List<SeedAddress>> getSeedNodes() async {
    if (_seedNodes == null) {
      final fname = _getSeedNodesAsset(network);
      if (fname != null) {
        final fdata = await rootBundle.loadString("assets/$fname");
        final seedLines = fdata.split("\n");
        _seedNodes = List<SeedAddress>();
        _seedNodes.addAll(seedLines
            .where((a) => a.isNotEmpty && !a.startsWith("#"))
            .map((a) => SeedAddress.tryParse(a.trim()))
            .where((a) => a != null));
      } else {
        throw "Unknown network $network";
      }
    }

    return _seedNodes;
  }

  static String _getSeedNodesAsset(BitcoinNetwork network) {
    if (network == BitcoinNetwork.Mainnet) {
      return "btc_mainnet.seednodes";
    } else if (network == BitcoinNetwork.Testnet) {
      return "btc_testnet.seednodes";
    } else if (network == BitcoinNetwork.Regtest) {
      return "btc_regtest.seednodes";
    }
    return null;
  }
}
