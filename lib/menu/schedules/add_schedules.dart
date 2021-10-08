import 'package:flutter/material.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:intl/intl.dart';
import 'package:project_gmastereki/custom/date_picker.dart';
import 'package:project_gmastereki/custom/new_color.dart';
import 'package:project_gmastereki/custom/shared_pref.dart';
import 'package:project_gmastereki/database/database_helper.dart';
import 'package:project_gmastereki/model_sqflite/schedule_model.dart';
import 'package:rxdart/rxdart.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:timezone/timezone.dart' as tz;

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

class AddSchedules extends StatefulWidget {
  final VoidCallback reload;
  AddSchedules(this.reload,{Key? key}) : super(key: key);
  @override
  _AddSchedulesState createState() => _AddSchedulesState();
}

final myTheme = NewColor();

class _AddSchedulesState extends State<AddSchedules> {

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

  final _key = GlobalKey<FormState>();

  late int idNotif2;
  late int idNotif3;

  getPref()async{
    SharedPreferences pref = await SharedPreferences.getInstance();
    setState(() {
      idNotif2 = int.parse(pref.getString(Pref.idNotif)!);
    });
  }

  savePref(
      String idNotif3,
      )async{
    SharedPreferences pref = await SharedPreferences.getInstance();
    setState(() {
      pref.setString(Pref.idNotif, idNotif3);
    });
  }

  @override
  void initState() {
    // TODO: implement initState
    getPref();
    super.initState();
  }


  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Add Note"),
        backgroundColor: Colors.blue,
        elevation: 2.0,
      ),
      body: ListView(
        padding: const EdgeInsets.all(10.0),
        shrinkWrap: true,
        children: <Widget>[
          TextField(
            controller: title,
            decoration: InputDecoration(
              labelText: 'title',
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(3.0),
              ),
            ),
          ),
          const SizedBox(
            height: 10,
          ),
          TextField(
            maxLines: 5,
            controller: description,
            decoration: InputDecoration(
              labelText: 'description',
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(3.0),
              ),
            ),
          ),
          const SizedBox(
            height: 10,
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
              setState(() {
                idNotif3=idNotif2+1;
              });
              savePref(idNotif3.toString());
              await DatabaseHelper.instance.add(
                ScheduleModel(
                  idnotification: idNotif2.toString(),
                    title: title.text,
                    description: description.text,
                    hour: hour.text,
                    minute: minute.text,
                    datepicker: DateFormat("yyyy-MM-dd").format(tgl1)
                ),
              );
              _scheduleDailyTenAMNotification(title.text, description.text, hour.text, minute.text);
              widget.reload();
              Navigator.pop(context);
            },
            child: const Text("Save"),
          ),
        ],
      ),
    );
  }

  Future<void> _scheduleDailyTenAMNotification(String title, String description, String hour, String minute) async {
    await flutterLocalNotificationsPlugin.zonedSchedule(
        idNotif2,
        title,
        description,
        _nextInstanceOfTenAM(hour, minute),
        const NotificationDetails(
          android: AndroidNotificationDetails(
              '0',
              'title',
              'description',
            sound: RawResourceAndroidNotificationSound('flutter_notif'),),
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
