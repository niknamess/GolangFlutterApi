class File {
  String name;

  File({required this.name});

  File.fromJson(Map<String, dynamic> sting) : name = sting["Path"];
}
/* 
class Loglist1 {
  final String log;
  Loglist1({required this.log});
  static Loglist1 fromXml(xml.XmlElement xmlNode) {
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
} */

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
        extMessage: json["ext_message"]);
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
/* 
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
 */