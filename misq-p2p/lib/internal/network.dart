import 'dart:async';

import 'package:logging/logging.dart';
import 'package:misq_p2p/internal/connection_manager.dart';
import 'package:misq_p2p/internal/repository/peers.dart';
import 'package:misq_p2p/internal/repository/seeds.dart';
import 'package:misq_p2p/internal/version.dart';
import 'package:misq_p2p/proto_dart/proto/proto_v1.2.0.pbserver.dart';
import 'package:sqflite/sqflite.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/services.dart';

/// Manages storage and peer connections
///
class BisqNetwork {
  final BisqVersion version;
  final StreamController _exitStream = StreamController();
  final StreamController<NetworkEvent> _eventStream = StreamController.broadcast();
  final Logger log = Logger('BisqNetwork');

  Stream<NetworkEvent> get events => _eventStream.stream;

  SeedRepository _seedRepo;
  PeerRepository _peerRepo;
  ConnectionManager _connManager;

  Future get waitForExit => _exitStream.stream.first;

  BisqNetwork({
    this.version,
  }) {
    Logger.root.level = Level.ALL;
    Logger.root.onRecord.listen((LogRecord rec) {
      print('${rec.level.name}: ${rec.time}: ${rec.message}');
    });
  }

  Future<void> run(AssetBundle bundle) async {
    if (!kReleaseMode) {
      log.info("Enabling SQL debug logging");
      await Sqflite.setDebugModeOn();
    }
    log.info("Starting Bisq Network [$version]");

    /// Load seed repo
    ///
    _seedRepo = SeedRepository(version, bundle);
    await _seedRepo.load();

    log.info("Loaded ${_seedRepo.seeds} seed nodes");

    /// Load peer repo
    ///
    _peerRepo = PeerRepository(version);
    await _peerRepo.load();
    log.info("Loaded ${_peerRepo.peers.length} peers from db");

    /// Start connection manager
    ///
    _connManager = ConnectionManager(
      version: version,
      seedRepo: _seedRepo,
      peerRepo: _peerRepo,
      eventStream: _eventStream,
    );
    await _connManager.start();
  }

  void close() {
    _eventStream.close();
    _exitStream.add(0);
    _exitStream.close();
  }
}

enum NetworkEventType {
  Empty,
  NewPeer,
  TradeNew,
  TradeUpdate,
  TradePeerMessage,

  NetworkReady,
}

abstract class NetworkEvent {
  final NetworkEventType type;

  NetworkEvent({
    this.type,
  });
}

class NewPeerNetworkEvent extends NetworkEvent {
  final int peerCount;
  final PeerConnection newPeer;

  NewPeerNetworkEvent({
    this.newPeer,
    this.peerCount,
  }) : super(type: NetworkEventType.NewPeer);
}

class NetworkReadyNetworkEvent extends NetworkEvent {
  final GetDataResponse response;

  NetworkReadyNetworkEvent({
    this.response,
  }) : super(type: NetworkEventType.NetworkReady);
}
