class File {
  String name;

  File({required this.name});

  File.fromJson(Map<String, dynamic> sting) : name = sting["Path"];
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
