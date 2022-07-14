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
                  child: FutureBuilder<String>(
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

  Future<String> getXMLData() async {
    var url = "http://192.168.0.101:5500//data/" + window.btoa(filename.path);
    var response = await http.get(Uri.parse(url));
    var data1;
    //var concatenate = StringBuffer();
    List<dynamic> datalist = [];
    List<String> datalist2 = [];

    if (response.statusCode == 200) {
      Xml2Json xml2json = Xml2Json();
      xml2json.parse(response.body);
      var json = xml2json.toGData();
      print('========================================');
      //print(json);

      data1 = jsonDecode(json);
      print('========================================');
      List data2 = data1['catalog']['loglist'];
      final List<String> strs2 = data2.map((e) => e.toString()).toList();
      datalist2 = strs2;

      print('========================================');
      for (int i = 0; i < data2.length; i++) {
        datalist.add(data2[i]['log']);
        print(data2[i]['log']);
      }
    }

    final String jsonObject = datalist2.join(', ');
    //print(jsonObject);
    print('========================================');

    /*  final myTransformer = Xml2Json();
    final myTransformer2 = Xml2Json();

    // Parse a simple XML string

    myTransformer.parse(goodXmlString);
    myTransformer2.parse(goodxmlString2);

    print('XML string');
    print(goodXmlString);
    print('');
    print(goodxmlString2);
    print('');

    // Transform to JSON using Badgerfish
    var json = myTransformer.toBadgerfish();
    var json2 = myTransformer2.toBadgerfish();

    print('Badgerfish');
    print('');
    print(json);
    print('');
    print(json2);
    print('');

    // Transform to JSON using GData
    json = myTransformer.toGData();
    json2 = myTransformer.toGData();
    print('GData');
    print('');
    print(json);
    print('');
    print(json2);
    print('');

    // Transform to JSON using Parker
    json = myTransformer.toParker();
    json2 = myTransformer2.toParker();
    print('Parker');
    print('');
    print(json);
    print('');
    print(json2);
    print('');

    // Transform to JSON using ParkerWithAttrs
    json = myTransformer.toParkerWithAttrs();
    json2 = myTransformer2.toParkerWithAttrs();
    print('ParkerWithAttrs');
    print('');
    print(json);
    print('');
    print(json2);
    print('');

    // Transform to JSON using ParkerWithAttrs
    // A node in XML should be an array, but if there is only one element in the array,
    // it will only be parsed into an object, so we need to specify the node as an array
    json = myTransformer2.toParkerWithAttrs(array: ['contact']);
    print('ParkerWithAttrs, specify the node as an array');
    print('');
    print(json);
 */
    return "";
  }
}
