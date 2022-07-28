import 'package:flutter/material.dart';
import 'package:api_flutter/screens/sidebar.dart';
import 'package:api_flutter/screens/fitches_wiidgets.dart';

import 'dart:io';

import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:syncfusion_flutter_datepicker/datepicker.dart';

void enablePlatformOverrideForDesktop() {
  if (!kIsWeb && (Platform.isMacOS || Platform.isWindows || Platform.isLinux)) {
    debugDefaultTargetPlatformOverride = TargetPlatform.fuchsia;
  }
}

void main() {
  // enablePlatformOverrideForDesktop();

  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Logi2 Demo',
      theme: ThemeData(
        primarySwatch: Colors.orange,
      ),
      debugShowCheckedModeBanner: false,
      initialRoute: '/',
      home: MyHomePage(),
    );
  }
}

class MyHomePage extends StatefulWidget {
  @override
  _MyHomePageState createState() {
    return _MyHomePageState();
  }
}

class _MyHomePageState extends State<MyHomePage> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
        appBar: AppBar(
          title: Text("Flutter Logi2 Demo"),
        ),
        body: LayoutBuilder(builder: (context, constraints) {
          return Column(
            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
            children: [
              Container(
                  width: constraints.maxWidth * 0.55,
                  height: 50.0,
                  child: InputX()),
              Container(
                  width: constraints.maxWidth * 0.55,
                  height: constraints.maxHeight * 0.55,
                  child: Calendar()),
              Container(
                width: constraints.maxWidth * 0.55,
                height: constraints.maxHeight * 0.55,
                //child: Calendar()
              )
            ],
          );
        }),
        drawer: NavDrawer());
  }
}
