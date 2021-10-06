import 'package:flutter/material.dart';
import 'package:project_gmastereki/database/database_helper.dart';
import 'package:project_gmastereki/model_sqflite/schedule_model.dart';

class Schedule extends StatefulWidget {
  const Schedule({Key? key}) : super(key: key);

  @override
  _ScheduleState createState() => _ScheduleState();
}

class _ScheduleState extends State<Schedule> {
  int? selectedId;
  final textController = TextEditingController();
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      home: Scaffold(
        appBar: AppBar(title: TextField(
          controller: textController,
        ),),
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
                      child: Card(
                        color: selectedId == schedule.id
                            ? Colors.white70
                            : Colors.white,
                        child: ListTile(
                          title: Text(schedule.name),
                          onTap: () {
                            if (selectedId == null) {
                              textController.text = schedule.name;
                              selectedId = schedule.id;
                            } else {
                              textController.text = '';
                              selectedId = null;
                            }
                          },
                          onLongPress: () {
                            setState(() {
                              DatabaseHelper.instance.remove(schedule.id!);
                            });
                          },
                        ),
                      ),
                    );
                  }).toList(),
                );
              }),
        ),
        floatingActionButton: FloatingActionButton(
          child: const Icon(Icons.save),
          onPressed: () async {
            selectedId != null
                ? await DatabaseHelper.instance.update(
              ScheduleModel(id: selectedId, name: textController.text),
            )
                :
            await DatabaseHelper.instance.add(
              ScheduleModel(name: textController.text),
            );
            setState(() {
              textController.clear();
              selectedId = null;
            });
          },
        ),
      ),
    );
  }
}



