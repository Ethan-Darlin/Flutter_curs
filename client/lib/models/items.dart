class Item {
  int? id;
  String? name;
  String? description;
  int? cost;
  int? count;
  int orderCount = 0;
  String? image;
  String? category;
  int? raiting;
  DateTime? createdAt; // Добавлено поле для даты создания

  Item.undef() {
    id = -1;
    name = null;
    description = null;
    cost = null;
    count = null;
    image = null;
    category = null;
    raiting = null;
    createdAt = null; // Инициализация даты создания как null
  }

  Item.forCart({
    this.id,
    this.name,
    this.cost,
    this.createdAt, // Добавлено поле для даты создания
  });

  Item({
    this.id,
    this.name,
    this.description,
    this.cost,
    this.count,
    this.image,
    this.category, 
    this.raiting,
    this.createdAt, // Добавлено поле для даты создания
  });

  static List<Item> sortItemsByRating(List<Item> items) {
    // Сортируем список в порядке убывания рейтинга
    return items..sort((a, b) => b.raiting!.compareTo(a.raiting!));
  }
    static List<Item> sortItemsByCreatedAt(List<Item> items) {
    // Сортируем список по дате создания
    return items..sort((a, b) => b.createdAt!.compareTo(a.createdAt!));
  }
static List<Item> sortItemsByCreatedAt2(List<Item> items) {
  // Сортируем список по дате создания, чтобы более старые даты были вверху
  return items..sort((a, b) => a.createdAt!.compareTo(b.createdAt!));
}
static List<Item> sortItemsByCount(List<Item> items) {
  // Сортируем список по количеству, чтобы элементы с большим количеством были вверху
  return items..sort((a, b) => b.count!.compareTo(a.count!));
}

 factory Item.fromJson(Map<String, dynamic> json) {
  return Item(
    id: json['id'],
    name: json['name'],
    description: json['description']?? null,
    cost: json['cost']?? null,
    count: json['count']?? null,
    image: json['image']?? null,
    category: json['category']?? null,
    raiting: json['raiting']?? null,
    createdAt: json['createdat']!= null? DateTime.parse(json['createdat'].replaceAll('+03:00', '')) : null,
  );
}


  factory Item.fromJsonToCart(Map<String, dynamic> json) {
    return Item(
      id: json['id'],
      name: json['name'],
      cost: json['cost']?? null,
      raiting: json['raiting']?? null,
      createdAt: json['createdAt'] == null? null : DateTime.parse(json['createdAt']), // Парсинг даты из JSON
    );
  }

  @override
  String toString() {
    return 'Item{id: $id, name: $name, description: $description, cost: $cost, count: $count, image: $image, category: $category, raiting: $raiting, createdAt: $createdAt}';
  }

  String toSearchString(){
    return '$name / $description';
  }
}
