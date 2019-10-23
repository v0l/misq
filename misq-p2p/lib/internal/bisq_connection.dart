import 'dart:async';
import 'dart:io';
import 'dart:math';
import 'dart:typed_data';

import 'package:misq_p2p/internal/bisq_capability.dart';
import 'package:misq_p2p/internal/bisq_version.dart';
import 'package:misq_p2p/internal/const.dart';
import 'package:misq_p2p/proto_dart/proto/proto_v1.1.7.pb.dart';
import 'package:protobuf/protobuf.dart';
import 'package:socks/socks.dart';

/// Creates an outbound peer connection
/// 
/// Can open connections via tor if its running on the default port 9050
/// 
class BisqConnection {
  BisqVersion _version;
  SOCKSSocket _torSocket;
  RawSocket _rawSocket;
  StreamSubscription<RawSocketEvent> _rawSub;
  final StreamController<NetworkEnvelope> _messageStream = StreamController<NetworkEnvelope>();
  Stream<NetworkEnvelope> get onMessage => _messageStream.stream;

  Uint8List _buffer = Uint8List(MaxMessageSize);
  int _bufferOffset = 0;
  int _bufferTarget;

  RawSocket get _socket => _rawSocket;

  BisqConnection(this._version);

  Future connect(InternetAddress ip, [int port = 9999]) async {
    _rawSocket = await RawSocket.connect(ip, port);
    _rawSub = _rawSocket.listen(_onData);

    _startConnection();
  }

  Future connectTor(String host) async {
    _rawSocket = await RawSocket.connect(InternetAddress.loopbackIPv4, 9050);
    _torSocket = SOCKSSocket(_rawSocket);
    await _torSocket.connect(host);
    _rawSub = _torSocket.subscription;
    _rawSub.onData(_onData); //set onData handler to our handler function

    _startConnection();
  }

  void close() {
    _messageStream.close();
    _rawSub.cancel();
    _socket.close();
  }

  void _startConnection() {
    //start by sending PreliminaryDataRequest
    final req = PreliminaryGetDataRequest()..nonce = Random().nextInt(Int32Max);
    req.supportedCapabilities.addAll(DefaultBisqCapability.map((v) => v.index));

    final prelimGetRequest = NetworkEnvelope()
      ..messageVersion = _version.p2pMessageVersion
      ..preliminaryGetDataRequest = req;
    send(prelimGetRequest);
  }

  void send(NetworkEnvelope v) {
    print(">> ${v.toProto3Json()}");

    final data = v.writeToBuffer();

    var delim = CodedBufferWriter();
    delim.writeInt32NoTag(data.lengthInBytes);
    final delimData = delim.toBuffer();

    _socket.write(delimData + data);
    // TODO: check how much we wrote
  }

  void _onData(RawSocketEvent ev) {
    if (ev == RawSocketEvent.read) {
      final data = _socket.read(_socket.available());

      //print("Got: ${data.lengthInBytes}");
      //print("Buffer Length: ${(_bufferOffset ?? 0)}");

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
    //print("Buffer = Target: ${(_bufferTarget ?? 0)}, Offset: ${_bufferOffset ?? 0}, Length: ${_buffer.lengthInBytes}");

    final stream = CodedBufferReader(data);
    final envelope = NetworkEnvelope();

    /// readMessage reads a lenght value first
    stream.readMessage(envelope, ExtensionRegistry.EMPTY);

    print("<< ${envelope.toProto3Json()}");

    _messageStream.add(envelope);
  }
}
