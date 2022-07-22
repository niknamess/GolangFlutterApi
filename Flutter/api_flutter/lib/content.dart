// ignore_for_file: dead_code

import 'package:flutter/material.dart';
import 'package:api_flutter/NavDrawer.dart';
import 'package:api_flutter/Model.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'package:xml2json/xml2json.dart';
import 'package:syncfusion_flutter_datagrid/datagrid.dart';
import 'package:syncfusion_flutter_core/theme.dart';
import 'package:intl/intl.dart';

class initWS extends StatefulWidget {
  final Filename filename;

  initWS({required this.filename});
  print(filename);

  _initWSState createState() => _initWSState();

  @override
  dynamic noSuchMethod(Invocation invocation) => super.noSuchMethod(invocation);
}

List<Log> paginatedDataSource = [];
List<Log> _logs = [];
final int rowsPerPage = 10;

class _initWSState extends State<initWS> {
  bool toggle = true;
  late LogDataSource _logDataSource;

  bool showLoadingIndicator = true;
  double pageCount = 0;

  @override
  void initState() {
    _logDataSource = LogDataSource();

    //dynamic filename = widget.filename;
    //print(filename.path);
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    //late LogDataSource _logDataSource;
    //_logDataSource = LogDataSource();
    dynamic filename = widget.filename;
    return SafeArea(
        child: Scaffold(
      appBar: AppBar(
        title: Text(filename.path),
      ),
      body: LayoutBuilder(
        builder: (context, constraints) {
          return Row(children: [
            Column(
              children: [
                SizedBox(
                    height: constraints.maxHeight - 60,
                    width: constraints.maxWidth,
                    child: buildStack(constraints)),
                Container(
                  child: FutureBuilder<List<Log>>(
                      future: getLogDataSource(filename),
                      builder: (BuildContext context,
                          AsyncSnapshot<dynamic> snapshot) {
                        return snapshot.hasData
                            ? Container(
                                height: 60,
                                width: constraints.maxWidth,
                                child: SfDataPager(
                                  pageCount: pageCount =
                                      (snapshot.data.length / rowsPerPage)
                                          .ceilToDouble(),
                                  direction: Axis.horizontal,
                                  onPageNavigationStart: (int pageIndex) {
                                    setState(() {
                                      showLoadingIndicator = true;
                                    });
                                  },
                                  delegate: _logDataSource,
                                  onPageNavigationEnd: (int pageIndex) {
                                    setState(() {
                                      showLoadingIndicator = false;
                                    });
                                  },
                                ))
                            : Center(
                                /*  child: CircularProgressIndicator(
                                  strokeWidth: 3,
                                ), */
                                );
                      }),
                )
              ],
            ),
          ]);
        },
      ),
    ));
  }

  Widget _buildLoadingScreen() {
    return Center(
      child: Container(
        width: 50,
        height: 50,
        child: CircularProgressIndicator(),
      ),
    );
  }
/* 
  @override
  Widget build(BuildContext context) {
    dynamic filename = widget.filename;
    return SafeArea(
        child: Scaffold(
            appBar: AppBar(
              title: Text(filename.path),
            ),
            body: SfDataGridTheme(
                data: SfDataGridThemeData(
                    rowHoverColor: Colors.yellow,
                    rowHoverTextStyle: TextStyle(
                      color: Colors.red,
                      fontSize: 14,
                    )),
                child: Container(
                  child: FutureBuilder(
                    future: getLogDataSource(filename),
                    builder: (BuildContext context,
                        AsyncSnapshot<dynamic> snapshot) {
                      return snapshot.hasData
                          ? SfDataGrid(
                              source: snapshot.data, columns: getColumns())
                          : Center(
                              child: CircularProgressIndicator(
                                strokeWidth: 3,
                              ),
                            );
                    },
                  ),
                ))));
  } */

