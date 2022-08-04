import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:api_flutter/screens/sidebar.dart';
import 'package:api_flutter/model/Model.dart';
import 'package:api_flutter/data/data.dart';
import 'package:syncfusion_flutter_datagrid/datagrid.dart';
import 'package:xml2json/xml2json.dart';

class TableContent extends StatefulWidget {
  final Filename filename;

  const TableContent({super.key, required this.filename});
  //print(filename);

  @override
  // ignore: library_private_types_in_public_api
  _TableContent createState() => _TableContent(filename: filename);

  @override
  dynamic noSuchMethod(Invocation invocation) => super.noSuchMethod(invocation);
}

List<Log> paginatedDataSource = [];
List<Log> _log = <Log>[];
dynamic gg;

const int rowsPerPage = 10;

class _TableContent extends State<TableContent> {
  // ignore: non_constant_identifier_names
  late LogDataSource _LogDataSource;
  final Filename filename;
  _TableContent({required this.filename});
  //final Filename filename;

  bool showLoadingIndicator = true;
  double pageCount = 0;

  void getCharactersfromApi() async {
   // print(filename.path);
   // print("filename1");
    LogiApi.getLogs(filename).then((response) {
      setState(() {
        // ignore: prefer_typing_uninitialized_variables
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
        var str = jsonEncode(datalistdy);
        //  print(str);
        Iterable list = json.decode(str);
        _log = list.map((model) => Log.fromJson(model)).toList();
        _LogDataSource = LogDataSource();
        pageCount = (_log.length / rowsPerPage).ceilToDouble();
      });
    });
  }

  @override
  void initState() {
    super.initState();
    getCharactersfromApi();
  }

  @override
  Widget build(BuildContext context) {
    dynamic filename = widget.filename;
    // print("build");
    //print(filename.path);
    //print("build");
    return SafeArea(
        child: Scaffold(
            appBar: AppBar(
              title: Text(filename.path),
            ),
            body: LayoutBuilder(builder: (context, constraints) {
              return Row(children: [
                Column(children: [
                  SizedBox(
                  height: constraints.maxHeight - 60,
                  width: constraints.maxWidth,
                  child: buildStack(constraints)),
                  SizedBox(
                  height: 60,
                  width: constraints.maxWidth,
                  child: SfDataPager(
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
                  ))
                ])
              ]);
            })));
  }

  Widget buildDataGrid(BoxConstraints constraint) {
    return SfDataGrid(
        source: _LogDataSource,
        columnWidthMode: ColumnWidthMode.fill,
        allowSorting: true,
        allowMultiColumnSorting: true,
        showSortNumbers: true,
        columns: [
          GridColumn(
              columnName: 'type',
              width: 100,
              label: Container(
                  padding: const EdgeInsets.all(8),
                  alignment: Alignment.centerLeft,
                  child: const Text('type'))),
          GridColumn(
              columnName: 'module_name',
              width: 120,
              label: Container(
                  padding: const EdgeInsets.all(8),
                  alignment: Alignment.centerLeft,
                  child: const Text('module_name',
                      overflow: TextOverflow.clip, softWrap: true))),
          GridColumn(
              columnName: 'app_path',
              width: 100,
              label: Container(
                  padding: const EdgeInsets.all(8),
                  alignment: Alignment.centerLeft,
                  child: const Text('app_path',
                      overflow: TextOverflow.clip, softWrap: true))),
          GridColumn(
              columnName: 'app_pid',
              width: 100,
              label: Container(
                  padding: const EdgeInsets.all(8),
                  alignment: Alignment.centerLeft,
                  child: const Text('app_pid',
                      overflow: TextOverflow.clip, softWrap: true))),
          GridColumn(
              columnName: 'thread_id',
              width: 95,
              label: Container(
                  padding: const EdgeInsets.all(8),
                  alignment: Alignment.centerLeft,
                  child: const Text('thread_id',
                      overflow: TextOverflow.clip, softWrap: true))),
          GridColumn(
              columnName: 'time',
              width: 150,
              label: Container(
                  padding: const EdgeInsets.all(8),
                  alignment: Alignment.centerLeft,
                  child: const Text('time'))),
          GridColumn(
              columnName: 'ulid',
              width: 150,
              label: Container(
                  padding: const EdgeInsets.all(8),
                  alignment: Alignment.centerLeft,
                  child: const Text('ulid'))),
          GridColumn(
              columnName: 'message',
              width: 300,
              label: Container(
                  padding: const EdgeInsets.all(8),
                  alignment: Alignment.centerLeft,
                  child: const Text('message'))),
          GridColumn(
              columnName: 'ext_message',
              width: 465,
              label: Container(
                  padding: const EdgeInsets.all(8),
                  alignment: Alignment.centerLeft,
                  child: const Text('extMessage'))),
        ]);
  }

