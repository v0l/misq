import 'dart:async';
import 'dart:io';
import 'dart:math';

import 'package:logging/logging.dart';
import 'package:misq_p2p/internal/const.dart';
import 'package:misq_p2p/internal/model/node_address.dart';
import 'package:misq_p2p/internal/repository/peers.dart';
import 'package:misq_p2p/internal/repository/seeds.dart';
import 'package:misq_p2p/misq_p2p.dart';
import 'package:misq_p2p/proto_dart/proto/proto_v1.1.7.pb.dart';

enum _PeerDirection { Outbound, Inbound }

class _PeerConnection {
  final BisqConnection connection;
  final DateTime connected;
  final _PeerDirection direction;
  StreamSubscription<PeerMessage> messageHandler;
  int bytesIn;
  int bytesOut;
  double lastPing;

  _PeerConnection({this.connection, this.direction})
      : assert(connection != null, "Connection must not be null"),
        assert(direction != null, "Direction must not be null"),
        connected = DateTime.now();

  String toString() {
    return "[${direction.toString().split(".")[1]}] $connection";
  }
}

class ConnectionManager {
  static const int TargetConnections = 5;

  final Logger log = Logger("ConnectionManager");
  final BisqVersion version;
  final SeedRepository seedRepo;
  final PeerRepository peerRepo;

  final List<_PeerConnection> _peers = List<_PeerConnection>();

  ConnectionManager({
    this.version,
    this.seedRepo,
    this.peerRepo,
  });

  Future<void> start() async {
    /// Pick [TargetConnections] to connect to
    ///
    final peerList = seedRepo.seeds + peerRepo.peers;
    peerList.sort((a, b) {
      final r = Random();
      return r.nextInt(Int32Max).compareTo(r.nextInt(Int32Max));
    });

    final toConnect = peerList.take(TargetConnections);
    toConnect.forEach((a) => tryMakeConnection(a));
  }

  Future<void> tryMakeConnection(PeerAddress addr) async {
    try {
      var newCon = BisqConnection(version);
      await newCon.connectPeer(addr);

      /// if connected, add peer to list and listen for messages
      ///
      final pc = _PeerConnection(connection: newCon, direction: _PeerDirection.Outbound);
      pc.messageHandler = newCon.onMessage.listen((data) {
        pc.bytesIn += data.bytesIn;
        _handlePeerMessage(pc, data);
      });
      _peers.add(pc);
    } on SocketException catch (sex) {
      log.warning("Connection failed to $addr, $sex");
    } on Exception catch (ex) {
      log.warning("Connection failed to $addr, $ex");
    }
  }

