import 'dart:async';
import 'dart:io';
import 'dart:typed_data';

import 'package:logging/logging.dart';
import 'package:misq_p2p/internal/bisq_capability.dart';
import 'package:misq_p2p/internal/const.dart';
import 'package:misq_p2p/internal/model/node_address.dart';
import 'package:misq_p2p/internal/version.dart';
import 'package:misq_p2p/proto_dart/proto/proto_v1.1.7.pb.dart';
import 'package:protobuf/protobuf.dart';
import 'package:socks5/socks5.dart';

class PeerMessage {
  final NetworkEnvelope request;
  final NetworkEnvelope response;
  final BisqConnection connection;
  final int bytesIn;

  PeerMessage({
    this.request,
    this.response,
    this.connection,
    this.bytesIn,
  });
}

/// Creates an outbound peer connection
///
/// Can open connections via tor if its running on the default port 9050
///
class BisqConnection {
  BisqVersion _version;
  SOCKSSocket _torSocket;
  RawSocket _rawSocket;
  StreamSubscription<RawSocketEvent> _rawSub;

  final Logger log = Logger("BisqConnection");
  final StreamController<PeerMessage> _messageStream = StreamController<PeerMessage>();
  final Map<int, NetworkEnvelope> _pendingRequests = Map<int, NetworkEnvelope>();

  Stream<PeerMessage> get onMessage => _messageStream.stream;

  Uint8List _buffer = Uint8List(MaxMessageSize);
  int _bufferOffset = 0;
  int _bufferTarget;
  int _nonce = 1;

  RawSocket get _socket => _rawSocket;
  int get nonce => _nonce++;

  BisqConnection(this._version);

  Future<void> connect(InternetAddress ip, [int port = 9999]) async {
    log.info("Connecting to ${ip.host}:$port");

    _rawSocket = await RawSocket.connect(ip, port);
    _rawSub = _rawSocket.listen(_onData);

    _startConnection();
  }

  Future<void> connectTor(String host) async {
    log.info("Connecting to $host");

    _rawSocket = await RawSocket.connect(InternetAddress.loopbackIPv4, 9050);
    _torSocket = SOCKSSocket(_rawSocket);
    await _torSocket.connect(host);
    _rawSub = _torSocket.subscription;
    _rawSub.onData(_onData); //set onData handler to our handler function

    _startConnection();
  }

  Future<void> connectPeer(PeerAddress addr) async {
    if (addr.isTor) {
      await connectTor("${addr.address}:${addr.port}");
    } else if (addr.isDomain) {
      final addrList = await InternetAddress.lookup(addr.address);
      if (addrList.length > 0) {
        await connect(addrList.first, addr.port);
      } else {
        throw "Hostname lookup failed for $addr";
      }
    } else {
      await connect(addr.internetAddress, addr.port);
    }
  }

  void close() {
    _messageStream.close();
    _rawSub.cancel();
    _socket.close();
  }

  void _startConnection() {
    //start by sending PreliminaryDataRequest
    final req = PreliminaryGetDataRequest()..nonce = nonce;
    req.supportedCapabilities.addAll(DefaultBisqCapability.map((v) => v.index));

    final prelimGetRequest = NetworkEnvelope()
      ..messageVersion = _version.p2pMessageVersion
      ..preliminaryGetDataRequest = req;
    send(prelimGetRequest);
  }

  int send(NetworkEnvelope v) {
    log.finest(">> ${v.toProto3Json()}");

    final data = v.writeToBuffer();

    var delim = CodedBufferWriter();
    delim.writeInt32NoTag(data.lengthInBytes);
    final delimData = delim.toBuffer();

    final wlen = _socket.write(delimData + data);

    final nonce = _getNonce(v);
    if (nonce != null) {
      _pendingRequests[nonce] = v;
    }

    return wlen;
  }

