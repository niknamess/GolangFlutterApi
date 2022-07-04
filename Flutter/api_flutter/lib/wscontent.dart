import 'package:flutter/material.dart';
import 'package:api_flutter/NavDrawer.dart';
import 'package:path/path.dart';
//import 'dart:html';
//import 'package:flutter/material.dart';
import 'package:web_socket_channel/web_socket_channel.dart';

//import 'package:web_socket_channel/io.dart';
//import 'package:web_socket_channel/status.dart' as status;

class initWS extends StatelessWidget {
  static const String routeName = '/initws';
  //final Filename filename;
  initWS({super.key, required this.filename});
  final Filename filename;
  final _channel = WebSocketChannel.connect(
    Uri.parse(
        'ws://localhost:15000/ws/L3Zhci9sb2NhbC9sb2dpMi9yZXBkYXRhL2dlbl9sb2dzX2NvZGVkNTEwMQ=='),
  );
  /* var channel1 = IOWebSocketChannel.connect('ws://' +
      '192.168.0.101' +
      ':5500' +
      '/ws/' +
      'L3Zhci9sb2NhbC9sb2dpMi9yZXBkYXRhL2dlbl9sb2dzX2NvZGVkNjEwMQ=='); */
  //final Filename snapshot;
  @override
  Widget build(BuildContext context) {
    /* final _channel = WebSocketChannel.connect(
      Uri.parse('wss://' +
          '192.168.0.101' +
          ':5500' +
          '/ws/' +
          window.btoa(filename.path)),
    ); */
    //final filename = ModalRoute.of(context)!.settings.arguments as Todo;

    return new Scaffold(
        appBar: AppBar(
          title: Text(basename(filename.path)),
        ),
        drawer: NavDrawer(),
        body: Center(
            child: StreamBuilder(
          stream: _channel.stream,
          builder: (context, snapshot) {
            return Text(snapshot.hasData ? '${snapshot.data}' : '');
          },
        )

            /*  Text("This is initWS page" +
              filename.path +
              "   " +
              window.btoa(filename.path)), */
            ));
  }

  @override
  void dispose() {
    _channel.sink.close();
    dispose();
  }
}
