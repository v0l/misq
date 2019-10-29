import 'package:flutter/services.dart';
import 'package:misq_p2p/internal/model/node_address.dart';
import 'package:misq_p2p/internal/repository/base.dart';
import 'package:misq_p2p/internal/version.dart';

/// Seed ndoes files can be found here: https://github.com/bisq-network/bisq/blob/master/core/src/main/resources
///
class SeedRepository extends Repository<PeerAddress> {
  final BisqVersion _version;
  final AssetBundle _bundle;

  List<PeerAddress> _seedNodes;

  List<PeerAddress> get seeds => _seedNodes;

  SeedRepository(this._version, this._bundle);

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

  @override
  Future<void> add(PeerAddress value) async {
    throw "Seed repository cannot be modified";
  }

  @override
  Future<void> remove(PeerAddress value) async {
    throw "Seed repository cannot be modified";
  }

  @override
  Future<void> save() async {
    // Cant be modified
  }

  @override
  Future<void> load() async {
    final fname = _getSeedNodesAsset(_version.network);
    if (fname != null) {
      final fdata = await _bundle.loadString("packages/misq_p2p/data/$fname");
      final seedLines = fdata.split("\n");
      _seedNodes = List<PeerAddress>();
      _seedNodes.addAll(seedLines
          .where((a) => a.isNotEmpty && !a.startsWith("#"))
          .map((a) => PeerAddress.tryParseSeed(a.trim()))
          .where((a) => a != null));
    } else {
      throw "Unknown network ${_version.network}";
    }
  }
}
