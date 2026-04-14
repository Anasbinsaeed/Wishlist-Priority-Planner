import '../core/database/database_helper.dart';
import '../models/category.dart';

class CategoryRepository {
  final DatabaseHelper _db = DatabaseHelper.instance;

  Future<List<WishCategory>> getAllCategories() async {
    final maps = await _db.queryAll('categories');
    return maps.map(WishCategory.fromMap).toList();
  }

  Future<WishCategory> createCategory(WishCategory category) async {
    await _db.insert('categories', category.toMap());
    return category;
  }

  Future<WishCategory> updateCategory(WishCategory category) async {
    await _db.update('categories', category.toMap(), category.id);
    return category;
  }

  Future<void> deleteCategory(String id) async {
    await _db.delete('categories', id);
  }
}
