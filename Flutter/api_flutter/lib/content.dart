// ignore_for_file: dead_code

import 'package:flutter/material.dart';
import 'package:api_flutter/NavDrawer.dart';
import 'dart:html';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'package:xml2json/xml2json.dart';
import 'package:json_table/json_table.dart';

class initWS extends StatefulWidget {
  final Filename filename;

  initWS({required this.filename});
  //final filename filename;
  print(filename);

  _initWSState createState() => _initWSState();

  @override
  dynamic noSuchMethod(Invocation invocation) => super.noSuchMethod(invocation);
}

class _initWSState extends State<initWS> {
  bool toggle = true;

  @override
  Widget build(BuildContext context) {
    dynamic filename = widget.filename;

    String truejson;

    return Scaffold(
      appBar: AppBar(
        title: Text(filename.path),
      ),
      body: FutureBuilder<String>(
          future: getXMLData(filename),
          builder: (BuildContext context, AsyncSnapshot<dynamic> snapshot) {
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
              truejson = snapshot.data;
              var json1 = jsonDecode(truejson);

              return Column(
                children: [
                  JsonTable(
                    json1,
                    showColumnToggle: true,
                    allowRowHighlight: true,
                    rowHighlightColor: Colors.yellow[500]!.withOpacity(0.7),
                    paginationRowCount: 20,
                    onRowSelect: (index, map) {
                      //print(index);
                      //print(map);
                    },
                  ),
                  SizedBox(
                    height: 40.0,
                  ),
                  Text("Created by me")
                ],
              );
            }

            return new CircularProgressIndicator();
          }),
      floatingActionButton: FloatingActionButton(
          child: Icon(Icons.grid_on),
          onPressed: () {
            setState(
              () {
                toggle = !toggle;
              },
            );
          }),
    );
  }

  dynamic getPrettyJSONString(jsonObject) {
    JsonEncoder encoder = new JsonEncoder.withIndent('  ');
    String jsonString = encoder.convert(json.decode(jsonObject));
    return jsonString;
  } //Ready json data

  Future<String> getXMLData(filename) async {
    var url = "http://192.168.0.101:5500//data/" + window.btoa(filename.path);
    var response = await http.get(Uri.parse(url));
    var data1;
    dynamic datalistdy = [];

    if (response.statusCode == 200) {
      Xml2Json xml2json = Xml2Json();
      xml2json.parse(response.body);
      var json = xml2json.toGData();
      data1 = jsonDecode(json);
      dynamic data2 = data1['catalog']['loglist'];
      for (int i = 0; i < data2.length; i++) {
        data2.removeWhere((e) => e['log'] == null);
        datalistdy.add(data2[i]['log']);
      }
    }
    var test = jsonEncode(datalistdy);
    return test;
  }
}
