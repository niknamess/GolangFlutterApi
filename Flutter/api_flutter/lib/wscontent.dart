import 'package:flutter/material.dart';
import 'package:api_flutter/NavDrawer.dart';
import 'package:path/path.dart';
import 'dart:html';
import 'package:http/http.dart' as http;
import 'package:xml/xml.dart';
import 'package:api_flutter/Model.dart';

//import 'package:flutter/material.dart';
import 'package:web_socket_channel/web_socket_channel.dart';

//import 'package:web_socket_channel/io.dart';
//import 'package:web_socket_channel/status.dart' as status;

class initWS extends StatelessWidget {
  static const String routeName = '/initws';
  initWS({super.key, required this.filename});
  final Filename filename;
  //var url = "http://192.168.0.101:5500//data/" + window.btoa(filename.path);

  //final Filename snapshot;
  @override
  Widget build(BuildContext context) {
    // var url = "http://192.168.0.101:5500//data/" + window.btoa(filename.path);

    //final filename = ModalRoute.of(context)!.settings.arguments as Todo;

    return new Scaffold(
        appBar: AppBar(
          title: Text(basename(filename.path)),
        ),
        drawer: NavDrawer(),
        body: Container(
          child: FutureBuilder<List<Loglist>>(
            future: fetchFileXml(),
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
                return ListView.builder(
                  scrollDirection: Axis.vertical,
                  shrinkWrap: true,
                  itemCount: snapshot.data.length,
                  itemBuilder: (BuildContext context, int index) {
                    return ListTile(
                      title: Text(basename(snapshot.data[index].name)),
                      onTap: () {
                        final filename =
                            Filename(path: snapshot.data[index].name);
                        Navigator.of(context).pop();
                        Navigator.of(context).push(MaterialPageRoute(
                          builder: (BuildContext context) => initWS(
                            filename: filename,
                          ),
                        ));
                        // Update the state of the app
                        // ...
                        // Then close the drawer
                        //Navigator.pop(context);
                      },
                    );
                  },
                );
              }
              return new CircularProgressIndicator();
            },
          ),
          /* Text("This is initWS page" +
              filename.path +
              "   " +
              window.btoa(filename.path)), */
        ));
  }

  Future<List<Loglist>> fetchFileXml() async {
    var url = "http://192.168.0.101:5500//data/" + window.btoa(filename.path);
    var response = await http.get(Uri.parse(url));
    List<Loglist> loglist = [];
    if (response.statusCode == 200) {
      var raw = XmlDocument.parse(response.body);
      var elements = raw.findAllElements("loglist");
      for (final item in elements) {
        var item2 = item.toString();
        loglist.add(Loglist(log: item2));
      }
      /*  for (final item in elements) {
        loglist.add(Loglist(item));
      } */
    }
    return loglist;
  }
}