  Widget buildDataGrid(BoxConstraints constraint) {
    return SfDataGrid(
        source: _logDataSource,
        columnWidthMode: ColumnWidthMode.fill,
        columns: <GridColumn>[
          GridTextColumn(
              columnName: 'type',
              width: 100,
              label: Container(
                  padding: EdgeInsets.all(8),
                  alignment: Alignment.centerLeft,
                  child: Text('type'))),
          GridTextColumn(
              columnName: 'module_name',
              width: 120,
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
                  alignment: Alignment.centerLeft,
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
                  alignment: Alignment.centerLeft,
                  child: Text('thread_id',
                      overflow: TextOverflow.clip, softWrap: true))),
          GridTextColumn(
              columnName: 'time',
              width: 150,
              label: Container(
                  padding: EdgeInsets.all(8),
                  alignment: Alignment.centerLeft,
                  child: Text('time'))),
          GridTextColumn(
              columnName: 'ulid',
              width: 150,
              label: Container(
                  padding: EdgeInsets.all(8),
                  alignment: Alignment.centerLeft,
                  child: Text('ulid'))),
          GridTextColumn(
              columnName: 'message',
              width: 300,
              label: Container(
                  padding: EdgeInsets.all(8),
                  alignment: Alignment.centerLeft,
                  child: Text('message'))),
          GridTextColumn(
              columnName: 'ext_message',
              width: 465,
              label: Container(
                  padding: EdgeInsets.all(8),
                  alignment: Alignment.centerLeft,
                  child: Text('extMessage'))),
        ]);
  }

  Widget buildStack(BoxConstraints constraints) {
    List<Widget> _getChildren() {
      final List<Widget> stackChildren = [];
      stackChildren.add(buildDataGrid(constraints));

      if (showLoadingIndicator) {
        stackChildren.add(Container(
          color: Colors.black12,
          width: constraints.maxWidth,
          height: constraints.maxHeight,
          child: Align(
            alignment: Alignment.center,
            child: CircularProgressIndicator(
              strokeWidth: 3,
            ),
          ),
        ));
      }

      return stackChildren;
    }

    return Stack(
      children: _getChildren(),
    );
  }

  Future<List<Log>> getLogDataSource(filename) async {
    // print("filename");
    //print(filename.path);

    var logList = await generateLogList(filename);
    //print("logList");
    //print(logList);
    (LogDataGridSource(logList));
    return logList;
  }
/*
  List<GridColumn> getColumns() {
    return <GridColumn>[
      GridTextColumn(
          columnName: 'type',
          width: 100,
          label: Container(
              padding: EdgeInsets.all(8),
              alignment: Alignment.centerLeft,
              child: Text('type'))),
      GridTextColumn(
          columnName: 'module_name',
          width: 120,
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
              alignment: Alignment.centerLeft,
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
              alignment: Alignment.centerLeft,
              child: Text('thread_id',
                  overflow: TextOverflow.clip, softWrap: true))),
      GridTextColumn(
          columnName: 'time',
          width: 150,
          label: Container(
              padding: EdgeInsets.all(8),
              alignment: Alignment.centerLeft,
              child: Text('time'))),
      GridTextColumn(
          columnName: 'ulid',
          width: 150,
          label: Container(
              padding: EdgeInsets.all(8),
              alignment: Alignment.centerLeft,
              child: Text('ulid'))),
      GridTextColumn(
          columnName: 'message',
          width: 300,
          label: Container(
              padding: EdgeInsets.all(8),
              alignment: Alignment.centerLeft,
              child: Text('message'))),
      GridTextColumn(
          columnName: 'ext_message',
          width: 465,
          label: Container(
              padding: EdgeInsets.all(8),
              alignment: Alignment.centerLeft,
              child: Text('extMessage'))),
    ];
  } */
}

dynamic getPrettyJSONString(jsonObject) {
  JsonEncoder encoder = new JsonEncoder.withIndent('  ');
  String jsonString = encoder.convert(json.decode(jsonObject));
  return jsonString;
} //Ready json data

