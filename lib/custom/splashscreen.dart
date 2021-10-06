import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:loading_indicator/loading_indicator.dart';
import 'dart:async';

import 'package:project_gmastereki/custom/introduction.dart';

class SplashScreen extends StatefulWidget {
  const SplashScreen({Key? key}) : super(key: key);

  @override
  _SplashScreenState createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen> {

  @override
  void initState(){
    super.initState();
    starSplashScreen();
  }

  starSplashScreen()async{
    var duration = const Duration(seconds: 5);
    return Timer(duration, (){
      Navigator.of(context).pushReplacement(
          MaterialPageRoute(builder: (_){
            return Introduction();
          })
      );
    });
  }

  static const List<Color> _kDefaultRainbowColors = [
    Colors.blue,
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        body: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              Image.asset(
                "assets/logo.png",
                height: 150,
              ),
              const SizedBox(height:10,),
              const Text('TO-DO-LIST',style:TextStyle(fontSize: 35,color: Colors.blue,fontFamily: 'Chalkboard',)),
              const SizedBox(height: 30,),
              SizedBox(
                  height: 30,
                  width: 30,
                  child: LoadingIndicator(indicatorType: Indicator.ballTrianglePath,  colors:_kDefaultRainbowColors, ))
            ],
          ),
        )
    );

  }
}
