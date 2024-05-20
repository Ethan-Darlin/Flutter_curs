import 'package:sqflite/sqflite.dart';
import 'package:path/path.dart';

import '../models/OrderDetail.dart';
import '../models/User.dart';
import '../models/items.dart';
import '../models/orders.dart';
import '../models/points.dart';

class SqliteHandler {
  static Future<Database> getInstance() async {
    String path = await getDatabasesPath();
    return openDatabase(
      join(path, 'shop.db'),
      onCreate: (database, version) async {
        await database.execute(
          "CREATE TABLE items (id INTEGER PRIMARY KEY AUTOINCREMENT, name TEXT, description TEXT, cost INTEGER, count INTEGER);",
        );

        await database.execute(
            "CREATE TABLE points_of_issue (id INTEGER PRIMARY KEY, name TEXT, address TEXT);"
        );

        await database.execute(
            "CREATE TABLE users (id INTEGER PRIMARY KEY, name TEXT, login TEXT, phone_number TEXT,user_image TEXT);"
        );

        await database.execute(
          "CREATE TABLE orders (id INTEGER PRIMARY KEY, point_id INTEGER, user_id INTEGER, status TEXT, created_at TEXT,"
              "FOREIGN KEY (point_id) REFERENCES points_of_issue(id) ON UPDATE CASCADE ON DELETE CASCADE,"
              "FOREIGN KEY (user_id) REFERENCES users(id) ON UPDATE CASCADE ON DELETE CASCADE);"
        );

        await database.execute(
          "CREATE TABLE order_details (id INTEGER PRIMARY KEY AUTOINCREMENT, item_id INTEGER, count INTEGER, order_id INTEGER,"
              "FOREIGN KEY (item_id) REFERENCES items(id) ON UPDATE CASCADE ON DELETE CASCADE,"
              "FOREIGN KEY (order_id) REFERENCES orders(id) ON UPDATE CASCADE ON DELETE CASCADE);"
        );
      },
      version: 1,
    );
  }

  static Future<List<OrderDetail>> getOrderDetails() async {
    final database = await getInstance();
    List<Map<String, dynamic>> results = await database.query('order_details');
    List<OrderDetail> orderDetails = [];

    for (Map<String, dynamic> row in results) {
      int id = row['id'];
      int itemId = row['item_id'];
      int count = row['count'];
      int orderId = row['order_id'];
      OrderDetail orderDetail = OrderDetail(id: orderId, itemId: itemId, count: count);
      orderDetails.add(orderDetail);
    }

    return orderDetails;
  }

  static Future<List<Order>> getOrders() async {
    final database = await getInstance();
    List<Map<String, dynamic>> results = await database.query('orders');
    List<Order> orders = [];

    for (Map<String, dynamic> row in results) {
      int id = row['id'];
      int pointId = row['point_id'];
      int userId = row['user_id'];
      String status = row['status'];
      String createdAt = row['created_at'];
      Order order = Order(id: id, point_id: pointId, user_id: userId, status: status, createdAt: DateTime.tryParse(createdAt));
      orders.add(order);
    }

    return orders;
  }

  static Future<List<User>> getUsers() async {
    final database = await getInstance();
    List<Map<String, dynamic>> results = await database.query('users');
    List<User> users = [];

    for (Map<String, dynamic> row in results) {
      int id = row['id'];
      String name = row['name'];
      String login = row['login'];
      String phoneNumber = row['phone_number'];
      String user_image = row['user_image'];
      User user = User(id: id, name: name, login: login, phonenumber: phoneNumber,user_image: user_image);
      users.add(user);
    }
    return users;
  }

  static Future<List<Point>> getPoints() async {
    final database = await getInstance();
    List<Map<String, dynamic>> results = await database.query('points_of_issue');
    List<Point> pointsOfIssue = [];

    for (Map<String, dynamic> row in results) {
      int id = row['id'];
      String name = row['name'];
      String address = row['address'];
      Point pointOfIssue = Point(id: id, name: name, adress: address);
      pointsOfIssue.add(pointOfIssue);
    }
    return pointsOfIssue;
  }

