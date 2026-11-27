import 'dart:async';

import 'package:feat_couple/feat_couple.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:flutter_timezone/flutter_timezone.dart';
import 'package:timezone/data/latest.dart' as tzdata;
import 'package:timezone/timezone.dart' as tz;

import 'l10n/app_localizations.dart';

/// One alert ready to hand to the phone.
class ReminderAlert {
  const ReminderAlert({required this.at, required this.title, required this.body});
  final DateTime at;
  final String title;
  final String body;
}

/// Replaces every scheduled calendar alert on this phone with [alerts].
abstract class ReminderScheduler {
  Future<void> replaceAll(List<ReminderAlert> alerts);
}

/// Local notifications (no server, no FCM). Inexact alarms: Android may deliver a few
/// minutes late, which is fine for reminders and needs no exact-alarm permission.
/// Does nothing on web.
class PhoneReminders implements ReminderScheduler {
  final _plugin = FlutterLocalNotificationsPlugin();
  bool _ready = false;
  bool _askedPermission = false;

  Future<void> _init() async {
    if (_ready) return;
    tzdata.initializeTimeZones();
    try {
      final info = await FlutterTimezone.getLocalTimezone();
      tz.setLocalLocation(tz.getLocation(info.identifier));
    } catch (_) {
      tz.setLocalLocation(tz.UTC); // DateTimes below are converted from absolute instants anyway
    }
    await _plugin.initialize(
      settings: const InitializationSettings(android: AndroidInitializationSettings('@mipmap/ic_launcher')),
    );
    _ready = true;
  }

  @override
  Future<void> replaceAll(List<ReminderAlert> alerts) async {
    if (kIsWeb) return;
    try {
      await _init();
      final android = _plugin.resolvePlatformSpecificImplementation<AndroidFlutterLocalNotificationsPlugin>();
      if (alerts.isNotEmpty && !_askedPermission) {
        _askedPermission = true;
        await android?.requestNotificationsPermission(); // Android 13+ asks once
      }
      await _plugin.cancelAll();
      for (var i = 0; i < alerts.length; i++) {
        final a = alerts[i];
        await _plugin.zonedSchedule(
          id: i + 1,
          scheduledDate: tz.TZDateTime.from(a.at, tz.local),
          title: a.title,
          body: a.body,
          androidScheduleMode: AndroidScheduleMode.inexactAllowWhileIdle,
          notificationDetails: const NotificationDetails(
            android: AndroidNotificationDetails(
              'calendar_reminders',
              'Calendar reminders',
              importance: Importance.high,
              priority: Priority.high,
            ),
          ),
        );
      }
    } catch (e) {
      debugPrint('Reminders not scheduled: $e');
    }
  }
}

/// Keeps this phone's alerts in step with the union calendar: every change that arrives
/// through Realtime (from any member) reschedules. Locked unions get no alerts.
class ReminderSync extends StatefulWidget {
  const ReminderSync({
    super.key,
    required this.couple,
    required this.unionId,
    required this.uid,
    required this.scheduler,
    required this.child,
    this.clock = DateTime.now,
  });

  final CoupleRepository couple;
  final String unionId;
  final String uid;
  final ReminderScheduler scheduler;
  final Widget child;
  final DateTime Function() clock;

  @override
  State<ReminderSync> createState() => _ReminderSyncState();
}

class _ReminderSyncState extends State<ReminderSync> {
  StreamSubscription<bool>? _entitledSub;
  StreamSubscription<List<CalendarEvent>>? _eventsSub;
  Future<void> _queue = Future.value();

  @override
  void initState() {
    super.initState();
    _entitledSub = widget.couple.watchEntitled(widget.unionId).listen((on) {
      _eventsSub?.cancel();
      _eventsSub = null;
      if (!on) {
        _schedule(const []);
        return;
      }
      _eventsSub = widget.couple.watchEvents(widget.unionId).listen(_schedule, onError: (_) {});
    }, onError: (_) {});
  }

  void _schedule(List<CalendarEvent> events) {
    if (!mounted) return;
    final l = AppLocalizations.of(context);
    final alerts = [
      for (final p in planReminders(events, widget.uid, widget.clock()))
        ReminderAlert(
          at: p.at,
          title: p.event.title,
          body: switch (p.minutesBefore) {
            60 => l.reminderInHour,
            1440 => l.reminderInDay,
            final m => l.reminderInMinutes(m),
          },
        ),
    ];
    // One at a time, in arrival order, so an older plan never overwrites a newer one.
    _queue = _queue.then((_) => widget.scheduler.replaceAll(alerts));
  }

  @override
  void dispose() {
    _entitledSub?.cancel();
    _eventsSub?.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) => widget.child;
}
