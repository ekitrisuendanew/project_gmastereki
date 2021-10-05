import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:flutter_speed_dial/flutter_speed_dial.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:project_gmastereki/add_catatan.dart';
import 'package:project_gmastereki/custom/custom_color.dart';
import 'package:project_gmastereki/model/catatan_model.dart';
import 'package:project_gmastereki/network/network.dart';
import 'package:http/http.dart' as http;
import 'package:project_gmastereki/webview.dart';
import 'package:readmore/readmore.dart';

class Catatan extends StatefulWidget {
  const Catatan({Key? key}) : super(key: key);

  @override
  _CatatanState createState() => _CatatanState();
}

final myTheme = CustomColor();

class _CatatanState extends State<Catatan> {
  List<CatatanModel> list = [];
  String idUser = '1';

  NetworkUrl networkUrl = NetworkUrl();

  var loading = false;

  Future getCatatan() async {
    list.clear();
    setState(() {
      loading = true;
    });
    try {
      final response = await http.get(Uri.parse(NetworkUrl.getCatatan(idUser)));
      if (response.statusCode == 200) {
        Iterable it = jsonDecode(response.body);
        setState(() {
          for (Map i in it) {
            list.add(CatatanModel.fromJson(i));
          }
          loading = false;
        });
      } else {
        setState(() {
          loading = false;
        });
      }
    } catch (e) {
      print(e.toString());
    }
  }

  _deleteCatatan(String id) async {
    final response =
        await http.post(Uri.parse(NetworkUrl.deleteCatatan()), body: {
      "id": id,
      "idUser": idUser,
    });
    final data = jsonDecode(response.body);
    int value = data['value'];
    String message = data['message'];
    if (value == 1) {
      setState(() {
        Navigator.pop(context);
        getCatatan();
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
            padding: EdgeInsets.all(8.0),
            shrinkWrap: true,
            children: <Widget>[
              const Padding(
                padding: EdgeInsets.all(8.0),
                child: Text(
                  "Anda yakin ingin menghapus Catatan ini?",
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
                      child: Text("Tidak"),
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
                      child: Text("Ya"),
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
    // TODO: implement initState
    super.initState();
    getCatatan();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Catatan'),
        backgroundColor: myTheme.colors[Color1],
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
                    b.gambar=='-' ? const SizedBox() :
                    Image.network(
                      'https://ekitrisuenda.com/project_gmastereki/images/'+b.gambar,
                      fit: BoxFit.fill,
                    ),
                    const SizedBox(
                      height: 10,
                    ),
                    Text(
                      b.judul,
                      style: TextStyle(
                        fontWeight: FontWeight.bold,
                        color: myTheme.colors[Color1],
                      ),
                    ),
                    const SizedBox(
                      height: 10,
                    ),
                    ReadMoreText(
                      b.deskripsi,
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
                          color: myTheme.colors[Color1],
                        ),
                      ),
                    ),
                    const SizedBox(
                      height: 10,
                    ),
                    Text(
                      b.created_ad,
                      style: const TextStyle(fontSize: 10, color: Colors.grey),
                    ),

                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                      children: [
                        ButtonTheme(
                          child: RaisedButton(
                            shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(5.0)),
                            onPressed: () {},
                            color: myTheme.colors[Color1],
                            textColor: Colors.white,
                            child: const Center(
                              child: Icon(
                                Icons.edit,
                                size: 17,
                              ),
                            ),
                          ),
                        ),
                        const SizedBox(
                          width: 10,
                        ),
                        ButtonTheme(
                          child: RaisedButton(
                            shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(5.0)),
                            onPressed: () {
                              dialogDeleteCatatan(b.id);
                            },
                            color: myTheme.colors[Color1],
                            textColor: Colors.white,
                            child: const Center(
                              child: Icon(
                                Icons.delete,
                                size: 17,
                              ),
                            ),
                          ),
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
        icon: Icons.settings,
          children: [
            SpeedDialChild(
              child: const Icon(Icons.add),
              label: 'Add Catatan',
              onTap: (){
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => AddCatatan(getCatatan),
                  ),
                );
              }),
            SpeedDialChild(
                child: const Icon(Icons.search),
                label: 'Search Catatan',
                onTap: (){
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) => AddCatatan(getCatatan),
                    ),
                  );
                }),
          ]
      ),
    );
  }
}
