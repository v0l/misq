import 'dart:async';

import 'package:misq_p2p/internal/bisq_version.dart';
import 'package:misq_p2p/internal/repository/seeds.dart';

export 'package:misq_p2p/internal/bisq_version.dart';

/// Manages storage and peer connections
///
class BisqNetwork {
  final BisqVersion version;
  final StreamController _exitStream = StreamController();

  SeedRepository _seedRepo;

  Future get waitForExit => _exitStream.stream.first;

  BisqNetwork({
    this.version,
  });

  Future<void> run() async {
    print("Starting Bisq Network [$version]");

    /// Start by connecting to seed nodes
    /// 
    _seedRepo = SeedRepository(version.network);
    await _seedRepo.getSeedNodes();

    /// Connect to each seed 
    /// 
  }

  void close() {
    _exitStream.add(0);
    _exitStream.close();
  }
}
