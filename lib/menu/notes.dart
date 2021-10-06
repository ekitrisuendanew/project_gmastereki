import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:flutter_speed_dial/flutter_speed_dial.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:project_gmastereki/menu/notes/add_note.dart';
import 'package:project_gmastereki/custom/new_color.dart';
import 'package:project_gmastereki/menu/notes/edit_note.dart';
import 'package:project_gmastereki/model_network/notes_model.dart';
import 'package:project_gmastereki/network/network.dart';
import 'package:http/http.dart' as http;
import 'package:project_gmastereki/custom/webview.dart';
import 'package:readmore/readmore.dart';

class Notes extends StatefulWidget {
  const Notes({Key? key}) : super(key: key);

  @override
  _NotesState createState() => _NotesState();
}

final myTheme = NewColor();

class _NotesState extends State<Notes> {
  List<NotesModel> list = [];
  String idUser = '1';

  NetworkUrl networkUrl = NetworkUrl();

  var loading = false;

  Future getNotes2()async{}
  Future getNotes() async {
    list.clear();
    setState(() {
      loading = true;
    });
    try {
      final response = await http.get(Uri.parse(NetworkUrl.getNote(idUser)));
      if (response.statusCode == 200) {
        Iterable it = jsonDecode(response.body);
        setState(() {
          for (Map i in it) {
            list.add(NotesModel.fromJson(i));
          }
          loading = false;
        });
      } else {
        setState(() {
          loading = false;
        });
      }
    } catch (e) {
      // ignore: avoid_print
      print(e.toString());
    }
  }

  _deleteCatatan(String id) async {
    final response =
        await http.post(Uri.parse(NetworkUrl.deleteNote()), body: {
      "id": id,
      "idUser": idUser,
    });
    final data = jsonDecode(response.body);
    int value = data['value'];
    String message = data['message'];
    if (value == 1) {
      setState(() {
        Navigator.pop(context);
        getNotes();
        detailToast(message);
      });
    } else {
      detailToast(message);
    }
  }

  dialogDeleteCatatan(String id) {
    showDialog(
      context: context,
      builder: (context) {
        return Dialog(
          child: ListView(
            padding: const EdgeInsets.all(8.0),
            shrinkWrap: true,
            children: <Widget>[
              const Padding(
                padding: EdgeInsets.all(8.0),
                child: Text(
                  "Are you sure you want to delete this Note?",
                  style: TextStyle(fontSize: 18.0, fontWeight: FontWeight.bold),
                ),
              ),
              const SizedBox(
                height: 10.0,
              ),
              Row(
                mainAxisAlignment: MainAxisAlignment.end,
                children: <Widget>[
                  InkWell(
                    onTap: () {
                      Navigator.pop(context);
                    },
                    child: const Padding(
                      padding: EdgeInsets.all(8.0),
                      child: Text("No"),
                    ),
                  ),
                  const SizedBox(
                    width: 16.0,
                  ),
                  InkWell(
                    onTap: () {
                      _deleteCatatan(id);
                    },
                    child: const Padding(
                      padding: EdgeInsets.all(8.0),
                      child: Text("Yes"),
                    ),
                  ),
                ],
              )
            ],
          ),
        );
      },
    );
  }

  detailToast(String toast) {
    return Fluttertoast.showToast(
        msg: toast,
        toastLength: Toast.LENGTH_SHORT,
        gravity: ToastGravity.TOP,
        timeInSecForIosWeb: 1,
        backgroundColor: Colors.orange,
        textColor: Colors.white);
  }

  @override
  void initState() {
    getNotes();
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Notes'),
        backgroundColor: Colors.blue,
        elevation: 2.0,
      ),
      body: ListView.builder(
        itemCount: list.length,
        itemBuilder: (context, i) {
          final b = list[i];
          return Padding(
            padding: const EdgeInsets.only(right: 8.0,left: 8.0,bottom: 4.0),
            child: Card(
              child: Padding(
                padding: const EdgeInsets.all(8.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    b.image=='-' ? const SizedBox() :
                    Image.network(
                      'https://ekitrisuenda.com/project_gmastereki/images/'+b.image,
                      fit: BoxFit.fill,
                    ),
                    const SizedBox(
                      height: 10,
                    ),
                    Text(
                      b.title,
                      style: TextStyle(
                        fontWeight: FontWeight.bold,
                        color: myTheme.colors[color1],
                      ),
                    ),
                    const SizedBox(
                      height: 10,
                    ),
                    ReadMoreText(
                      b.description,
                      trimLines: 2,
                      style: const TextStyle(color: Colors.black),
                      colorClickableText: Colors.blue,
                      trimMode: TrimMode.Line,
                      trimCollapsedText: 'Show more',
                      trimExpandedText: 'Show less',
                      moreStyle: const TextStyle(fontSize: 14, fontWeight: FontWeight.bold,color: Colors.blue),
                    ),
                    const SizedBox(
                      height: 10,
                    ),
                    InkWell(
                      onTap: (){
                        Navigator.push(context, MaterialPageRoute(
                            builder: (context)=>WebView1(b.link)
                        ));
                      },
                      child: Text(
                        b.link,
                        style: TextStyle(
                          fontWeight: FontWeight.bold,
                          color: myTheme.colors[color1],
                        ),
                      ),
                    ),
                    const SizedBox(
                      height: 10,
                    ),
                    Text(
                      b.createdAt,
                      style: const TextStyle(fontSize: 10, color: Colors.grey),
                    ),

                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                      children: [
                        ElevatedButton.icon(
                          onPressed: () =>
                            Navigator.push(
                              context,
                              MaterialPageRoute(
                                builder: (context) => EditNote(b,getNotes),
                              ),
                            ),
                          icon: const Icon(Icons.edit, size: 18),
                          label: const Text("Edit"),
                        ),
                        const SizedBox(
                          width: 10,
                        ),
                        ElevatedButton.icon(
                          onPressed: () {
                            dialogDeleteCatatan(b.id);
                          },
                          icon: const Icon(Icons.delete, size: 18),
                          label: const Text("Delete"),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ),
          );
        },
      ),
      floatingActionButton: SpeedDial(
        icon: Icons.add,
          onPress: (){
            Navigator.push(
              context,
              MaterialPageRoute(
                builder: (context) => AddNote(getNotes),
              ),
            );
          }
      ),
    );
  }
}
