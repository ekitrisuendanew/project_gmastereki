import 'dart:convert';
import 'dart:io';

import 'package:flutter/material.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:loading_indicator/loading_indicator.dart';
import 'package:http/http.dart' as http;
import 'package:project_gmastereki/custom/new_color.dart';
import 'package:project_gmastereki/menu/notes.dart';
import 'package:project_gmastereki/network/network.dart';
import 'package:path/path.dart' as path;
import 'package:async/async.dart';
import 'package:image_picker/image_picker.dart';

class AddNote extends StatefulWidget {
  final VoidCallback reload;
  const AddNote(this.reload, {Key? key}) : super(key: key);
  @override
  _AddNoteState createState() => _AddNoteState();
}

final myTheme = NewColor();
enum ImageSourceType { gallery, camera }

class _AddNoteState extends State<AddNote> {

  String idUser='1';
  late String title, description, link;
  final _key = GlobalKey<FormState>();

  var _autovalidate = false;
  check(){
    final form = _key.currentState;
    if (form!.validate()){
      form.save();
      save();
    }else{
      setState(() {
        _autovalidate = true;
      });
    }
  }

  static const List<Color> _kDefaultRainbowColors = [
    Colors.blue,
  ];

  var _image;
  var imagePicker;

  dialogProses() {
    showDialog(
        context: context,
        builder: (context) {
          return Dialog(
            child: ListView(
              padding: const EdgeInsets.all(16.0),
              shrinkWrap: true,
              children: <Widget>[
                InkWell(
                  onTap: () async {
                    var source = ImageSource.gallery;
                    XFile image = await imagePicker.pickImage(
                        source: source, imageQuality: 50, preferredCameraDevice: CameraDevice.front);
                    setState(() {
                      _image = File(image.path);
                    });
                    Navigator.pop(context);
                  },
                  child: Container(
                    padding: const EdgeInsets.all(16),
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(8),
                      border: Border.all(color: Colors.blue),
                    ),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text("Dari Galeri",style: TextStyle(color:myTheme.colors[color1]),),
                        Icon(Icons.image,color: myTheme.colors[color1])
                      ],
                    ),
                  ),
                ),
                const SizedBox(height: 10,),
                InkWell(
                  onTap: () async {
                    var source = ImageSource.camera;
                    XFile image = await imagePicker.pickImage(
                        source: source, imageQuality: 50, preferredCameraDevice: CameraDevice.front);
                    setState(() {
                      _image = File(image.path);
                    });
                    Navigator.pop(context);
                  },
                  child: Container(
                    padding: const EdgeInsets.all(16),
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(8),
                      border: Border.all(color: Colors.blue),
                    ),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text("Dari Kamera",style: TextStyle(color:myTheme.colors[color1]),),
                        Icon(Icons.camera_alt,color: myTheme.colors[color1],)
                      ],
                    ),
                  ),
                ),
              ],
            ),
          );
        });
  }

  save()async{
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
    try{
      var stream = http.ByteStream(DelegatingStream.typed(_image.openRead()));
      var length = await _image.length();
      var url = Uri.parse(NetworkUrl.addNote());
      var multipartFile= http.MultipartFile("image",stream,length, filename: path.basename(_image.path));
      var request = http.MultipartRequest("POST",url);

      request.files.add(multipartFile);
      request.fields['idUser']=idUser;
      request.fields['title']=title;
      request.fields['description']=description;
      request.fields['link']=link;

      var response = await request.send();
      response.stream.transform(utf8.decoder).listen((value) {
        final data = jsonDecode(value);
        int valueGet = data['value'];
        String message = data['message'];
        if(valueGet==1){
          widget.reload();
          Navigator.pop(context);
          Navigator.pop(context);
          createToast(message);
        }else{
          Navigator.pop(context);
          Navigator.pop(context);
          createToast(message);
        }
      });

    }catch(e){
      debugPrint("Error $e");
    }
  }

  createToast(String toast) {
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
    imagePicker = ImagePicker();
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
      body: Form(
        key: _key,
        autovalidate: _autovalidate,
        child: ListView(
          padding: const EdgeInsets.all(16.0),
          children: <Widget>[
            InkWell(
                onTap: dialogProses,
                child: _image == null ? Image.asset("assets/img.png",
                  fit: BoxFit.cover,
                ) : Image.file(_image, fit: BoxFit.cover,)
            ),
            const SizedBox(height: 15,),
            Theme(
              data: Theme.of(context).copyWith(primaryColor: myTheme.colors[color1]),
              child: TextFormField(
                cursorColor: myTheme.colors[color1],
                onSaved: (e) => title = e!,
                validator: (e) {
                  if (e!.isEmpty) {
                    return "Please Enter Title";
                  } else{
                    return null;
                  }
                },
                decoration: InputDecoration(labelText: 'Title',
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(3.0),
                  ),

                ),
              ),
            ),
            const SizedBox(height: 15,),
            Theme(
              data: Theme.of(context).copyWith(primaryColor: myTheme.colors[color1]),
              child: TextFormField(
                maxLines: 10,
                cursorColor: myTheme.colors[color1],
                onSaved: (e) => description = e!,
                validator: (e) {
                  if (e!.isEmpty) {
                    return "Please Enter Description";
                  } else{
                    return null;
                  }
                },
                decoration: InputDecoration(labelText: 'Description',
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(3.0),
                  ),

                ),
              ),
            ),
            const SizedBox(height: 15,),
            Theme(
              data: Theme.of(context).copyWith(primaryColor: myTheme.colors[color1]),
              child: TextFormField(
                cursorColor: myTheme.colors[color1],
                onSaved: (e) => link = e!,
                validator: (e) {
                  if (e!.isEmpty) {
                    return "If there is no content -";
                  } else{
                    return null;
                  }
                },
                decoration: InputDecoration(labelText: 'Website Link (https format)',
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(3.0),
                  ),

                ),
              ),
            ),
            const SizedBox(height: 15,),
            ElevatedButton(
              onPressed: () {
               check();
              },
              child: const Text("Save"),
            ),
          ],
        ),
      ),
    );
  }
}
