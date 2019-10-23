class BitcoinNetwork {
  static const Mainnet = const BitcoinNetwork._(0);
  static const Testnet = const BitcoinNetwork._(1);
  static const Regtest = const BitcoinNetwork._(2);

  final int _value;

  const BitcoinNetwork._(this._value);
}

class BisqVersion {
  static const Mainnet = const BisqVersion(BitcoinNetwork.Mainnet);
  static const Testnet = const BisqVersion(BitcoinNetwork.Testnet);
  static const Regtest = const BisqVersion(BitcoinNetwork.Regtest);

  static const _P2PNetworkVersion = 1;

  final BitcoinNetwork network;
  const BisqVersion(this.network);

  int get p2pMessageVersion => (network?._value ?? 0) + 10 * _P2PNetworkVersion;
}