  void _onData(RawSocketEvent ev) {
    if (ev == RawSocketEvent.read) {
      final data = _socket.read(_socket.available());

      //append buffr and see if we have target yet
      if ((_bufferTarget ?? 0) > 0) {
        _buffer.setRange(_bufferOffset ?? 0, (_bufferOffset ?? 0) + data.lengthInBytes, data);
        if (_bufferOffset != null) {
          _bufferOffset += data.lengthInBytes;
        } else {
          _bufferOffset = data.lengthInBytes;
        }

        if (_bufferOffset >= _bufferTarget) {
          _handleEnvelopeBuffer(_buffer);
          _bufferTarget = null;
          _bufferOffset = null;
        } else {
          //not enough data yet
        }
      } else {
        final stream = CodedBufferReader(data);
        final msgLen = stream.readInt32();

        /// not accurate but good enough :(
        /// there doesnt appear to be a way to get the offset from [CodedBufferReader]
        /// at worst we are 1-9 bytes off which shouldn't* be sent as a single packet
        if (msgLen < data.lengthInBytes) {
          //we already have enough data, no need to buffer
          _handleEnvelopeBuffer(data);
        } else {
          _bufferTarget = msgLen;
          _buffer.setRange(_bufferOffset ?? 0, (_bufferOffset ?? 0) + data.lengthInBytes - 1, data);
          if (_bufferOffset != null) {
            _bufferOffset += data.lengthInBytes;
          } else {
            _bufferOffset = data.lengthInBytes;
          }
        }
      }
    }
  }

  void _handleEnvelopeBuffer(Uint8List data) {
    final stream = CodedBufferReader(data);
    final envelope = NetworkEnvelope();

    /// readMessage reads a lenght value first
    stream.readMessage(envelope, ExtensionRegistry.EMPTY);

    //log.finest("<< ${envelope.toProto3Json()}");

    final nonce = _getNonce(envelope);
    NetworkEnvelope req;
    if (nonce != null && _pendingRequests.containsKey(nonce)) {
      req = _pendingRequests.remove(nonce);
    }

    _messageStream.add(PeerMessage(
      request: req,
      response: envelope,
      connection: this,
    ));
  }

  @override
  String toString() {
    return "${_socket.remoteAddress.host}:${_socket.remotePort}";
  }

  int _getNonce(NetworkEnvelope data) {
    switch (data.whichMessage()) {
      case NetworkEnvelope_Message.preliminaryGetDataRequest:
        return data.preliminaryGetDataRequest.nonce;
      case NetworkEnvelope_Message.getDataResponse:
        return data.getDataResponse.requestNonce;
      case NetworkEnvelope_Message.getUpdatedDataRequest:
        return data.getUpdatedDataRequest.nonce;
      case NetworkEnvelope_Message.getPeersRequest:
        return data.getPeersRequest.nonce;
      case NetworkEnvelope_Message.getPeersResponse:
        return data.getPeersResponse.requestNonce;
      case NetworkEnvelope_Message.ping:
        return data.ping.nonce;
      case NetworkEnvelope_Message.pong:
        return data.pong.requestNonce;
      case NetworkEnvelope_Message.getBlocksRequest:
        return data.getBlocksRequest.nonce;
      case NetworkEnvelope_Message.getBlocksResponse:
        return data.getBlocksResponse.requestNonce;
      case NetworkEnvelope_Message.getDaoStateHashesRequest:
        return data.getDaoStateHashesRequest.nonce;
      case NetworkEnvelope_Message.getDaoStateHashesResponse:
        return data.getDaoStateHashesResponse.requestNonce;
      case NetworkEnvelope_Message.getProposalStateHashesRequest:
        return data.getProposalStateHashesRequest.nonce;
      case NetworkEnvelope_Message.getProposalStateHashesResponse:
        return data.getProposalStateHashesResponse.requestNonce;
      case NetworkEnvelope_Message.getBlindVoteStateHashesRequest:
        return data.getBlindVoteStateHashesRequest.nonce;
      case NetworkEnvelope_Message.getBlindVoteStateHashesResponse:
        return data.getBlindVoteStateHashesResponse.requestNonce;
      default:
        return null;
    }
  }
}