  Widget buildStack(BoxConstraints constraints) {
    // ignore: no_leading_underscores_for_local_identifiers
    List<Widget> _getChildren() {
      final List<Widget> stackChildren = [];
      stackChildren.add(buildDataGrid(constraints));

      if (showLoadingIndicator) {
        stackChildren.add(Container(
          color: Colors.black12,
          width: constraints.maxWidth,
          height: constraints.maxHeight,
          child: const Align(
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
}

class LogDataSource extends DataGridSource {
  LogDataSource() {
    // print("LogDataSource1");
    // print(_log.length);
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
   // print("LogDataSource2");
    //print(_log.length);
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
    // ignore: non_constant_identifier_names
    dynamic Typestr;
    Color? color;
    switch (number) {
      // The switch statement must be told to exit, or it will execute every case.
      case 0:
        Typestr = "INFO";
        color = const Color.fromRGBO(180, 252, 181, 1);
        break;
      case 1:
        Typestr = "DEBUG";
        color = const Color.fromRGBO(160, 160, 160, 1);
        break;
      case 2:
        Typestr = "WARNING";
        color = const Color.fromRGBO(255, 252, 155, 1);
        break;
      case 3:
        Typestr = "ERROR";
        color = const Color.fromRGBO(253, 177, 177, 1);
        break;
      case 4:
        Typestr = "FATAL";
        color = const Color.fromARGB(255, 229, 88, 17);

        break;
    }
    return DataGridRowAdapter(color: color, cells: [
      Container(
        alignment: Alignment.centerLeft,
        padding: const EdgeInsets.all(8.0),
        child: Text(
          // style: TextStyle(color: Color.fromRGBO(180, 252, 181, 1)),
          Typestr,
          overflow: TextOverflow.ellipsis,
        ),
      ),
      Container(
        alignment: Alignment.centerLeft,
        padding: const EdgeInsets.all(8.0),
        child: Text(
          row.getCells()[1].value.toString(),
          overflow: TextOverflow.ellipsis,
        ),
      ),
      Container(
        alignment: Alignment.centerLeft,
        padding: const EdgeInsets.all(8.0),
        child: Text(
          row.getCells()[2].value.toString(),
          overflow: TextOverflow.ellipsis,
        ),
      ),
      Container(
        alignment: Alignment.centerLeft,
        padding: const EdgeInsets.all(8.0),
        child: Text(
          row.getCells()[3].value.toString(),
          overflow: TextOverflow.ellipsis,
        ),
      ),
      Container(
          alignment: Alignment.centerLeft,
          padding: const EdgeInsets.all(8.0),
          child: Text(
            row.getCells()[4].value.toString(),
            overflow: TextOverflow.ellipsis,
          )),
      Container(
        alignment: Alignment.centerLeft,
        padding: const EdgeInsets.all(8.0),
        child: Text(
          row.getCells()[5].value.toString(),
          overflow: TextOverflow.ellipsis,
        ),
      ),
      Container(
        alignment: Alignment.centerLeft,
        padding: const EdgeInsets.all(8.0),
        child: Text(
          row.getCells()[6].value.toString(),
          overflow: TextOverflow.ellipsis,
        ),
      ),
      Container(
        alignment: Alignment.centerLeft,
        padding: const EdgeInsets.all(8.0),
        child: Text(
          row.getCells()[7].value.toString(),
          overflow: TextOverflow.ellipsis,
        ),
      ),
      Container(
        alignment: Alignment.centerLeft,
        padding: const EdgeInsets.all(8.0),
        child: Text(
          row.getCells()[8].value.toString(),
          overflow: TextOverflow.ellipsis,
        ),
      )
    ]);
  }
}
