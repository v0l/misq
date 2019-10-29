abstract class Repository<T extends DBModel> {
  Future<void> add(T value);
  Future<void> remove(T value);

  Future<void> save();
  Future<void> load();
}

abstract class DBModel {
  Map<String, dynamic> toMap();
}