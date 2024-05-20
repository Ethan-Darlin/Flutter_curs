class Point{
  int? id;
  String? name;
  String? adress;
  Point.undef(){
    id=-1;
    name=null;
    adress;
  }
  Point({
    this.id,
    this.name,
    this.adress,
  });

  factory Point.fromJson(Map<String, dynamic> json) {
    return Point(
      id: json['id'],
      name: json['name'],
      adress: json['adress'] ?? null,
    );
  }

  @override
  String toString() {
    return 'User{id: $id, name: $name, adress: $adress}';
  }
}