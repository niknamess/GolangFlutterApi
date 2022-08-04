import 'package:flutter/material.dart';
import 'package:api_flutter/screens/sidebar.dart';
import 'package:api_flutter/screens/fitches_widgets.dart';

import 'dart:io';

import 'package:flutter/foundation.dart';

void enablePlatformOverrideForDesktop() {
  if (!kIsWeb && (Platform.isMacOS || Platform.isWindows || Platform.isLinux)) {
    debugDefaultTargetPlatformOverride = TargetPlatform.fuchsia;
  }
}

void main() {
  // enablePlatformOverrideForDesktop();

  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Logi2 Demo',
      theme: ThemeData(
        primarySwatch: Colors.orange,
      ),
      debugShowCheckedModeBanner: false,
      initialRoute: '/',
      home: const MyHomePage(),
    );
  }
}

class MyHomePage extends StatefulWidget {
  const MyHomePage({super.key});

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
          title: const Text("Flutter Logi2 Demo"),
        ),
        body: LayoutBuilder(builder: (context, constraints) {
          return Column(
            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
            children: [
              SizedBox(
                  width: constraints.maxWidth * 0.55,
                  height: 50.0,
                  child: const InputX()),
              SizedBox(
                  width: constraints.maxWidth * 0.55,
                  height: constraints.maxHeight * 0.55,
                  child: const Calendar()),
              SizedBox(
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
