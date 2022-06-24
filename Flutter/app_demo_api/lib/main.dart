// ignore_for_file: missing_return

import 'package:flutter/material.dart';
import 'package:app_demo_api/productModel.dart';
import 'package:http/http.dart' as http;
import 'dart:convert' as convert;

void main() {
  runApp(AppDemo());
}

class AppDemo extends StatefulWidget {
  AppDemo({Key key}) : super(key: key);

  @override
  _AppDemoState createState() => _AppDemoState();
}

class _AppDemoState extends State<AppDemo> {
  double fetchCountPercentage = 20.0; // default 10%
  double fetchPercentage = 20.0;

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
        home: Scaffold(
            backgroundColor: Colors.blueGrey,
            body: SizedBox.expand(
                child: Stack(
              children: [
                FutureBuilder<List<Product>>(
                  future: fetchFromServer(),
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
                        itemCount: snapshot.data.length,
                        itemBuilder: (BuildContext context, int index) {
                          return Card(
                              child: ListTile(
                            title: Text(snapshot.data[index].name),
                            subtitle: Text(
                                "Count: ${snapshot.data[index].count} \t Price:${snapshot.data[index].price}"),
                          ));
                        },
                      );
                    }
                  },
                ),
                FutureBuilder<List<File>>(
                  future: fetchFromServerFile(),
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
                        itemCount: snapshot.data.length,
                        itemBuilder: (BuildContext context, int index) {
                          return Card(
                              child: ListTile(
                            title: Text(snapshot.data[index].name),
                          ));
                        },
                      );
                    }
                  },
                ),
                Positioned(
                    bottom: 5,
                    right: 5,
                    child: Slider(
                      value: fetchCountPercentage,
                      min: 0,
                      max: 100,
                      divisions: 10,
                      label: fetchCountPercentage.toString(),
                      onChanged: (double value) {
                        setState(() {
                          fetchCountPercentage = value;
                        });
                      },
                    ))
                /* Positioned(
                    bottom: 5,
                    right: 15,
                    child: Slider(
                      value: fetchPercentage,
                      min: 0,
                      max: 100,
                      divisions: 10,
                      label: fetchPercentage.toString(),
                      onChanged: (double value) {
                        setState(() {
                          fetchPercentage = value;
                        });
                      },
                    )) */
              ],
            ))));
  }

  Future<List<Product>> fetchFromServer() async {
    var url = "http://192.168.0.101:5500/products/$fetchCountPercentage";
    var response = await http.get(url);

    List<Product> productList = [];
    if (response.statusCode == 200) {
      var productMap = convert.jsonDecode(response.body);
      for (final item in productMap) {
        productList.add(Product.fromJson(item));
      }
    }

    return productList;
  }

  Future<List<File>> fetchFromServerFile() async {
    var url = "http://192.168.0.101:5500//files/$fetchPercentage";
    var response = await http.get(url);

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
