import 'package:flutter/material.dart';
import 'package:app_demo_api/Model.dart';
import 'package:http/http.dart' as http;
import 'dart:convert' as convert;
import 'package:path/path.dart';

void main() => runApp(const MyApp());

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  static const appTitle = 'Drawer Demo';

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: appTitle,
      home: MyHomePage(title: appTitle),
    );
  }
}

// ignore: must_be_immutable
class MyHomePage extends StatelessWidget {
  MyHomePage({super.key, required this.title});

  final String title;
  double fetchPercentage = 100.0;
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.orange,
      appBar: AppBar(title: Text(title)),
      body: Center(
        child: Text('My Page!'),
      ),
      drawer: Drawer(
        // Add a ListView to the drawer. This ensures the user can scroll
        // through the options in the drawer if there isn't enough vertical
        // space to fit everything.
        child: ListView(
          // Important: Remove any padding from the ListView.
          padding: EdgeInsets.zero,
          children: [
            DrawerHeader(
              decoration: BoxDecoration(
                  image: DecorationImage(
                      image: AssetImage("images/servers.jpg"),
                      fit: BoxFit.cover)),
              child: Text('List files'),
            ),
            FutureBuilder<List<File>>(
              future: fetchFromServerFile(),
              builder: (BuildContext context, AsyncSnapshot snapshot) {
                /* if (snapshot.connectionState == ConnectionState.waiting) {
                  return Center(
                    child: CircularProgressIndicator(),
                  );
                }
 */
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
                          // Update the state of the app
                          // ...
                          // Then close the drawer
                          Navigator.pop(context);
                        },
                      );
                    },
                  );
                }
                return new CircularProgressIndicator();
              },
            ),
          ],
        ),
      ),
    );
  }

  Future<List<File>> fetchFromServerFile() async {
    var url = "http://192.168.0.101:5500//files/$fetchPercentage";
    var response = await http.get(Uri.parse(url));

    List<File> filetList = [];
    if (response.statusCode == 200) {
      var fileMap = convert.jsonDecode(response.body);
      for (final item in fileMap) {
        filetList.add(File.fromJson(item));
      }
    }

    return filetList;
  }
}
