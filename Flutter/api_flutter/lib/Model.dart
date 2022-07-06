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

/* class Log {
  Log._(this.module_name, this.app_path, this.app_pid, this.thread_id,
      this.time, this.ulid, this.type, this.message, this.ext_message);

  factory Log.fromElement(Log logElement) {
    return Log._(
      logElement.getAttribute('module_name'),
      logElement.getAttribute('app_path'),
      logElement.getAttribute('app_pid'),
      logElement.getAttribute('thread_id'),
      logElement.getAttribute('time'),
      logElement.getAttribute('ulid'),
      logElement.getAttribute('type'),
      logElement.getAttribute('message'),
      logElement.getAttribute('ext_message'),
      logElement
          .findElements('log')
          .map<Log>((e) => Log.fromElement(e))
          .toList(),
    );
  }

  String module_name;
  String app_path;
  String app_pid;
  String thread_id;
  String time;
  String ulid;
  String type;
  String message;
  String ext_message;
}
 */

/* class Genre {
  Genre._(this.id, this.title, this.token, this.type, this.subGenres);

  factory Genre.fromElement(XmlElement genreElement) {
    return Genre._(
      genreElement.getAttribute('id'),
      genreElement.getAttribute('title'),
      genreElement.getAttribute('token'),
      genreElement.getAttribute('type'),
      genreElement
          .findElements('genre')
          .map<Genre>((e) => Genre.fromElement(e))
          .toList(),
    );
  }

  String id;
  String title;
  String token;
  String type;
  List<Genre> subGenres;
}
 */
class Welcome8 {
  Welcome8({
    required this.catalog,
  });

  Catalog catalog;
}

class Catalog {
  Catalog({
    required this.loglist,
  });

  List<Loglist> loglist;
}

class Loglist {
  Loglist({
    required this.log,
  });

  Log log;
}

class Log {
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

  String moduleName;
  String appPath;
  String appPid;
  String threadId;
  String time;
  String ulid;
  String type;
  String message;
  String extMessage;
}
