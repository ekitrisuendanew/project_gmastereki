import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:project_gmastereki/custom/date_picker.dart';
import 'package:project_gmastereki/database/database_helper.dart';
import 'package:project_gmastereki/model_sqflite/schedule_model.dart';
import 'dart:async';
import 'package:flutter/cupertino.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:rxdart/subjects.dart';
import 'package:timezone/timezone.dart' as tz;
import 'package:intl/intl.dart';

final FlutterLocalNotificationsPlugin flutterLocalNotificationsPlugin =
FlutterLocalNotificationsPlugin();
final BehaviorSubject<ReceivedNotification> didReceiveLocalNotificationSubject =
BehaviorSubject<ReceivedNotification>();
final BehaviorSubject<String?> selectNotificationSubject =
BehaviorSubject<String?>();

class ReceivedNotification {
  ReceivedNotification({
    required this.id,
    required this.title,
    required this.description,
  });

  final int id;
  final String? title;
  final String? description;
}

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

  late String pilihTanggal1;
  DateTime tgl1 = DateTime.now();
  final TextStyle valueStyle1 = const TextStyle(fontSize: 16.0);
  Future<Null> _selectedDate(BuildContext context) async{
    final DateTime? picked = await showDatePicker(
        context: context,
        initialDate: tgl1,
        firstDate: DateTime(1992),
        lastDate: DateTime(2099));

    if(picked != null && picked != tgl1){
      setState(() {
        tgl1 = picked;
        pilihTanggal1 = DateFormat("yyyy-MM-dd").format(DateTime.now());
      });
    }else{}
  }

  final _key = new GlobalKey<FormState>();

  dialog() {
    showDialog(
      context: context,
      builder: (context) {
        return Dialog(
          child: ListView(
            padding: const EdgeInsets.all(10.0),
            shrinkWrap: true,
            children: <Widget>[
              TextField(
                controller: title,
                decoration: const InputDecoration(
                  labelText: 'title',
                ),
              ),
              const SizedBox(
                height: 10,
              ),
              TextField(
                maxLines: 5,
                controller: description,
                decoration: const InputDecoration(
                  labelText: 'description',
                ),
              ),
              const SizedBox(
                height: 20,
              ),
              DateDropDown(
                valueText: DateFormat.yMd().format(tgl1),
                valueStyle: valueStyle1,
                onPressed: (){
                  _selectedDate(context);
                }, labelText: 'Date:', key: _key, child: const SizedBox(),
              ),
              const SizedBox(
                height: 20,
              ),
              Row(
                children: [
                  Expanded(
                    child: TextField(
                      keyboardType: TextInputType.number,
                      controller: hour,
                      decoration: InputDecoration(
                        labelText: 'hour',
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(3.0),
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(
                    width: 10,
                  ),
                  Expanded(
                    child: TextField(
                      keyboardType: TextInputType.number,
                      controller: minute,
                      decoration: InputDecoration(
                        labelText: 'minute',
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(3.0),
                        ),
                      ),
                    ),
                  ),
                ],
              ),
              const SizedBox(
                height: 10,
              ),
              ElevatedButton(
                onPressed: () async {
                  await DatabaseHelper.instance.add(
                    ScheduleModel(
                        title: title.text,
                        description: description.text,
                        hour: hour.text,
                        minute: minute.text,
                        datepicker: DateFormat("yyyy-MM-dd").format(tgl1)
                    ),
                  );
                  _scheduleDailyTenAMNotification(
                      title.text, description.text, hour.text, minute.text);
                  Navigator.pop(context);
                  setState(() {
                    title.clear();
                    description.clear();
                    hour.clear();
                    minute.clear();
                  });
                },
                child: const Text("Save"),
              ),
            ],
          ),
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      home: Scaffold(
        appBar: AppBar(title: const Text('Schedule')),
        body: Center(
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
                        onLongPress: () {
                          setState(() {
                            DatabaseHelper.instance.remove(schedule.id!);
                          });
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
                                    Text(DateFormat("yyyy-MM-dd").format(tgl1), style: const TextStyle(color: Colors.black54)),
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
        floatingActionButton: FloatingActionButton(
          child: const Icon(Icons.add),
          onPressed: () {
            dialog();
          },
        ),
      ),
    );
  }

  Future<void> _scheduleDailyTenAMNotification(
      String title, String description, String hour, String minute) async {
    await flutterLocalNotificationsPlugin.zonedSchedule(
        0,
        title,
        description,
        _nextInstanceOfTenAM(hour, minute),
        const NotificationDetails(
          android: AndroidNotificationDetails('0', 'title', 'description'),
        ),
        androidAllowWhileIdle: true,
        uiLocalNotificationDateInterpretation:
        UILocalNotificationDateInterpretation.absoluteTime,
        matchDateTimeComponents: DateTimeComponents.time);
  }

  tz.TZDateTime _nextInstanceOfTenAM(String hour, String minute) {
    final tz.TZDateTime now = tz.TZDateTime.now(tz.local);
    tz.TZDateTime scheduledDate = tz.TZDateTime(tz.local, int.parse(DateFormat("yyyy").format(tgl1)), int.parse(DateFormat("MM").format(tgl1)), int.parse(DateFormat("dd").format(tgl1)), int.parse(hour), int.parse(minute));
    if (scheduledDate.isBefore(now)) {
      scheduledDate = scheduledDate.add(const Duration(days: 1));
    }
    return scheduledDate;
  }
}
