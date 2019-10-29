import 'dart:io';

import 'package:misq_p2p/internal/const.dart';
import 'package:misq_p2p/internal/repository/base.dart';

class PeerAddress extends DBModel with Comparable<PeerAddress> {
  static const String colAddr = "address";
  static const String colConFirst = "first_seen";
  static const String colConLast = "last_seen";

  final String address;
  final int port;
  final String owner;
  final DateTime lastSeen;
  final DateTime firstSeen;

  bool get isTor => address.contains(".onion");
  bool get isIPv4 => RegExp(IPv4Regex).hasMatch(address);
  bool get isIPv6 => RegExp(IPv6Regex).hasMatch(address);
  bool get isDomain => !isInternetAddress && !isTor;
  bool get isInternetAddress => isIPv4 || isIPv6;

  InternetAddress get internetAddress => isInternetAddress ? InternetAddress(address) : null;

  PeerAddress({this.address, this.port, this.owner, this.lastSeen, this.firstSeen});

  /// Trys to parse lines from `seednodes` files
  /// in the format `addr:port (owner)`
  ///
  /// Otherwise returns `null`
  ///
  static PeerAddress tryParseSeed(String line) {
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
        return PeerAddress(
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

  static PeerAddress fromMap(Map<String, dynamic> mp) {
    return PeerAddress(
      address: mp[colAddr],
      lastSeen: DateTime.fromMillisecondsSinceEpoch(mp[colConLast] as int, isUtc: true),
      firstSeen: DateTime.fromMillisecondsSinceEpoch(mp[colConFirst] as int, isUtc: true),
    );
  }

  Map<String, dynamic> toMap() {
    return {
      colAddr: address,
      colConFirst: firstSeen.toUtc().millisecondsSinceEpoch,
      if (lastSeen != null) colConLast: lastSeen?.toUtc()?.millisecondsSinceEpoch
    };
  }

  @override
  int compareTo(PeerAddress other) {
    return other.address.compareTo(address);
  }
}
