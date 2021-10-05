import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:loading_indicator/loading_indicator.dart';
import 'package:http/http.dart' as http;
import 'package:project_gmastereki/custom/custom_color.dart';
import 'package:project_gmastereki/network/network.dart';

class AddNotes extends StatefulWidget {
  final VoidCallback reload;
  const AddNotes(this.reload);
  @override
  _AddNotesState createState() => _AddNotesState();
}

final myTheme = CustomColor();

class _AddNotesState extends State<AddNotes> {

  String idUser='1';
  late String gambar, judul, deskripsi, link;
  final _key = new GlobalKey<FormState>();

  var _autovalidate = false;
  check(){
    final form = _key.currentState;
    if (form!.validate()){
      form.save();
      submit();
    }else{
      setState(() {
        _autovalidate = true;
      });
    }
  }

  static const List<Color> _kDefaultRainbowColors = [
    Colors.red,
    Colors.orange,
    Colors.yellow,
    Colors.green,
    Colors.blue,
    Colors.indigo,
    Colors.purple,
  ];

  submit() async {
    showDialog(context: context,
        builder: (context){
          return AlertDialog(
            title: Text("Processing"),
            content: Container(
              child: Column(mainAxisSize: MainAxisSize.min,
                children: [
                  Container(
                      height: 50,
                      width: 50,
                      child: LoadingIndicator(indicatorType: Indicator.ballSpinFadeLoader, colors:_kDefaultRainbowColors,)),
                  SizedBox(height: 10,),
                  Text("Loading..",style: TextStyle(color: myTheme.colors[Color1]),)
                ],
              ),
            ),
          );
        }
    );
    final response = await http.post(Uri.parse(NetworkUrl.addCatatan()), body:{
      "idUser" : idUser,
      "gambar" : gambar,
      "judul" : judul,
      "deskripsi" : deskripsi,
      "link" : link,
    });

    final data = jsonDecode(response.body);
    int value = data['value'];
    String pesan = data['message'];
    if ( value==1){
      setState(() {
        widget.reload();
        Navigator.pop(context);
        Navigator.pop(context);
        CreateToast(pesan);
      });
    } else{
      Navigator.pop(context);
      CreateToast(pesan);
    }
  }




  CreateToast(String toast) {
    return Fluttertoast.showToast(
        msg: toast,
        toastLength: Toast.LENGTH_SHORT,
        gravity: ToastGravity.TOP,
        timeInSecForIosWeb: 1,
        backgroundColor: Colors.orange,
        textColor: Colors.white);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Tambah Catatan"),
        backgroundColor: myTheme.colors[Color1],
        elevation: 2.0,
      ),
      body: Form(
        key: _key,
        autovalidate: _autovalidate,
        child: ListView(
          padding: const EdgeInsets.all(16.0),
          children: <Widget>[
            Theme(
              data: Theme.of(context).copyWith(primaryColor: myTheme.colors[Color1]),
              child: TextFormField(
                cursorColor: myTheme.colors[Color1],
                onSaved: (e) => gambar = e!,
                validator: (e) {
                  if (e!.isEmpty) {
                    return "Jika tidak ada isi -";
                  } else{
                    return null;
                  }
                },
                decoration: InputDecoration(labelText: 'Link Gambar (format https)',
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(3.0),
                  ),

                ),
              ),
            ),
            const SizedBox(height: 15,),
            Theme(
              data: Theme.of(context).copyWith(primaryColor: myTheme.colors[Color1]),
              child: TextFormField(
                cursorColor: myTheme.colors[Color1],
                onSaved: (e) => judul = e!,
                validator: (e) {
                  if (e!.isEmpty) {
                    return "Silakan Masukkan Judul";
                  } else{
                    return null;
                  }
                },
                decoration: InputDecoration(labelText: 'Judul',
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(3.0),
                  ),

                ),
              ),
            ),
            const SizedBox(height: 15,),
            Theme(
              data: Theme.of(context).copyWith(primaryColor: myTheme.colors[Color1]),
              child: TextFormField(
                cursorColor: myTheme.colors[Color1],
                onSaved: (e) => deskripsi = e!,
                validator: (e) {
                  if (e!.isEmpty) {
                    return "Silakan Masukkan Deskripsi";
                  } else{
                    return null;
                  }
                },
                decoration: InputDecoration(labelText: 'Deskripsi',
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(3.0),
                  ),

                ),
              ),
            ),
            const SizedBox(height: 15,),
            Theme(
              data: Theme.of(context).copyWith(primaryColor: myTheme.colors[Color1]),
              child: TextFormField(
                cursorColor: myTheme.colors[Color1],
                onSaved: (e) => link = e!,
                validator: (e) {
                  if (e!.isEmpty) {
                    return "Jika tidak ada isi -";
                  } else{
                    return null;
                  }
                },
                decoration: InputDecoration(labelText: 'Link Website (format https)',
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(3.0),
                  ),

                ),
              ),
            ),
            const SizedBox(height: 15,),
            ButtonTheme(
              minWidth: MediaQuery.of(context).size.width,
              child: RaisedButton(
                shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(5.0)),
                onPressed: () {
                  check();
                },
                color: myTheme.colors[Color1],
                textColor: Colors.white,
                child: const Text(
                  "Simpan",
                  style: TextStyle(fontSize: 15.0),
                ),
              ),
            )
          ],
        ),
      ),
    );
  }
}
