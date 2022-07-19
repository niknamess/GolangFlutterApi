import 'package:flutter/widgets.dart';
import 'package:xml/xml.dart' as xml;

class File {
  String name;

  File({required this.name});

  File.fromJson(Map<String, dynamic> sting) : name = sting["Path"];
}

class Loglist1 {
  final String log;

  Loglist1({required this.log});

  static Loglist1 fromXml(xml.XmlElement xmlNode) {
    //var log = xmlNode.findAllElements('id').single.getAttribute('im:id');
    var log = xmlNode.findAllElements('log').single.text;

    return Loglist1(
      log: log,
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'log': log,
    };
  }

  //Loglist1.fromJSON(Map<String, dynamic> string) : log = string["log"];
}

class Log {
  factory Log.fromJson(Map<String, dynamic> json) {
    return Log(
        moduleName: json["module_name"],
        appPath: json["app_path"],
        appPid: json["app_pid"],
        threadId: json["thread_id"],
        time: json["time"],
        ulid: json["ulid"],
        type: json["type"],
        message: json["message"],
        extMessage: json["extMessage"]);
  }
  Log({
    required this.moduleName,
    required this.appPath,
    required this.appPid,
    required this.threadId,
    required this.time,
    required this.ulid,
    required this.type,
    required this.message,
    required this.extMessage,
  });
  final String moduleName;
  final String appPath;
  final String appPid;
  final String threadId;
  final String time;
  final String ulid;
  final String type;
  final String message;
  final String extMessage;
}
