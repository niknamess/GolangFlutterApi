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
import 'dart:convert' as convert;
import 'package:api_flutter/test/xml2json_test_strings.dart';

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
  final String jsonSample =
      '[{"module_name": "7TMCS TEST", "app_path": "/3/TEST/TEST", "app_pid": "10103", "thread_id": 0, "time": 582018000147040, "ulid":"01G514D4KMX40AGTW5RSH0NR7R", "type": "3", "message":"Ð¡Ð¾ÑÑÐ¾ÑÐ½Ð¸Ðµ \'110.99.215.211CÐµÑÐ²ÐµÑÐ¡_UDP/Ð¸Ð½Ð³\'", "ext_message": "Context:-- voidtmcs::AbstractMonitor::,Worcestershire"}, '
      '{"module_name": "7TMCS TEST", "app_path": "/3/TEST/TEST", "app_pid": "10106", "thread_id": 2, "time": 582018000149040, "ulid":"01G514D4KMX40AGTW5RSH0NR7R", "type": "3", "message":"Ð¡Ð¾ÑÑÐ¾ÑÐ½Ð¸Ðµ \'110.99.215.211CÐµÑÐ²ÐµÑÐ¡_UDP/Ð¸Ð½Ð³\'", "ext_message": "Context:  -- voidtmcs::AbstractMonitor::,Worcestershire"}]';

  bool toggle = true;

  @override
  Widget build(BuildContext context) {
    dynamic filename = widget.filename;
    // print("filename");

    //print(filename.path);
    //  var filename;
    var json = jsonDecode(jsonSample);
    var truejson;
    // print(jsonSample);
    // print(json);

    return Scaffold(
      body: SingleChildScrollView(
        padding: EdgeInsets.all(16.0),
        child: Container(
          child: toggle
              ? Column(
                  children: [
                    FutureBuilder<dynamic>(
                        future: getXMLData(filename),
                        builder: (BuildContext context,
                            AsyncSnapshot<dynamic> snapshot) {
                          if (snapshot.connectionState ==
                              ConnectionState.waiting) {
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

                            //return snapshot.data;
                          }
                          return new CircularProgressIndicator();
                        }),
                    JsonTable(
                      json,
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
                    Text("Simple table which creates table direclty from json")
                  ],
                )
              : Center(
                  child: Text(getPrettyJSONString(jsonSample)),
                ),
        ),
      ),
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

  String getPrettyJSONString(jsonObject) {
    JsonEncoder encoder = new JsonEncoder.withIndent('  ');
    String jsonString = encoder.convert(json.decode(jsonObject));
    return jsonString;
  } //Ready json data

  Future<dynamic> getXMLData(filename) async {
    //var filename;
    var url = "http://192.168.0.101:5500//data/" + window.btoa(filename.path);
    var response = await http.get(Uri.parse(url));
    var data1;
    dynamic datalistdy = [];

    if (response.statusCode == 200) {
      Xml2Json xml2json = Xml2Json();
      xml2json.parse(response.body);
      var json = xml2json.toGData();
      // print(json);
      data1 = jsonDecode(json);
      dynamic data2 = data1['catalog']['loglist'];
      print('========================================');
      for (int i = 0; i < data2.length; i++) {
        datalistdy.add(data2[i]['log']);
        //print(data2[i]['log']);
      }
    }
    //print(datalistdy);
    final List<String> dataliststr =
        datalistdy.map((e) => e.toString()).toList();
    //delete null
    for (int i = 0; i < 10; i++) {
      for (int i = 0; i < dataliststr.length; i++) {
        if (dataliststr[i] == 'null') {
          //print(dataliststr.length);

          print('================null========================');
          //print(dataliststr[i]);
          //print(i);

          bool result = dataliststr.remove('null');
          print(result); // true
          //print(dataliststr.length);
        }
      }
    }

    final String jsonObject = dataliststr.join(', ');
    var jsonFinalString =
        "[" + jsonObject.substring(0, jsonObject.length) + "]";
    //print(jsonFinalString);

    print(jsonFinalString.substring(0, 30));

    print(jsonFinalString.substring(
        jsonFinalString.length - 20, jsonFinalString.length));

    print('========================================');
    final dynamic jsonFinaldynamic = jsonFinalString;
    //formating
    //var json = jsonDecode(jsonFinalString);
    //JsonEncoder encoder = new JsonEncoder.withIndent('  ');
    //String jsonString = encoder.convert(json.decode(jsonFinalString));

    return json;
  }

  /* @override
  dynamic noSuchMethod(Invocation invocation) => super.noSuchMethod(invocation); */
}
