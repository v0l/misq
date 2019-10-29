import 'package:logging/logging.dart';
import 'package:misq_p2p/internal/model/node_address.dart';
import 'package:misq_p2p/internal/repository/base.dart';
import 'package:misq_p2p/internal/version.dart';
import 'package:sqflite/sqflite.dart';
import 'package:path/path.dart' as p;

class PeerRepository extends Repository<PeerAddress> {
  static const String DBName = "peers.db";
  static const String tableName = "peers";
  static const int DBVersion = 1;

  final Logger log = Logger("PeerRepository");
  final BisqVersion _version;
  final List<PeerAddress> _peers = List<PeerAddress>();

  List<PeerAddress> get peers => _peers;

  PeerRepository(this._version);

  @override
  Future<void> add(PeerAddress value) async {
    if (!_peers.contains(value)) {
      _peers.add(value);
    }
  }

  @override
  Future<void> load() async {
    log.info("Trying to open $DBName from ${_version.appDataDirectory}");

    final db =
        await openDatabase(p.join(_version.appDataDirectory, DBName), version: DBVersion, onCreate: _createTable);

    final peers = await db.query(tableName, columns: [PeerAddress.colAddr, PeerAddress.colConFirst, PeerAddress.colConLast]);
    if (peers.length > 0) {
      _peers.clear();
      _peers.addAll(peers.map((a) => PeerAddress.fromMap(a)));
    }

    await db.close();
  }

  @override
  Future<void> remove(PeerAddress value) async {
    _peers.remove(value);
  }

  @override
  Future<void> save() async {
    log.info("Saving $DBName");

    final db =
        await openDatabase(p.join(_version.appDataDirectory, DBName), version: DBVersion, onCreate: _createTable);

    if (_peers.length > 0) {
      for (var peer in _peers) {
        final rowUpdates = await db.update(tableName, peer.toMap(), where: "${PeerAddress.colAddr} = ?", whereArgs: [peer.address]);
        if (rowUpdates == 0) {
          await db.insert(tableName, peer.toMap());
        }
      }
    } else {
      await db.execute("truncate table $tableName");
    }

    await db.close();
  }

  Future<void> _createTable(Database db, int version) async {
    await db.execute(
        "create table $tableName (${PeerAddress.colAddr} text primary key, ${PeerAddress.colConFirst} INTEGER not null, ${PeerAddress.colConLast} INTEGER)");
    log.info("Created table $tableName in $DBName");
  }
}
