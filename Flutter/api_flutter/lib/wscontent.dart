import 'package:flutter/material.dart';
import 'package:api_flutter/NavDrawer.dart';
import 'package:path/path.dart';
import 'dart:html';
import 'package:http/http.dart' as http;

//import 'package:flutter/material.dart';
import 'package:web_socket_channel/web_socket_channel.dart';

//import 'package:web_socket_channel/io.dart';
//import 'package:web_socket_channel/status.dart' as status;

class initWS extends StatelessWidget {
  static const String routeName = '/initws';
  initWS({super.key, required this.filename});
  final Filename filename;
  //var url = "http://192.168.0.101:5500//data/" + window.btoa(filename.path);

  //final Filename snapshot;
  @override
  Widget build(BuildContext context) {
    // var url = "http://192.168.0.101:5500//data/" + window.btoa(filename.path);

    //final filename = ModalRoute.of(context)!.settings.arguments as Todo;

    return new Scaffold(
        appBar: AppBar(
          title: Text(basename(filename.path)),
        ),
        drawer: NavDrawer(),
        body: Center(
          child: Text("This is initWS page" +
              filename.path +
              "   " +
              window.btoa(filename.path)),
        ));
  }

  Future<List> fetchFromXml() async {
    var url = "http://192.168.0.101:5500//data/" + window.btoa(filename.path);
    var response = await http.get(Uri.parse(url));

    ;
  }
}