  static Future<List<Item>> getItems() async {
  final database = await getInstance();
  List<Map<String, dynamic>> results = await database.query('items');
  List<Item> items = [];

  for (Map<String, dynamic> row in results) {
    int id = row['id'];
    String name = row['name'];
    String description = row['description'];
    int cost = row['cost'];
    int count = row['count'];
    int raiting = row['raiting']!= null? row['raiting'] as int : 0;
    DateTime createdAt = row['createdAt'];
    Item item = Item(id: id, name: name, description: description, cost: cost, count: count, raiting: raiting,createdAt: createdAt);
    print('Рейтинг: ${item.raiting}');
    items.add(item);
  }

  return items;
}

  static Future<int> insertItem(int id, String name, String description, int cost, int count, int raiting, DateTime? createdAt) async {
    final database = await getInstance();
    final table = 'items';
    final columns = ['id', 'name', 'description', 'cost', 'count','raiting','createdAt'];
    final values = [id, name, description, cost, count,raiting,createdAt];

    final generatedId = await database.insert(table, Map.fromIterables(columns, values),
        conflictAlgorithm: ConflictAlgorithm.replace);

    return generatedId;
  }

  static Future<int> insertPointOfIssue(int id, String name, String address) async {
    final database = await getInstance();
    final table = 'points_of_issue';
    final columns = ['id', 'name', 'address'];
    final values = [id, name, address];

    final generatedId = await database.insert(table, Map.fromIterables(columns, values),
        conflictAlgorithm: ConflictAlgorithm.replace);
    return generatedId;
  }

  static Future<int> insertUser(int id, String name, String login, String phoneNumber) async {
    final database = await getInstance();
    final table = 'users';
    final columns = ['id', 'name', 'login', 'phone_number'];
    final values = [id, name, login, phoneNumber];

    final generatedId = await database.insert(table, Map.fromIterables(columns, values),
        conflictAlgorithm: ConflictAlgorithm.replace);

    return generatedId;
  }

  static Future<int> insertOrder(int id, int pointId, int userId, String status, String createdAt) async {
    final database = await getInstance();
    final table = 'orders';
    final columns = ['id', 'point_id', 'user_id', 'status', 'created_at'];
    final values = [id, pointId, userId, status, createdAt];

    final generatedId = await database.insert(table, Map.fromIterables(columns, values),
        conflictAlgorithm: ConflictAlgorithm.replace);

    return generatedId;
  }

  static Future<int> insertOrderDetails(int itemId, int count, int orderId) async {
    final database = await getInstance();
    final table = 'order_details';
    final columns = ['item_id', 'count', 'order_id'];
    final values = [itemId, count, orderId];

    final generatedId = await database.insert(table, Map.fromIterables(columns, values),
        conflictAlgorithm: ConflictAlgorithm.replace);

    return generatedId;
  }

  static Future<void> deleteItems() async {
    final database = await getInstance();
    await database.execute("DELETE FROM items");
  }

  static Future<void> deleteUsers() async {
    final database = await getInstance();
    await database.execute("DELETE FROM users");
  }

  static Future<void> deletePoints() async {
    final database = await getInstance();
    await database.execute("DELETE FROM points_of_issue");
  }

  static Future<void> deleteOrders() async {
    final database = await getInstance();
    await database.execute("DELETE FROM orders");
  }

  static Future<void> deleteDetails() async {
    final database = await getInstance();
    await database.execute("DELETE FROM order_details");
  }

  static Future<void> deleteDetailsById(int orderId) async {
    final database = await getInstance();
    await database.execute("DELETE FROM order_details where order_id = $orderId");
  }

  static Future<void> deleteAllData() async {
    final database = await getInstance();
    await database.execute("DELETE FROM items");
    await database.execute("DELETE FROM users");
    await database.execute("DELETE FROM points_of_issue");
    await database.execute("DELETE FROM orders");
    await database.execute("DELETE FROM order_details");
  }
}