// ignore_for_file: dead_code

import 'package:flutter/material.dart';
import 'package:api_flutter/NavDrawer.dart';
import 'package:api_flutter/Model.dart';

import 'dart:html';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'package:xml2json/xml2json.dart';
import 'package:json_table/json_table.dart';
import 'package:syncfusion_flutter_datagrid/datagrid.dart';

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

    return SafeArea(
        child: Scaffold(
      appBar: AppBar(
        title: Text(filename.path),
      ),
      body: FutureBuilder(
        future: getLogDataSource(filename),
        builder: (BuildContext context, AsyncSnapshot<dynamic> snapshot) {
          return snapshot.hasData
              ? SfDataGrid(source: snapshot.data, columns: getColumns())
              : Center(
                  child: CircularProgressIndicator(
                    strokeWidth: 3,
                  ),
                );
        },
      ),
    ));
  }

  Future<LogDataGridSource> getLogDataSource(filename) async {
    var logList = await generateLogList(filename);
    return LogDataGridSource(logList);
  }

  List<GridColumn> getColumns() {
    return <GridColumn>[
      GridTextColumn(
          columnName: 'module_name',
          width: 70,
          label: Container(
              padding: EdgeInsets.all(8),
              alignment: Alignment.centerLeft,
              child: Text('module_name',
                  overflow: TextOverflow.clip, softWrap: true))),
      GridTextColumn(
          columnName: 'app_path',
          width: 100,
          label: Container(
              padding: EdgeInsets.all(8),
              alignment: Alignment.centerRight,
              child: Text('app_path',
                  overflow: TextOverflow.clip, softWrap: true))),
      GridTextColumn(
          columnName: 'app_pid',
          width: 100,
          label: Container(
              padding: EdgeInsets.all(8),
              alignment: Alignment.centerLeft,
              child: Text('app_pid',
                  overflow: TextOverflow.clip, softWrap: true))),
      GridTextColumn(
          columnName: 'thread_id',
          width: 95,
          label: Container(
              padding: EdgeInsets.all(8),
              alignment: Alignment.centerRight,
              child: Text('thread_id',
                  overflow: TextOverflow.clip, softWrap: true))),
      GridTextColumn(
          columnName: 'time',
          width: 65,
          label: Container(
              padding: EdgeInsets.all(8),
              alignment: Alignment.centerLeft,
              child: Text('time'))),
      GridTextColumn(
          columnName: 'ulid',
          width: 65,
          label: Container(
              padding: EdgeInsets.all(8),
              alignment: Alignment.centerLeft,
              child: Text('ulid'))),
      GridTextColumn(
          columnName: 'type',
          width: 65,
          label: Container(
              padding: EdgeInsets.all(8),
              alignment: Alignment.centerLeft,
              child: Text('type'))),
      GridTextColumn(
          columnName: 'message',
          width: 65,
          label: Container(
              padding: EdgeInsets.all(8),
              alignment: Alignment.centerLeft,
              child: Text('message'))),
      GridTextColumn(
          columnName: 'ext_message',
          width: 65,
          label: Container(
              padding: EdgeInsets.all(8),
              alignment: Alignment.centerLeft,
              child: Text('extMessage'))),
    ];
  }
}

dynamic getPrettyJSONString(jsonObject) {
  JsonEncoder encoder = new JsonEncoder.withIndent('  ');
  String jsonString = encoder.convert(json.decode(jsonObject));
  return jsonString;
} //Ready json data

/*   Future<String> getXMLData(filename) async {
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
  } */
Future<List<Log>> generateLogList(filename) async {
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
  var decodedLogs = json.decode(test).cast<Map<String, dynamic>>();
  List<Log> logList =
      await decodedLogs.map<Log>((json) => Log.fromJson(json)).toList();
  return logList;
}

class LogDataGridSource extends DataGridSource {
  LogDataGridSource(this.logList) {
    buildDataGridRow();
  }
  late List<DataGridRow> dataGridRows;
  late List<Log> logList;

  @override
  DataGridRowAdapter? buildRow(DataGridRow row) {
    return DataGridRowAdapter(cells: [
      Container(
        child: Text(
          row.getCells()[0].value.toString(),
          overflow: TextOverflow.ellipsis,
        ),
        alignment: Alignment.centerLeft,
        padding: EdgeInsets.all(8.0),
      ),
      Container(
        alignment: Alignment.centerLeft,
        padding: EdgeInsets.all(8.0),
        child: Text(
          row.getCells()[1].value.toString(),
          overflow: TextOverflow.ellipsis,
        ),
      ),
      Container(
        alignment: Alignment.centerRight,
        padding: EdgeInsets.all(8.0),
        child: Text(
          row.getCells()[2].value.toString(),
          overflow: TextOverflow.ellipsis,
        ),
      ),
      Container(
        alignment: Alignment.centerRight,
        padding: EdgeInsets.all(8.0),
        child: Text(
          row.getCells()[3].value.toString(),
          overflow: TextOverflow.ellipsis,
        ),
      ),
      Container(
          alignment: Alignment.centerRight,
          padding: EdgeInsets.all(8.0),
          child: Text(
            row.getCells()[4].value.toString(),
            overflow: TextOverflow.ellipsis,
          )),
      Container(
        alignment: Alignment.centerRight,
        padding: EdgeInsets.all(8.0),
        child: Text(
          row.getCells()[5].value.toString(),
          overflow: TextOverflow.ellipsis,
        ),
      ),
      Container(
        alignment: Alignment.centerRight,
        padding: EdgeInsets.all(8.0),
        child: Text(
          row.getCells()[6].value.toString(),
          overflow: TextOverflow.ellipsis,
        ),
      ),
      Container(
        alignment: Alignment.centerRight,
        padding: EdgeInsets.all(8.0),
        child: Text(
          row.getCells()[7].value.toString(),
          overflow: TextOverflow.ellipsis,
        ),
      ),
      Container(
        alignment: Alignment.centerRight,
        padding: EdgeInsets.all(8.0),
        child: Text(
          row.getCells()[8].value.toString(),
          overflow: TextOverflow.ellipsis,
        ),
      )
    ]);
  }

  @override
  List<DataGridRow> get rows => dataGridRows;

  void buildDataGridRow() {
    dataGridRows = logList.map<DataGridRow>((dataGridRow) {
      return DataGridRow(cells: [
        DataGridCell(columnName: 'moduleName', value: dataGridRow.moduleName),
        DataGridCell<String>(columnName: 'appPath', value: dataGridRow.appPath),
        DataGridCell<String>(columnName: 'appPid', value: dataGridRow.appPid),
        DataGridCell<String>(columnName: 'thread', value: dataGridRow.threadId),
        DataGridCell<String>(columnName: 'time', value: dataGridRow.time),
        DataGridCell<String>(columnName: 'ulid', value: dataGridRow.ulid),
        DataGridCell<String>(columnName: 'type', value: dataGridRow.type),
        DataGridCell<String>(columnName: 'message', value: dataGridRow.message),
        DataGridCell<String>(columnName: 'extM', value: dataGridRow.extMessage),
      ]);
    }).toList(growable: false);
  }
}
