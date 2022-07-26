// ignore_for_file: dead_code

import 'package:flutter/material.dart';
import 'package:api_flutter/NavDrawer.dart';
import 'package:api_flutter/Model.dart';
import 'package:syncfusion_flutter_core/theme.dart';
import 'package:syncfusion_flutter_datagrid/datagrid.dart';

import 'package:http/http.dart' as http;
import 'dart:convert';
import 'package:xml2json/xml2json.dart';
//import 'package:api_flutter/test/data.dart';

class initWS extends StatefulWidget {
  final Filename filename;

  initWS({required this.filename});
  //print(filename);

  _initWSState createState() => _initWSState();

  @override
  dynamic noSuchMethod(Invocation invocation) => super.noSuchMethod(invocation);
}

List<Log> paginatedDataSource = [];
List<Log> _log = [];
dynamic gg;
//List<Log> test1 = [];

final int rowsPerPage = 10;

class _initWSState extends State<initWS> {
  late LogDataSource _LogDataSource;
  //final Filename filename;

  bool showLoadingIndicator = true;
  double pageCount = 0;

  // _initWSState(this.filename);

  // get filename => this.filename;

  @override
  void initState() {
    super.initState();
    // dynamic filename = widget.filename;
  }

  @override
  Widget build(BuildContext context) {
    dynamic filename = widget.filename;
    //print(filename.path);
    return SafeArea(
        child: Scaffold(
            appBar: AppBar(
              title: Text(filename.path),
            ),
            body: LayoutBuilder(builder: (context, constraints) {
              return Row(children: [
                Container(
                    child: Column(children: [
                  SizedBox(
                      height: constraints.maxHeight - 60,
                      width: constraints.maxWidth,
                      child: buildStack(constraints)),
                  Container(
                      height: 60,
                      width: constraints.maxWidth,
                      child: FutureBuilder<List<Log>>(
                          future: getLogList(filename),
                          builder: (BuildContext context,
                              AsyncSnapshot<dynamic> snapshot) {
                            if (snapshot.hasError) {
                              return Center(
                                child: Text("${snapshot.error}",
                                    style: TextStyle(color: Colors.redAccent)),
                              );
                            }

                            if (snapshot.hasData) {
                              _log = snapshot.data;
                              _LogDataSource = LogDataSource();
                              pageCount =
                                  (_log.length / rowsPerPage).ceilToDouble();
                              print("+++++++++++++++++++++++++++++++");

                              print(pageCount);
                            }

                            return SfDataPager(
                              pageCount: pageCount,
                              direction: Axis.horizontal,
                              onPageNavigationStart: (int pageIndex) {
                                setState(() {
                                  showLoadingIndicator = true;
                                });
                              },
                              delegate: _LogDataSource,
                              onPageNavigationEnd: (int pageIndex) {
                                setState(() {
                                  showLoadingIndicator = false;
                                });
                              },
                            );
                          }))
                ]))
              ]);
            })));
  }

  Widget buildDataGrid(BoxConstraints constraint) {
    //var _LogDataSource;
    return SfDataGrid(
        source: _LogDataSource,
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
}

class LogDataSource extends DataGridSource {
  LogDataSource() {
    print("LogDataSource1");
    print(_log.length);
    paginatedDataSource = _log.getRange(0, 10).toList();
    buildDataGridRows();
  }

  List<DataGridRow> _LogData = [];

  @override
  List<DataGridRow> get rows => _LogData;

  @override
  Future<bool> handlePageChange(int oldPageIndex, int newPageIndex) async {
    await Future.delayed(const Duration(seconds: 3));
    int startIndex = newPageIndex * rowsPerPage;
    int endIndex = startIndex + rowsPerPage;
    print("LogDataSource2");
    print(_log.length);
    if (startIndex < _log.length) {
      if (endIndex > _log.length) {
        endIndex = _log.length;
      }
      paginatedDataSource =
          _log.getRange(startIndex, endIndex).toList(growable: false);
      buildDataGridRows();
    } else {
      paginatedDataSource = [];
    }
    notifyListeners();
    return true;
  }

  void buildDataGridRows() {
    _LogData = paginatedDataSource
        .map<DataGridRow>((e) => DataGridRow(cells: [
              DataGridCell<String>(columnName: 'type', value: e.type),
              DataGridCell(columnName: 'moduleName', value: e.moduleName),
              DataGridCell<String>(columnName: 'appPath', value: e.appPath),
              DataGridCell<String>(columnName: 'appPid', value: e.appPid),
              DataGridCell<String>(columnName: 'thread', value: e.threadId),
              DataGridCell<String>(columnName: 'time', value: e.time),
              DataGridCell<String>(columnName: 'ulid', value: e.ulid),
              DataGridCell<String>(columnName: 'message', value: e.message),
              DataGridCell<String>(columnName: 'extM', value: e.extMessage),
            ]))
        .toList();
  }

  @override
  DataGridRowAdapter buildRow(DataGridRow row) {
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
}
