import 'package:flutter/foundation.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:path/path.dart' as path_pkg;
import 'package:sqflite/sqflite.dart' as sqflite_pkg;
import 'package:timezone/timezone.dart' as tz;
import '../../models/wish.dart';

class NotificationService {
  NotificationService._();
  static final NotificationService instance = NotificationService._();

  final _plugin = FlutterLocalNotificationsPlugin();

  static const _channelId = 'wishlist_deadlines';
  static const _channelName = 'Wish Deadlines';
  static const _channelDesc = 'Reminders when wish deadlines are approaching';
  static const actionMarkDone = 'mark_done';

  static int _dayBeforeId(String wishId) => wishId.hashCode & 0x0FFFFFFF;
  static int _exactId(String wishId) =>
      (wishId.hashCode & 0x0FFFFFFF) | 0x10000000;

  Future<void> init({
    DidReceiveBackgroundNotificationResponseCallback? backgroundHandler,
  }) async {
    const android = AndroidInitializationSettings('@mipmap/ic_launcher');
    const ios = DarwinInitializationSettings(
      requestAlertPermission: false,
      requestBadgePermission: false,
      requestSoundPermission: false,
    );

    await _plugin.initialize(
      const InitializationSettings(android: android, iOS: ios),
      onDidReceiveNotificationResponse: _handleForegroundAction,
      onDidReceiveBackgroundNotificationResponse: backgroundHandler,
    );

    await _plugin
        .resolvePlatformSpecificImplementation<
          AndroidFlutterLocalNotificationsPlugin
        >()
        ?.createNotificationChannel(
          const AndroidNotificationChannel(
            _channelId,
            _channelName,
            description: _channelDesc,
            importance: Importance.high,
            enableVibration: true,
            playSound: true,
          ),
        );

    await _plugin
        .resolvePlatformSpecificImplementation<
          AndroidFlutterLocalNotificationsPlugin
        >()
        ?.createNotificationChannel(
          const AndroidNotificationChannel(
            'wishlist_milestones',
            'Milestones',
            description: 'Achievement milestone notifications',
            importance: Importance.high,
            enableVibration: true,
            playSound: true,
          ),
        );
  }

  static void _handleForegroundAction(NotificationResponse response) async {
    if (response.actionId != actionMarkDone) return;
    final wishId = response.payload;
    if (wishId == null || wishId.isEmpty) return;
    await _markWishDone(wishId);
    await instance.cancelForWish(wishId);
  }

  static Future<void> _markWishDone(String wishId) async {
    try {
      final dbPath = await sqflite_pkg.getDatabasesPath();
      final fullPath = path_pkg.join(dbPath, 'wishlist.db');
      final db = await sqflite_pkg.openDatabase(fullPath);
      await db.rawUpdate('UPDATE wishes SET status = ? WHERE id = ?', [
        WishStatus.completed.index,
        wishId,
      ]);
      await db.close();
    } catch (e) {
      debugPrint('NotificationService._markWishDone error: $e');
    }
  }

  Future<void> requestPermission() async {
    await _plugin
        .resolvePlatformSpecificImplementation<
          AndroidFlutterLocalNotificationsPlugin
        >()
        ?.requestNotificationsPermission();
    await _plugin
        .resolvePlatformSpecificImplementation<
          IOSFlutterLocalNotificationsPlugin
        >()
        ?.requestPermissions(alert: true, badge: true, sound: true);
  }

  Future<bool> isPermissionGranted() async {
    final android = _plugin
        .resolvePlatformSpecificImplementation<
          AndroidFlutterLocalNotificationsPlugin
        >();
    if (android != null) {
      return await android.areNotificationsEnabled() ?? false;
    }
    final ios = _plugin
        .resolvePlatformSpecificImplementation<
          IOSFlutterLocalNotificationsPlugin
        >();
    if (ios != null) {
      return await ios.requestPermissions(
            alert: false,
            badge: false,
            sound: false,
          ) ??
          false;
    }
    return false;
  }

  Future<bool> requestAndCheckPermission() async {
    await requestPermission();
    return isPermissionGranted();
  }

  Future<void> scheduleForWish(Wish wish) async {
    await cancelForWish(wish.id);
    if (wish.deadline == null) return;
    if (wish.status != WishStatus.active) return;

    final now = DateTime.now();
    final deadline = wish.deadline!;

    final details = NotificationDetails(
      android: AndroidNotificationDetails(
        _channelId,
        _channelName,
        channelDescription: _channelDesc,
        importance: Importance.high,
        priority: Priority.high,
        icon: '@mipmap/ic_launcher',
      ),
      iOS: const DarwinNotificationDetails(
        presentAlert: true,
        presentBadge: true,
        presentSound: true,
        categoryIdentifier: 'wish_deadline',
      ),
    );

    final dayBefore = deadline.subtract(const Duration(hours: 24));
    if (dayBefore.isAfter(now)) {
      await _scheduleAt(
        id: _dayBeforeId(wish.id),
        title: '⏰ Deadline tomorrow',
        body: '"${wish.title}" is due in 24 hours.',
        payload: wish.id,
        scheduledDate: dayBefore,
        details: details,
      );
    }

    if (deadline.isAfter(now)) {
      await _scheduleAt(
        id: _exactId(wish.id),
        title: '🎯 Deadline reached',
        body: '"${wish.title}" deadline is now!',
        payload: wish.id,
        scheduledDate: deadline,
        details: details,
      );
    }
  }

  Future<void> cancelForWish(String wishId) async {
    await _plugin.cancel(_dayBeforeId(wishId));
    await _plugin.cancel(_exactId(wishId));
  }

  Future<void> cancelAll() async => _plugin.cancelAll();

  Future<void> _scheduleAt({
    required int id,
    required String title,
    required String body,
    required String payload,
    required DateTime scheduledDate,
    required NotificationDetails details,
  }) async {
    try {
      final tzDate = tz.TZDateTime.from(scheduledDate, tz.local);
      await _plugin.zonedSchedule(
        id,
        title,
        body,
        tzDate,
        details,
        payload: payload,
        androidScheduleMode: AndroidScheduleMode.exactAllowWhileIdle,
        uiLocalNotificationDateInterpretation:
            UILocalNotificationDateInterpretation.absoluteTime,
      );
    } catch (e) {
      debugPrint('NotificationService._scheduleAt error: $e');
    }
  }
}
