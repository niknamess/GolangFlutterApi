// ignore_for_file: dead_code

import 'package:api_flutter/Model.dart';
import 'package:flutter/material.dart';
import 'package:api_flutter/NavDrawer.dart';
import 'package:path/path.dart';
import 'dart:html';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'package:xml2json/xml2json.dart';
import 'package:json_table/json_table.dart';

//import 'package:flutter/material.dart';

//import 'package:web_socket_channel/io.dart';
//import 'package:web_socket_channel/status.dart' as status;

class initWS extends StatelessWidget {
  static const String routeName = '/initws';
  initWS({super.key, required this.filename});
  final Filename filename;
  //var url = "http://192.168.0.101:5500//data/" + window.btoa(filename.path);
  bool toggle = true;
  //final Filename snapshot;
  @override
  Widget build(BuildContext context) {
    // var url = "http://192.168.0.101:5500//data/" + window.btoa(filename.path);
    //final filename = ModalRoute.of(context)!.settings.arguments as Todo;

    return new Scaffold(
        appBar: AppBar(
          title: Text(basename(filename.path)),
        ),
        body: SingleChildScrollView(
            padding: EdgeInsets.all(16.0),
            child: Container(
              child: Center(
                  child: FutureBuilder<List<Log>>(
                future: getXMLData(),
                builder: (BuildContext context, AsyncSnapshot snapshot) {
                  if (snapshot.connectionState == ConnectionState.waiting) {
                    return Center(
                      child: CircularProgressIndicator(),
                    );
                  }

                  if (snapshot.hasError) {
                    return Center(
                      child: Text("${snapshot.error}",
                          style: TextStyle(color: Colors.redAccent)),
                    );
                  }

                  if (snapshot.hasData) {
                    return Column(children: [
                      JsonTable(
                        snapshot.data,
                        showColumnToggle: true,
                        allowRowHighlight: true,
                        rowHighlightColor: Colors.yellow[500]!.withOpacity(0.7),
                        paginationRowCount: 4,
                        onRowSelect: (index, map) {
                          print(index);
                          print(map);
                        },
                      ),
                      SizedBox(
                        height: 40.0,
                      ),
                      Text(
                          "Simple table which creates table direclty from json")
                    ]);
                  }
                  return new CircularProgressIndicator();
                },
              )
                  //Text(getXMLData()),
                  ),

              /* Text("This is initWS page" +
              filename.path +
              "   " +
              window.btoa(filename.path)), */
            )));
  }

  Future<List<Log>> getXMLData() async {
    var url = "http://192.168.0.101:5500//data/" + window.btoa(filename.path);
    var response = await http.get(Uri.parse(url));
    var data1;
    List<dynamic> datalist = [];
    List<String> target_list_2 = [];
    /*   final String jsonSample =
        '[{"name":"Ram","email":"ram@gmail.com","age":23,"income":"10Rs","country":"India","area":"abc"},{"name":"Shyam","email":"shyam23@gmail.com",'
        '"age":28,"income":"30Rs","country":"India","area":"abc","day":"Monday","month":"april"},{"name":"John","email":"john@gmail.com","age":33,"income":"15Rs","country":"India",'
        '"area":"abc","day":"Monday","month":"april"},{"name":"Ram","email":"ram@gmail.com","age":23,"income":"10Rs","country":"India","area":"abc","day":"Monday","month":"april"},'
        '{"name":"Shyam","email":"shyam23@gmail.com","age":28,"income":"30Rs","country":"India","area":"abc","day":"Monday","month":"april"},{"name":"John","email":"john@gmail.com",'
        '"age":33,"income":"15Rs","country":"India","area":"abc","day":"Monday","month":"april"},{"name":"Ram","email":"ram@gmail.com","age":23,"income":"10Rs","country":"India",'
        '"area":"abc","day":"Monday","month":"april"},{"name":"Shyam","email":"shyam23@gmail.com","age":28,"income":"30Rs","country":"India","area":"abc","day":"Monday","month":"april"},'
        '{"name":"John","email":"john@gmail.com","age":33,"income":"15Rs","country":"India","area":"abc","day":"Monday","month":"april"},{"name":"Ram","email":"ram@gmail.com","age":23,'
        '"income":"10Rs","country":"India","area":"abc","day":"Monday","month":"april"},{"name":"Shyam","email":"shyam23@gmail.com","age":28,"income":"30Rs","country":"India","area":"abc",'
        '"day":"Monday","month":"april"},{"name":"John","email":"john@gmail.com","age":33,"income":"15Rs","country":"India","area":"abc","day":"Monday","month":"april"}]'; */
    // List data2 = data1['catalog']['loglist'];
    // List<Loglist1> loglist = [];
    if (response.statusCode == 200) {
      //var raw = XmlDocument.parse(response.body);
      Xml2Json xml2json = Xml2Json();
      xml2json.parse(response.body);
      var json = xml2json.toBadgerfish();
      print('========================================');
      //print(json);

      data1 = jsonDecode(json);
      //print(data1);
      print('========================================');
      List data2 = data1['catalog']['loglist'];
      //print(data2);

      print('========================================');
      for (int i = 0; i < data2.length; i++) {
        datalist.add(data2[i]['log']);
        //print(data2[i]['log']);
      }
      //print(test);
    }
    //  print(datalist);
    final local = datalist.map<Log>((map) => Log.fromJson(map)).toList();
    print(local[0]);
    target_list_2 = List<String>.from(datalist);
    //print(target_list_2);

    String result = target_list_2.map((val) => val.trim()).join(',');
    print('========================================');
    print(result);
    //var data2;
    //JsonEncoder encoder = new JsonEncoder.withIndent('catalog');
    //String jsonString = json.decode(data2[2]['log']);
    //JsonEncoder encoder = new JsonEncoder.withIndent('  ');
    //String jsonString = jsonDecode(jsonSample);
    return local;
  }
}
