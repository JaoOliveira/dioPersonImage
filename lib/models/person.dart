class Person {
  String? cpf;
  String? name;
  String? image;
  String? objectId;

  Person({
    this.cpf,
    this.name,
    this.image,
    this.objectId,
  });

  Person.fromJson(Map<String, dynamic> json) {
    objectId = json['objectId'];
    cpf = json['cpf'];
    name = json['name'];
    image = json['image'];
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = new Map<String, dynamic>();
    data['cpf'] = this.cpf;
    data['name'] = this.name;
    data['image'] = this.image;
    data['objectId'] = this.objectId;
    return data;
  }
}
