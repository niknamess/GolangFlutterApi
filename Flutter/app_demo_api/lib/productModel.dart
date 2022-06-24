class Product {
  String name;
  num price;
  int count;

  Product({this.name, this.price, this.count});

  Product.fromJson(Map<String, dynamic> json)
      : name = json["Name"],
        price = json["Price"],
        count = json["Count"];
}

class File {
  String name;

  File({this.name});

  File.fromJson(Map<String, dynamic> sting) : name = sting["Name"];
}
