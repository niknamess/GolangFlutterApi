import 'package:flutter/material.dart';
import 'package:app_demo_api/NavDrawer.dart';

class initWS extends StatelessWidget {
  static const String routeName = '/initws';

  @override
  Widget build(BuildContext context) {
    return new Scaffold(
        appBar: AppBar(
          title: Text("initWS"),
        ),
        drawer: NavDrawer(),
        body: Center(child: Text("This is initWS page")));
  }
}
