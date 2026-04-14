import 'package:uuid/uuid.dart';
import '../core/database/database_helper.dart';
import '../models/wish.dart';
import '../models/wish_history.dart';

class WishRepository {
  final DatabaseHelper _db = DatabaseHelper.instance;
  final _uuid = const Uuid();

  Future<List<Wish>> getAllWishes() async {
    final maps = await _db.queryAll('wishes');
    return maps.map(Wish.fromMap).toList();
  }

  Future<List<Wish>> getWishesByStatus(WishStatus status) async {
    final maps = await _db.queryWhere(
      'wishes',
      where: 'status = ?',
      whereArgs: [status.index],
    );
    return maps.map(Wish.fromMap).toList();
  }

  Future<List<Wish>> getWishesByCategory(String categoryId) async {
    final maps = await _db.queryWhere(
      'wishes',
      where: 'category_id = ?',
      whereArgs: [categoryId],
    );
    return maps.map(Wish.fromMap).toList();
  }

  Future<Wish> createWish(Wish wish) async {
    await _db.insert('wishes', wish.toMap());
    await _logHistory(wish.id, 'Wish created: ${wish.title}');
    return wish;
  }

  Future<Wish> updateWish(Wish wish) async {
    await _db.update('wishes', wish.toMap(), wish.id);
    await _logHistory(wish.id, 'Wish updated: ${wish.title}');
    return wish;
  }

  Future<void> deleteWish(String id) async {
    await _db.delete('wishes', id);
    await _db.queryWhere('wish_history', where: 'wish_id = ?', whereArgs: [id]);
  }

  Future<List<WishHistory>> getHistory(String wishId) async {
    final maps = await _db.queryWhere(
      'wish_history',
      where: 'wish_id = ?',
      whereArgs: [wishId],
    );
    return maps.map(WishHistory.fromMap).toList();
  }

  Future<void> _logHistory(String wishId, String description) async {
    final entry = WishHistory(
      id: _uuid.v4(),
      wishId: wishId,
      changeDescription: description,
      changedAt: DateTime.now(),
    );
    await _db.insert('wish_history', entry.toMap());
  }
}
