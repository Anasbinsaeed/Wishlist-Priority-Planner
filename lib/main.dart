import 'dart:ui';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:flutter_timezone/flutter_timezone.dart';
import 'package:path/path.dart' as path_pkg;
import 'package:sqflite/sqflite.dart' as sqflite_pkg;
import 'package:timezone/data/latest_all.dart' as tz;
import 'package:timezone/timezone.dart' as tz;
import 'core/notifications/notification_service.dart';
import 'app.dart';

@pragma('vm:entry-point')
void notificationBackgroundHandler(NotificationResponse response) async {
  WidgetsFlutterBinding.ensureInitialized();

  if (response.actionId != NotificationService.actionMarkDone) return;

  final wishId = response.payload;
  if (wishId == null || wishId.isEmpty) return;

  try {
    final dbPath = await sqflite_pkg.getDatabasesPath();
    final fullPath = path_pkg.join(dbPath, 'wishlist.db');
    final db = await sqflite_pkg.openDatabase(fullPath);
    await db.rawUpdate('UPDATE wishes SET status = ? WHERE id = ?', [
      2,
      wishId,
    ]);
    await db.close();

    final plugin = FlutterLocalNotificationsPlugin();
    await plugin.cancel(wishId.hashCode & 0x0FFFFFFF);
    await plugin.cancel((wishId.hashCode & 0x0FFFFFFF) | 0x10000000);
  } catch (e) {
    debugPrint('notificationBackgroundHandler error: $e');
  }
}

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  await SystemChrome.setPreferredOrientations([
    DeviceOrientation.portraitUp,
    DeviceOrientation.portraitDown,
  ]);

  tz.initializeTimeZones();
  final String localTimezone = await FlutterTimezone.getLocalTimezone();
  tz.setLocalLocation(tz.getLocation(localTimezone));

  final handle = PluginUtilities.getCallbackHandle(
    notificationBackgroundHandler,
  );
  assert(
    handle != null,
    'notificationBackgroundHandler is not accessible to PluginUtilities. '
    'Ensure it is a top-level function in main.dart with @pragma(vm:entry-point).',
  );

  await NotificationService.instance.init(
    backgroundHandler: notificationBackgroundHandler,
  );

  runApp(const WishlistApp());
}
