import 'package:flutter/material.dart';
import 'package:loading_indicator/loading_indicator.dart';
import 'package:project_gmastereki/custom/custom_color.dart';
import 'package:webview_flutter/webview_flutter.dart';

final myTheme = CustomColor();

class WebView1 extends StatefulWidget {
  final String link;
  WebView1(this.link);
  @override
  _WebView1State createState() => _WebView1State();
}

class _WebView1State extends State<WebView1> {
  static const List<Color> _kDefaultRainbowColors = [
    Colors.blue,
    Colors.indigo,
    Colors.purple,
    Colors.red,
    Colors.orange,
    Colors.yellow,
    Colors.green,
  ];

  bool isLoading=true;

  @override
  Widget build(BuildContext context) {

    return Scaffold(
      appBar: AppBar(
        title: const Text("Back"),
        leading: Padding(
          padding: const EdgeInsets.only(left: 15),
          child: IconButton(
            icon: const Icon(Icons.arrow_back),
            onPressed: (){
              Navigator.pop(context);
            },
          ),
        ),
        backgroundColor: myTheme.colors[Color1],
        elevation: 0.0,
      ),
      body: Stack(
        children: [
          WebView(
            initialUrl: widget.link,
            javascriptMode: JavascriptMode.unrestricted,
            onPageFinished: (finish) {
              setState(() {
                isLoading = false;
              });
            },
          ),
          isLoading ? Center( child: SizedBox(
              height: 50,
              width: 50,
              child: LoadingIndicator(indicatorType: Indicator.pacman, colors:_kDefaultRainbowColors,)),)
              : const SizedBox(),
        ],
      ),
    );
  }
}