  Future<void> _handlePeerMessage(_PeerConnection conn, PeerMessage msg) async {
    log.info("message [${msg.response.whichMessage().toString().split(".")[1]}] from $conn");

    switch (msg.response.whichMessage()) {
      case NetworkEnvelope_Message.preliminaryGetDataRequest:
        // TODO: Handle this case.
        break;
      case NetworkEnvelope_Message.getDataResponse:
        final data = msg.response.getDataResponse;
        for(var payload in data.dataSet) {

        }
        break;
      case NetworkEnvelope_Message.getUpdatedDataRequest:
        // TODO: Handle this case.
        break;
      case NetworkEnvelope_Message.getPeersRequest:
        // TODO: Handle this case.
        break;
      case NetworkEnvelope_Message.getPeersResponse:
        // TODO: Handle this case.
        break;
      case NetworkEnvelope_Message.ping:
        // TODO: Handle this case.
        break;
      case NetworkEnvelope_Message.pong:
        // TODO: Handle this case.
        break;
      case NetworkEnvelope_Message.offerAvailabilityRequest:
        // TODO: Handle this case.
        break;
      case NetworkEnvelope_Message.offerAvailabilityResponse:
        // TODO: Handle this case.
        break;
      case NetworkEnvelope_Message.refreshOfferMessage:
        // TODO: Handle this case.
        break;
      case NetworkEnvelope_Message.addDataMessage:
        // TODO: Handle this case.
        break;
      case NetworkEnvelope_Message.removeDataMessage:
        // TODO: Handle this case.
        break;
      case NetworkEnvelope_Message.removeMailboxDataMessage:
        // TODO: Handle this case.
        break;
      case NetworkEnvelope_Message.closeConnectionMessage:
        // TODO: Handle this case.
        break;
      case NetworkEnvelope_Message.prefixedSealedAndSignedMessage:
        // TODO: Handle this case.
        break;
      case NetworkEnvelope_Message.payDepositRequest:
        // TODO: Handle this case.
        break;
      case NetworkEnvelope_Message.publishDepositTxRequest:
        // TODO: Handle this case.
        break;
      case NetworkEnvelope_Message.depositTxPublishedMessage:
        // TODO: Handle this case.
        break;
      case NetworkEnvelope_Message.counterCurrencyTransferStartedMessage:
        // TODO: Handle this case.
        break;
      case NetworkEnvelope_Message.payoutTxPublishedMessage:
        // TODO: Handle this case.
        break;
      case NetworkEnvelope_Message.openNewDisputeMessage:
        // TODO: Handle this case.
        break;
      case NetworkEnvelope_Message.peerOpenedDisputeMessage:
        // TODO: Handle this case.
        break;
      case NetworkEnvelope_Message.chatMessage:
        // TODO: Handle this case.
        break;
      case NetworkEnvelope_Message.disputeResultMessage:
        // TODO: Handle this case.
        break;
      case NetworkEnvelope_Message.peerPublishedDisputePayoutTxMessage:
        // TODO: Handle this case.
        break;
      case NetworkEnvelope_Message.privateNotificationMessage:
        // TODO: Handle this case.
        break;
      case NetworkEnvelope_Message.getBlocksRequest:
        // TODO: Handle this case.
        break;
      case NetworkEnvelope_Message.getBlocksResponse:
        // TODO: Handle this case.
        break;
      case NetworkEnvelope_Message.newBlockBroadcastMessage:
        // TODO: Handle this case.
        break;
      case NetworkEnvelope_Message.addPersistableNetworkPayloadMessage:
        // TODO: Handle this case.
        break;
      case NetworkEnvelope_Message.ackMessage:
        // TODO: Handle this case.
        break;
      case NetworkEnvelope_Message.republishGovernanceDataRequest:
        // TODO: Handle this case.
        break;
      case NetworkEnvelope_Message.newDaoStateHashMessage:
        // TODO: Handle this case.
        break;
      case NetworkEnvelope_Message.getDaoStateHashesRequest:
        // TODO: Handle this case.
        break;
      case NetworkEnvelope_Message.getDaoStateHashesResponse:
        // TODO: Handle this case.
        break;
      case NetworkEnvelope_Message.newProposalStateHashMessage:
        // TODO: Handle this case.
        break;
      case NetworkEnvelope_Message.getProposalStateHashesRequest:
        // TODO: Handle this case.
        break;
      case NetworkEnvelope_Message.getProposalStateHashesResponse:
        // TODO: Handle this case.
        break;
      case NetworkEnvelope_Message.newBlindVoteStateHashMessage:
        // TODO: Handle this case.
        break;
      case NetworkEnvelope_Message.getBlindVoteStateHashesRequest:
        // TODO: Handle this case.
        break;
      case NetworkEnvelope_Message.getBlindVoteStateHashesResponse:
        // TODO: Handle this case.
        break;
      case NetworkEnvelope_Message.bundleOfEnvelopes:
        // TODO: Handle this case.
        break;
      case NetworkEnvelope_Message.mediatedPayoutTxSignatureMessage:
        // TODO: Handle this case.
        break;
      case NetworkEnvelope_Message.mediatedPayoutTxPublishedMessage:
        // TODO: Handle this case.
        break;
      case NetworkEnvelope_Message.notSet:
        // TODO: Handle this case.
        break;
    }
  }
}
