class File {
  String name;

  File({required this.name});

  File.fromJson(Map<String, dynamic> sting) : name = sting["Path"];
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