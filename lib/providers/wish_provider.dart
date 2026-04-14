import 'package:flutter/foundation.dart';
import 'package:uuid/uuid.dart';
import '../models/wish.dart';
import '../repositories/wish_repository.dart';
import '../core/notifications/notification_service.dart';

class WishProvider extends ChangeNotifier {
  final WishRepository _repo = WishRepository();
  final _uuid = const Uuid();
  final _notif = NotificationService.instance;

  List<Wish> _wishes = [];
  bool _isLoading = false;
  String? _error;

  List<Wish> get wishes => _wishes;
  bool get isLoading => _isLoading;
  String? get error => _error;

  List<Wish> get activeWishes =>
      _wishes.where((w) => w.status == WishStatus.active).toList();

  List<Wish> get completedWishes =>
      _wishes.where((w) => w.status == WishStatus.completed).toList();

  Future<void> loadWishes() async {
    _isLoading = true;
    _error = null;
    notifyListeners();
    try {
      _wishes = await _repo.getAllWishes();
      for (final w in _wishes) {
        await _notif.scheduleForWish(w);
      }
    } catch (e) {
      _error = e.toString();
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<void> addWish({
    required String title,
    String? description,
    required String categoryId,
    required WishPriority priority,
    DateTime? deadline,
    String? imagePath,
    String? notes,
    List<String> tags = const [],
  }) async {
    final wish = Wish(
      id: _uuid.v4(),
      title: title,
      description: description,
      categoryId: categoryId,
      priority: priority,
      createdAt: DateTime.now(),
      deadline: deadline,
      imagePath: imagePath,
      notes: notes,
      tags: tags,
    );
    await _repo.createWish(wish);
    await _notif.scheduleForWish(wish);
    _wishes.add(wish);
    notifyListeners();
  }

  Future<void> updateWish(Wish wish) async {
    await _repo.updateWish(wish);
    await _notif.scheduleForWish(wish);
    final index = _wishes.indexWhere((w) => w.id == wish.id);
    if (index != -1) {
      _wishes[index] = wish;
      notifyListeners();
    }
  }

  Future<void> updateStatus(String id, WishStatus status) async {
    final wish = _wishes.firstWhere((w) => w.id == id);
    await updateWish(wish.copyWith(status: status));
  }

  Future<void> deleteWish(String id) async {
    await _repo.deleteWish(id);
    await _notif.cancelForWish(id);
    _wishes.removeWhere((w) => w.id == id);
    notifyListeners();
  }

  void softDeleteWish(String id) {
    _wishes.removeWhere((w) => w.id == id);
    notifyListeners();
  }

  Future<void> commitDelete(String id) async {
    await _repo.deleteWish(id);
    await _notif.cancelForWish(id);
  }

  Future<void> restoreWish(Wish wish) async {
    if (_wishes.any((w) => w.id == wish.id)) return;
    final insertIndex = _wishes.indexWhere(
      (w) => w.createdAt.isBefore(wish.createdAt),
    );
    if (insertIndex == -1) {
      _wishes.add(wish);
    } else {
      _wishes.insert(insertIndex, wish);
    }
    notifyListeners();
    await _repo.createWish(wish);
    await _notif.scheduleForWish(wish);
  }

  Future<void> deleteWishes(List<String> ids) async {
    for (final id in ids) {
      await _repo.deleteWish(id);
      await _notif.cancelForWish(id);
    }
    _wishes.removeWhere((w) => ids.contains(w.id));
    notifyListeners();
  }

  Future<void> removeTagFromAllWishes(String tag) async {
    final affected = _wishes.where((w) => w.tags.contains(tag)).toList();
    for (final wish in affected) {
      final updated = wish.copyWith(
        tags: wish.tags.where((t) => t != tag).toList(),
      );
      await _repo.updateWish(updated);
      final index = _wishes.indexWhere((w) => w.id == wish.id);
      if (index != -1) _wishes[index] = updated;
    }
    notifyListeners();
  }

  List<Wish> filterWishes({
    WishStatus? status,
    WishPriority? priority,
    String? categoryId,
    String? tag,
  }) {
    return _wishes.where((w) {
      if (status != null && w.status != status) return false;
      if (priority != null && w.priority != priority) return false;
      if (categoryId != null && w.categoryId != categoryId) return false;
      if (tag != null && !w.tags.contains(tag)) return false;
      return true;
    }).toList();
  }
}
