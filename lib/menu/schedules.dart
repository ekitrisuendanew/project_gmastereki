import 'package:device_info/device_info.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:project_gmastereki/custom/date_picker.dart';
import 'package:project_gmastereki/database/database_helper.dart';
import 'package:project_gmastereki/menu/schedules/add_schedules.dart';
import 'package:project_gmastereki/model_sqflite/schedule_model.dart';
import 'dart:async';
import 'package:flutter/cupertino.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:rxdart/subjects.dart';
import 'package:timezone/timezone.dart' as tz;
import 'package:intl/intl.dart';


class Schedule extends StatefulWidget {
  const Schedule({Key? key}) : super(key: key);

  @override
  _ScheduleState createState() => _ScheduleState();
}

class _ScheduleState extends State<Schedule> {

  final title = TextEditingController();
  final description = TextEditingController();
  final hour = TextEditingController();
  final minute = TextEditingController();

  DateTime tgl1 = DateTime.now();

  reload(){
    setState(() {
      title.clear();
      description.clear();
      hour.clear();
      minute.clear();
    });
  }

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      home: Scaffold(
        appBar: AppBar(title: const Text('Schedule')),
        body: Column(
          children: [
            Padding(
              padding: const EdgeInsets.all(8.0),
              child: Row(
                children: [
                  Expanded(
                    child: ElevatedButton(
                      onPressed: () async {
                        await _checkPendingNotificationRequests();
                      },
                      child: const FittedBox(child: Text("Check pending notifications")),
                    ),
                  ),
                  const SizedBox(width: 10,),
                  Expanded(
                    child: ElevatedButton(
                      onPressed: () async {
                        await _cancelAllNotifications();
                      },
                      child: const FittedBox(child: Text("Cancel all notifications")),
                    ),
                  ),
                ],
              ),
            ),
            Expanded(
              child: Center(
                child: FutureBuilder<List<ScheduleModel>>(
                    future: DatabaseHelper.instance.getSchedules(),
                    builder: (BuildContext context,
                        AsyncSnapshot<List<ScheduleModel>> snapshot) {
                      if (!snapshot.hasData) {
                        return const Center(child: Text('Loading...'));
                      }
                      return snapshot.data!.isEmpty
                          ? const Center(child: Text('No Schedule in List.'))
                          : ListView(
                        children: snapshot.data!.map((schedule) {
                          return Center(
                            child: InkWell(
                              onTap: () {},
                              onLongPress: ()  async {
                                setState(() {
                                  DatabaseHelper.instance.remove(schedule.id!);
                                });
                                await _cancelNotification(int.parse(schedule.idnotification));
                              },
                              child: Card(
                                color: Colors.white,
                                child: Padding(
                                  padding: const EdgeInsets.all(8.0),
                                  child: Column(
                                    crossAxisAlignment:
                                    CrossAxisAlignment.stretch,
                                    mainAxisAlignment: MainAxisAlignment.start,
                                    children: [
                                      Row(
                                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                        children: [
                                          Expanded(
                                            child: Text(
                                              schedule.title,
                                              style: const TextStyle(
                                                  color: Colors.blue,fontSize: 20),
                                            ),
                                          ),
                                          Row(
                                            mainAxisAlignment:
                                            MainAxisAlignment.start,
                                            children: [
                                              const Icon(Icons.access_time,color: Colors.blue,),
                                              const SizedBox(
                                                width: 10,
                                              ),
                                              Text(
                                                schedule.hour.toString() +
                                                    ":" +
                                                    schedule.minute.toString(),
                                                style: const TextStyle(
                                                  fontSize: 20,
                                                  color: Colors.blue,),
                                              ),
                                            ],
                                          ),
                                        ],
                                      ),
                                      const SizedBox(
                                        height: 10,
                                      ),
                                      Row(
                                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                        crossAxisAlignment: CrossAxisAlignment.start,
                                        children: [
                                          Expanded(
                                            child: Text(
                                              schedule.description,
                                              style: const TextStyle(
                                                  color: Colors.black54),
                                            ),
                                          ),
                                          const SizedBox(
                                            width: 10,
                                          ),
                                          Text(DateFormat( schedule.datepicker).format(tgl1), style: const TextStyle(color: Colors.black54)),
                                        ],
                                      ),
                                    ],
                                  ),
                                ),
                              ),
                            ),
                          );
                        }).toList(),
                      );
                    }),
              ),
            ),
          ],
        ),
        floatingActionButton: FloatingActionButton(
          child: const Icon(Icons.add),
          onPressed: () {
            Navigator.push(
              context,
              MaterialPageRoute(
                builder: (context) => AddSchedules(reload),
              ),
            );
          },
        ),
      ),
    );
  }


  Future<void> _cancelNotification(int idNotif3) async {
    await flutterLocalNotificationsPlugin.cancel(idNotif3);
  }

  Future<void> _cancelAllNotifications() async {
    await flutterLocalNotificationsPlugin.cancelAll();
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



}
