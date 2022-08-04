import 'package:flutter/material.dart';
import 'package:api_flutter/model/Model.dart';
import 'package:http/http.dart' as http;
import 'dart:convert' as convert;
import 'package:path/path.dart';
import 'package:api_flutter/screens/table.dart';
import 'package:api_flutter/main.dart';

class Filename {
  String path;
  Filename({required this.path});
}

class NavDrawer extends StatelessWidget {
  double fetchPercentage = 100.0;

  NavDrawer({super.key});
  @override
  Widget build(BuildContext context) {
    return Drawer(
      child: Container(color: Color.fromARGB(253, 197, 92, 5),
      // Add a ListView to the drawer. This ensures the user can scroll
      // through the options in the drawer if there isn't enough vertical
      // space to fit everything.v 
      child: ListView(
        // Important: Remove any padding from the ListView.
        padding: EdgeInsets.zero,
        children: [
          const DrawerHeader(
            decoration: BoxDecoration(
                image: DecorationImage(
                    image: AssetImage('images/servers.jpg'),
                    fit: BoxFit.cover)),
            child: Text('List files'),
          ),
          ListTile(
            title: const Text("Home"),
            leading: IconButton(
              icon: const Icon(Icons.home),
              onPressed: () {
                Navigator.of(context).pop();
              },
            ),
            onTap: () {
              Navigator.of(context).pop();
              Navigator.of(context).push(MaterialPageRoute(
                  builder: (BuildContext context) => const MyHomePage()));
            },
          ),
          FutureBuilder<List<File>>(
            future: fetchFromServerFile(),
            builder: (BuildContext context, AsyncSnapshot snapshot) {
              if (snapshot.connectionState == ConnectionState.waiting) {
                return const Center(
                  child: CircularProgressIndicator(),
                );
              }

              if (snapshot.hasError) {
                return Center(
                  child: Text("${snapshot.error}",
                      style: const TextStyle(color: Colors.redAccent)),
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
                          builder: (BuildContext context) => TableContent(
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
              return const CircularProgressIndicator();
            },
          ),
        ],
      ),
      )
    );
  }

  Future<List<File>> fetchFromServerFile() async {
    var url = "http://192.168.0.111:5500//files/$fetchPercentage";
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
  
}
