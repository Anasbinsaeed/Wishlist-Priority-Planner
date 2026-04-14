import 'package:flutter/foundation.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import '../models/wish.dart';

class AnalyticsProvider extends ChangeNotifier {
  List<Wish> _wishes = [];
  int _lastMilestoneNotified = -1;

  void update(List<Wish> wishes) {
    final prevCompleted = _wishes
        .where((w) => w.status == WishStatus.completed)
        .length;
    _wishes = wishes;
    final newCompleted = completedCount;

    if (newCompleted > prevCompleted && newCompleted > 0) {
      _checkMilestone(newCompleted);
    }

    notifyListeners();
  }

  void _checkMilestone(int completed) {
    if (completed % 5 == 0 && completed != _lastMilestoneNotified) {
      _lastMilestoneNotified = completed;
      _sendMilestoneNotification(completed);
    }
  }

  void _sendMilestoneNotification(int count) async {
    try {
      final plugin = FlutterLocalNotificationsPlugin();
      await plugin.show(
        900000 + count,
        '🏆 Milestone Achieved!',
        'Congratulations! You\'ve completed $count wish${count == 1 ? '' : 'es'}.',
        const NotificationDetails(
          android: AndroidNotificationDetails(
            'wishlist_milestones',
            'Milestones',
            channelDescription: 'Achievement milestone notifications',
            importance: Importance.high,
            priority: Priority.high,
            icon: '@mipmap/ic_launcher',
          ),
          iOS: DarwinNotificationDetails(
            presentAlert: true,
            presentBadge: true,
            presentSound: true,
          ),
        ),
      );
    } catch (e) {
      debugPrint('AnalyticsProvider: milestone notification failed — $e');
    }
  }

  int get totalWishes => _wishes.length;
  int get completedCount =>
      _wishes.where((w) => w.status == WishStatus.completed).length;
  int get activeCount =>
      _wishes.where((w) => w.status == WishStatus.active).length;

  double get completionRate =>
      totalWishes == 0 ? 0 : completedCount / totalWishes;

  Map<WishPriority, int> get byPriority {
    final map = <WishPriority, int>{};
    for (final p in WishPriority.values) {
      map[p] = _wishes.where((w) => w.priority == p).length;
    }
    return map;
  }

  Map<String, int> get byCategory {
    final map = <String, int>{};
    for (final w in _wishes) {
      map[w.categoryId] = (map[w.categoryId] ?? 0) + 1;
    }
    return map;
  }

  List<Wish> get upcomingDeadlines {
    final now = DateTime.now();
    final soon = now.add(const Duration(days: 7));
    return _wishes
        .where(
          (w) =>
              w.status == WishStatus.active &&
              w.deadline != null &&
              w.deadline!.isAfter(now) &&
              w.deadline!.isBefore(soon),
        )
        .toList()
      ..sort((a, b) => a.deadline!.compareTo(b.deadline!));
  }

  List<Wish> get overdueWishes {
    final now = DateTime.now();
    return _wishes
        .where(
          (w) =>
              w.status == WishStatus.active &&
              w.deadline != null &&
              w.deadline!.isBefore(now),
        )
        .toList();
  }

  int get weeklyCompletedCount {
    final weekAgo = DateTime.now().subtract(const Duration(days: 7));
    return _wishes
        .where(
          (w) =>
              w.status == WishStatus.completed && w.createdAt.isAfter(weekAgo),
        )
        .length;
  }

  List<Wish> get prioritySortedActive {
    final active = _wishes.where((w) => w.status == WishStatus.active).toList();
    active.sort((a, b) => b.priority.index.compareTo(a.priority.index));
    return active;
  }
}
