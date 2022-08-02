
import 'dart:convert' as convert;

import 'package:http/http.dart' as http;
import 'dart:convert';
import 'package:xml2json/xml2json.dart';
import 'dart:async';
import 'package:api_flutter/model/Model.dart';

const Windows =  "http://192.168.0.111";
const Linux = "http://192.168.0.101";
const port = ":5500";
double fetchPercentage = 100.0;

class LogiApi {
 
  static Future getLogs(filename) async {
    String value = filename.path;
    Codec<String, String> stringToBase64Url = utf8.fuse(base64Url);
    String encoded = stringToBase64Url.encode(value);
    var url = Windows+port+"//data/" + encoded;
    var response = await http.get(Uri.parse(url));
    return response;
  }
  /*
  static Future<List<File>> fetchFromServerFile() async {
    var url = Windows+port+"//files/$fetchPercentage";
    var response = await http.get(Uri.parse(url));

    List<File> filetList = [];
    if (response.statusCode == 200) {
      var fileMap = convert.jsonDecode(response.body);
      for (final item in fileMap) {
        filetList.add(File.fromJson(item));
      }
    }
    //print(filetList);
    return filetList;
  }
  */
}

//full example decoded
Future<List<Log>> getLogList(filename) async {
  String value = filename.path;
  Codec<String, String> stringToBase64Url = utf8.fuse(base64Url);
  String encoded = stringToBase64Url.encode(value);

  var url = Windows+port+"//data/" + encoded;
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

  return logList;
}



