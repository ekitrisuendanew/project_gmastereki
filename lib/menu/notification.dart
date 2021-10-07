import 'dart:async';
import 'dart:ui';
import 'package:flutter/cupertino.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:project_gmastereki/custom/new_color.dart';
import 'package:rxdart/subjects.dart';
import 'package:timezone/timezone.dart' as tz;

final FlutterLocalNotificationsPlugin flutterLocalNotificationsPlugin = FlutterLocalNotificationsPlugin();
final BehaviorSubject<ReceivedNotification> didReceiveLocalNotificationSubject = BehaviorSubject<ReceivedNotification>();
final BehaviorSubject<String?> selectNotificationSubject = BehaviorSubject<String?>();

class ReceivedNotification {
  ReceivedNotification({
    required this.id,
    required this.title,
    required this.body,
    required this.payload,
  });

  final int id;
  final String? title;
  final String? body;
  final String? payload;
}


class PaddedElevatedButton extends StatelessWidget {
  const PaddedElevatedButton({
    required this.buttonText,
    required this.onPressed,
    Key? key,
  }) : super(key: key);

  final String buttonText;
  final VoidCallback onPressed;

  @override
  Widget build(BuildContext context) => Padding(
    padding: const EdgeInsets.fromLTRB(0, 0, 0, 8),
    child: ElevatedButton(
      onPressed: onPressed,
      child: Text(buttonText),
    ),
  );
}

final myTheme = NewColor();

class Timetable extends StatefulWidget {
  const Timetable({Key? key}) : super(key: key);

  @override
  _TimetableState createState() => _TimetableState();
}

class _TimetableState extends State<Timetable> {
  @override
  void initState() {
    super.initState();
    _requestPermissions();
    _configureDidReceiveLocalNotificationSubject();
    _configureSelectNotificationSubject();
  }

  void _requestPermissions() {
    flutterLocalNotificationsPlugin
        .resolvePlatformSpecificImplementation<
        IOSFlutterLocalNotificationsPlugin>()
        ?.requestPermissions(
      alert: true,
      badge: true,
      sound: true,
    );
    flutterLocalNotificationsPlugin
        .resolvePlatformSpecificImplementation<
        MacOSFlutterLocalNotificationsPlugin>()
        ?.requestPermissions(
      alert: true,
      badge: true,
      sound: true,
    );
  }

  void _configureDidReceiveLocalNotificationSubject() {
    didReceiveLocalNotificationSubject.stream
        .listen((ReceivedNotification receivedNotification) async {
      await showDialog(
        context: context,
        builder: (BuildContext context) => CupertinoAlertDialog(
          title: receivedNotification.title != null
              ? Text(receivedNotification.title!)
              : null,
          content: receivedNotification.body != null
              ? Text(receivedNotification.body!)
              : null,
          actions: <Widget>[
            CupertinoDialogAction(
              isDefaultAction: true,
              onPressed: () async {
                Navigator.of(context, rootNavigator: true).pop();
                await Navigator.push(
                  context,
                  MaterialPageRoute<void>(
                    builder: (BuildContext context) =>
                        SecondPage(receivedNotification.payload),
                  ),
                );
              },
              child: const Text('Ok'),
            )
          ],
        ),
      );
    });
  }

  void _configureSelectNotificationSubject() {
    selectNotificationSubject.stream.listen((String? payload) async {
      await Navigator.pushNamed(context, '/secondPage');
    });
  }

