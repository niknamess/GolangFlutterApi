class File {
  String name;

  File({required this.name});

  File.fromJson(Map<String, dynamic> sting) : name = sting["Path"];
}
