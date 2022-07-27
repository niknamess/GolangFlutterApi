import 'package:http/http.dart' as http;
import 'dart:convert';
import 'package:xml2json/xml2json.dart';
import 'dart:async';
import 'package:api_flutter/model/Model.dart';

class LogiApi {
  static Future getLogs(filename) async {
    String value = filename.path;
    Codec<String, String> stringToBase64Url = utf8.fuse(base64Url);
    String encoded = stringToBase64Url.encode(value);
    var url = "http://192.168.0.101:5500//data/" + encoded;
    var response = await http.get(Uri.parse(url));

    /* var data1;
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
        //print(data2[i]['log']);
      }
    }
    var str = jsonEncode(datalistdy); */
    return response;
  }
}

Future<List<Log>> getLogList(filename) async {
  String value = filename.path;
  Codec<String, String> stringToBase64Url = utf8.fuse(base64Url);
  String encoded = stringToBase64Url.encode(value);

  var url = "http://192.168.0.101:5500//data/" + encoded;
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
      //print(data2[i]['log']);
    }
  }
  var test = jsonEncode(datalistdy);
  var decodedLogs = json.decode(test).cast<Map<String, dynamic>>();
  List<Log> logList =
      await decodedLogs.map<Log>((json) => Log.fromJson(json)).toList();

  // print("decodedLogs");

  //print(decodedLogs);
  return logList;
}
