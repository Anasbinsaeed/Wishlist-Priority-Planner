import 'package:flutter/foundation.dart';
import 'package:uuid/uuid.dart';
import '../models/category.dart';
import '../repositories/category_repository.dart';

class CategoryProvider extends ChangeNotifier {
  final CategoryRepository _repo = CategoryRepository();
  final _uuid = const Uuid();

  List<WishCategory> _categories = [];
  bool _isLoading = false;

  List<WishCategory> get categories => _categories;
  bool get isLoading => _isLoading;

  Future<void> loadCategories() async {
    _isLoading = true;
    notifyListeners();
    try {
      _categories = await _repo.getAllCategories();
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<void> addCategory(String name, String icon, int colorValue) async {
    final category = WishCategory(
      id: _uuid.v4(),
      name: name,
      icon: icon,
      colorValue: colorValue,
    );
    await _repo.createCategory(category);
    _categories.add(category);
    notifyListeners();
  }

  Future<void> updateCategory(WishCategory category) async {
    await _repo.updateCategory(category);
    final index = _categories.indexWhere((c) => c.id == category.id);
    if (index != -1) {
      _categories[index] = category;
      notifyListeners();
    }
  }

  Future<void> deleteCategory(String id) async {
    await _repo.deleteCategory(id);
    _categories.removeWhere((c) => c.id == id);
    notifyListeners();
  }

  WishCategory? findById(String id) {
    try {
      return _categories.firstWhere((c) => c.id == id);
    } catch (_) {
      return null;
    }
  }
}
