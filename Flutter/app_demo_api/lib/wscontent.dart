import 'package:flutter/material.dart';
import 'package:app_demo_api/NavDrawer.dart';
import 'package:path/path.dart';

class initWS extends StatelessWidget {
  static const String routeName = '/initws';
  //final Filename filename;
  initWS({super.key, required this.filename});
  final Filename filename;

  //final Filename snapshot;
  @override
  Widget build(BuildContext context) {
    //final filename = ModalRoute.of(context)!.settings.arguments as Todo;

    return new Scaffold(
        appBar: AppBar(
          title: Text(basename(filename.path)),
        ),
        drawer: NavDrawer(),
        body: Center(child: Text("This is initWS page" + filename.path)));
  }
}