  @override
  void dispose() {
    didReceiveLocalNotificationSubject.close();
    selectNotificationSubject.close();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) => MaterialApp(
    home: Scaffold(
      appBar: AppBar(
        backgroundColor: myTheme.colors[color1],
        title: const Text('Timetable'),
      ),
      body: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.all(8),
          child: Center(
            child: Column(
              children: <Widget>[

                PaddedElevatedButton(
                  buttonText: 'Show notification with custom sound and schedule 5 seconds',
                  onPressed: () async {
                    await _showNotificationCustomSoundandschedule();
                  },
                ),

                PaddedElevatedButton(
                  buttonText:
                  'Schedule daily 10:00:00 am notification in your '
                      'local time zone',
                  onPressed: () async {
                    await _scheduleDailyTenAMNotification();
                  },
                ),
                PaddedElevatedButton(
                  buttonText: 'Check pending notifications',
                  onPressed: () async {
                    await _checkPendingNotificationRequests();
                  },
                ),
                PaddedElevatedButton(
                  buttonText: 'Cancel notification',
                  onPressed: () async {
                    await _cancelNotification();
                  },
                ),
                PaddedElevatedButton(
                  buttonText: 'Cancel all notifications',
                  onPressed: () async {
                    await _cancelAllNotifications();
                  },
                ),
              ],
            ),
          ),
        ),
      ),
    ),
  );

  Future<void> _cancelNotification() async {
    await flutterLocalNotificationsPlugin.cancel(0);
  }


  Future<void> _showNotificationCustomSoundandschedule() async {

    const AndroidNotificationDetails androidPlatformChannelSpecifics =
    AndroidNotificationDetails(
      'your other channel id',
      'your other channel name',
      'your other channel description',
      sound: RawResourceAndroidNotificationSound('flutter_notif'),
    );
    const NotificationDetails platformChannelSpecifics = NotificationDetails(
      android: androidPlatformChannelSpecifics,
    );
    await flutterLocalNotificationsPlugin.zonedSchedule(
        0,
        'scheduled title',
        'scheduled body',
        tz.TZDateTime.now(tz.local).add(const Duration(seconds: 5)),
        platformChannelSpecifics,
        androidAllowWhileIdle: true,
        uiLocalNotificationDateInterpretation:
        UILocalNotificationDateInterpretation.absoluteTime);
  }

  Future<void> _checkPendingNotificationRequests() async {
    final List<PendingNotificationRequest> pendingNotificationRequests =
    await flutterLocalNotificationsPlugin.pendingNotificationRequests();
    return showDialog<void>(
      context: context,
      builder: (BuildContext context) => AlertDialog(
        content:
        Text('${pendingNotificationRequests.length} pending notification '
            'requests'),
        actions: <Widget>[
          TextButton(
            onPressed: () {
              Navigator.of(context).pop();
            },
            child: const Text('OK'),
          ),
        ],
      ),
    );
  }

  Future<void> _cancelAllNotifications() async {
    await flutterLocalNotificationsPlugin.cancelAll();
  }

  Future<void> _scheduleDailyTenAMNotification() async {
    await flutterLocalNotificationsPlugin.zonedSchedule(
        0,
        'daily scheduled notification title',
        'daily scheduled notification body',
        _nextInstanceOfTenAM(),
        const NotificationDetails(
          android: AndroidNotificationDetails(
              'daily notification channel id',
              'daily notification channel name',
              'daily notification description'),
        ),
        androidAllowWhileIdle: true,
        uiLocalNotificationDateInterpretation:
        UILocalNotificationDateInterpretation.absoluteTime,
        matchDateTimeComponents: DateTimeComponents.time);
  }

  tz.TZDateTime _nextInstanceOfTenAM() {
    final tz.TZDateTime now = tz.TZDateTime.now(tz.local);
    tz.TZDateTime scheduledDate =
    tz.TZDateTime(tz.local, now.year, now.month, now.day, 10);
    if (scheduledDate.isBefore(now)) {
      scheduledDate = scheduledDate.add(const Duration(days: 1));
    }
    return scheduledDate;
  }

}

class SecondPage extends StatefulWidget {
  const SecondPage(
      this.payload, {
        Key? key,
      }) : super(key: key);

  static const String routeName = '/secondPage';

  final String? payload;

  @override
  State<StatefulWidget> createState() => SecondPageState();
}

class SecondPageState extends State<SecondPage> {
  String? _payload;
  @override
  void initState() {
    super.initState();
    _payload = widget.payload;
  }

  @override
  Widget build(BuildContext context) => Scaffold(
    appBar: AppBar(
      title: Text('Second Screen with payload: ${_payload ?? ''}'),
    ),
    body: Center(
      child: ElevatedButton(
        onPressed: () {
          Navigator.pop(context);
        },
        child: const Text('Go back!'),
      ),
    ),
  );
}