Future<List<Log>> generateLogList(filename) async {
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

class LogDataGridSource extends DataGridSource {
  LogDataGridSource(this.logList) {
    buildDataGridRow();
  }
  late List<DataGridRow> dataGridRows;
  late List<Log> logList;

  @override
  DataGridRowAdapter? buildRow(DataGridRow row) {
    var number = int.parse(row.getCells()[0].value.toString());
    var Typestr;
    Color? color;
    switch (number) {
      // The switch statement must be told to exit, or it will execute every case.
      case 0:
        Typestr = "INFO";
        color = Color.fromRGBO(180, 252, 181, 1);
        break;
      case 1:
        Typestr = "DEBUG";
        color = Color.fromRGBO(160, 160, 160, 1);
        break;
      case 2:
        Typestr = "WARNING";
        color = Color.fromRGBO(255, 252, 155, 1);
        break;
      case 3:
        Typestr = "ERROR";
        color = Color.fromRGBO(253, 177, 177, 1);
        break;
      case 4:
        Typestr = "FATAL";
        color = Color.fromARGB(255, 229, 88, 17);

        break;
    }
    //converter for time
    //converter
    return DataGridRowAdapter(color: color, cells: [
      Container(
        child: Text(
          // style: TextStyle(color: Color.fromRGBO(180, 252, 181, 1)),
          Typestr,
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
        alignment: Alignment.centerLeft,
        padding: EdgeInsets.all(8.0),
        child: Text(
          row.getCells()[2].value.toString(),
          overflow: TextOverflow.ellipsis,
        ),
      ),
      Container(
        alignment: Alignment.centerLeft,
        padding: EdgeInsets.all(8.0),
        child: Text(
          row.getCells()[3].value.toString(),
          overflow: TextOverflow.ellipsis,
        ),
      ),
      Container(
          alignment: Alignment.centerLeft,
          padding: EdgeInsets.all(8.0),
          child: Text(
            row.getCells()[4].value.toString(),
            overflow: TextOverflow.ellipsis,
          )),
      Container(
        alignment: Alignment.centerLeft,
        padding: EdgeInsets.all(8.0),
        child: Text(
          row.getCells()[5].value.toString(),
          overflow: TextOverflow.ellipsis,
        ),
      ),
      Container(
        alignment: Alignment.centerLeft,
        padding: EdgeInsets.all(8.0),
        child: Text(
          row.getCells()[6].value.toString(),
          overflow: TextOverflow.ellipsis,
        ),
      ),
      Container(
        alignment: Alignment.centerLeft,
        padding: EdgeInsets.all(8.0),
        child: Text(
          row.getCells()[7].value.toString(),
          overflow: TextOverflow.ellipsis,
        ),
      ),
      Container(
        alignment: Alignment.centerLeft,
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
        DataGridCell<String>(columnName: 'type', value: dataGridRow.type),
        DataGridCell(columnName: 'moduleName', value: dataGridRow.moduleName),
        DataGridCell<String>(columnName: 'appPath', value: dataGridRow.appPath),
        DataGridCell<String>(columnName: 'appPid', value: dataGridRow.appPid),
        DataGridCell<String>(columnName: 'thread', value: dataGridRow.threadId),
        DataGridCell<String>(columnName: 'time', value: dataGridRow.time),
        DataGridCell<String>(columnName: 'ulid', value: dataGridRow.ulid),
        //DataGridCell<String>(columnName: 'type', value: dataGridRow.type),
        DataGridCell<String>(columnName: 'message', value: dataGridRow.message),
        DataGridCell<String>(columnName: 'extM', value: dataGridRow.extMessage),
      ]);
    }).toList(growable: false);
  }
}

class LogDataSource extends DataGridSource {
  EmployeeDataSource() {
    paginatedDataSource = _logs.getRange(0, 10).toList();
    buildDataGridRows();
  }

  List<DataGridRow> _employeeData = [];

  @override
  List<DataGridRow> get rows => _employeeData;

  @override
  Future<bool> handlePageChange(int oldPageIndex, int newPageIndex) async {
    await Future.delayed(const Duration(seconds: 3));
    int startIndex = newPageIndex * rowsPerPage;
    int endIndex = startIndex + rowsPerPage;
    if (startIndex < _logs.length) {
      if (endIndex > _logs.length) {
        endIndex = _logs.length;
      }
      paginatedDataSource =
          _logs.getRange(startIndex, endIndex).toList(growable: false);
      buildDataGridRows();
    } else {
      paginatedDataSource = [];
    }
    notifyListeners();
    return true;
  }

  void buildDataGridRows() {
    _employeeData = paginatedDataSource
        .map<DataGridRow>((e) => DataGridRow(cells: [
              DataGridCell<String>(columnName: 'type', value: e.type),
              DataGridCell(columnName: 'moduleName', value: e.moduleName),
              DataGridCell<String>(columnName: 'appPath', value: e.appPath),
              DataGridCell<String>(columnName: 'appPid', value: e.appPid),
              DataGridCell<String>(columnName: 'thread', value: e.threadId),
              DataGridCell<String>(columnName: 'time', value: e.time),
              DataGridCell<String>(columnName: 'ulid', value: e.ulid),
              //DataGridCell<String>(columnName: 'type', value: dataGridRow.type),
              DataGridCell<String>(columnName: 'message', value: e.message),
              DataGridCell<String>(columnName: 'extM', value: e.extMessage),
            ]))
        .toList();
  }

  @override
  DataGridRowAdapter buildRow(DataGridRow row) {
    return DataGridRowAdapter(
        cells: row.getCells().map<Widget>((e) {
      return Container(
        alignment: Alignment.center,
        padding: const EdgeInsets.symmetric(horizontal: 16.0),
        child: Text(e.value.toString()),
      );
    }).toList());
  }
}
