import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:http/http.dart' as http;
import 'package:loading_indicator/loading_indicator.dart';
import 'package:project_gmastereki/custom/new_color.dart';
import 'package:project_gmastereki/model_network/notes_model.dart';
import 'package:project_gmastereki/network/network.dart';

class EditNote extends StatefulWidget {
  final NotesModel model;
  final VoidCallback reload1;
  const EditNote(this.model, this.reload1);
  @override
  _EditNoteState createState() => _EditNoteState();
}

final myTheme = NewColor();

class _EditNoteState extends State<EditNote> {

  final _key = new GlobalKey<FormState>();

  late String title, description, link;
  late TextEditingController txttitle, txtdescription, txtlink;
  setup() async{
    txttitle = TextEditingController(text: widget.model.title);
    txtdescription = TextEditingController(text: widget.model.description);
    txtlink = TextEditingController(text: widget.model.link);
  }

  static const List<Color> _kDefaultRainbowColors = [
    Colors.blue,
  ];

  check() {
    final form = _key.currentState;
    if (form!.validate()) {
      form.save();
      submit();
    } else {}
  }

  submit() async {
    showDialog(context: context,
        builder: (context){
          return AlertDialog(
            title: const Text("Processing"),
            content: Column(mainAxisSize: MainAxisSize.min,
              children: [
                SizedBox(
                    height: 50,
                    width: 50,
                    child: LoadingIndicator(indicatorType: Indicator.ballSpinFadeLoader, colors:_kDefaultRainbowColors,)),
                const SizedBox(height: 10,),
                Text("Loading..",style: TextStyle(color: myTheme.colors[color1]),)
              ],
            ),
          );
        }
    );
    final response = await http.post(Uri.parse(NetworkUrl.editNote()), body: {
      "id": widget.model.id,
      "title": title,
      "description": description,
      "link": link,
    });
    final data = jsonDecode(response.body);
    int value = data['value'];
    String message = data['message'];
    if (value == 1) {
      setState(() {
        widget.reload1();
        Navigator.pop(context);
        Navigator.pop(context);
        createPageToast(message);
      });
    } else {
      createPageToast(message);
    }
  }

  createPageToast(String toast) {
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
    // TODO: implement initState
    super.initState();
    setup();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Edit Profile'),
        backgroundColor: myTheme.colors[color1],
        elevation: 2.0,),
      body: Padding(
        padding: const EdgeInsets.all(8.0),
        child: Form(
            key: _key,
            child:SingleChildScrollView(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  SizedBox(height: 10,),
                  Theme(
                    data: Theme.of(context).copyWith(primaryColor: myTheme.colors[color1]),
                    child: TextFormField(
                      cursorColor: myTheme.colors[color1],
                      controller: txttitle,
                      onSaved: (e) => title = e!,
                      validator: (e) {
                        if (e!.isEmpty) {
                          return "Please enter title";
                        } else{
                          return null;
                        }
                      },
                      decoration: InputDecoration(labelText: 'title',
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(3.0),
                          )),
                    ),
                  ),
                  const SizedBox(height: 10,),
                  Theme(
                    data: Theme.of(context).copyWith(primaryColor: myTheme.colors[color1]),
                    child: TextFormField(
                      cursorColor: myTheme.colors[color1],
                      maxLines: 10,
                      controller: txtdescription,
                      onSaved: (e) => description = e!,
                      validator: (e) {
                        if (e!.isEmpty) {
                          return "Please enter description";
                        } else{
                          return null;
                        }
                      },
                      decoration: InputDecoration(labelText: 'description',
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(3.0),
                          )),
                    ),
                  ),
                  const SizedBox(height: 10,),
                  Theme(
                    data: Theme.of(context).copyWith(primaryColor: myTheme.colors[color1]),
                    child: TextFormField(
                      cursorColor: myTheme.colors[color1],
                      controller: txtlink,
                      onSaved: (e) => link = e!,
                      validator: (e) {
                        if (e!.isEmpty) {
                          return "Please enter link";
                        } else{
                          return null;
                        }
                      },
                      decoration: InputDecoration(labelText: 'link',
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(3.0),
                          )),
                    ),
                  ),
                  const SizedBox(height: 10,),
                  ElevatedButton(
                    onPressed: () {
                      check();
                    },
                    child: const Text("Save"),
                  ),
                ],
              ),
            )
        ),
      ),
    );
  }
}
