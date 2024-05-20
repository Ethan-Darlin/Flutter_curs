import 'dart:convert';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:logger/logger.dart';
import '../models/OrderDetail.dart';
import '../models/User.dart';
import '../models/items.dart';
import '../models/orders.dart';
import '../models/points.dart';
import '../models/coments.dart';

class DbHandler {

  static String hostName = "http://localhost:7700";
  static String webHostName = "http://localhost:7700";

  static Future<void> addOrderDetail(int itemId, int orderId, int count) async {
  final String baseUrl = defaultTargetPlatform == TargetPlatform.android
     ? "http://192.168.43.200:7700/addOrderDetail"
      : "http://localhost:7700/addOrderDetail";
  final url = Uri.parse(baseUrl);
  final headers = {'Content-Type': 'application/json'};
  final body = jsonEncode({'item_id': itemId, 'order_id': orderId, 'count': count});
  try {
    final response = await http.post(url, headers: headers, body: body);
    if (response.statusCode == 200) {
      print('Item $itemId successfully added');
    } else {
      print('Error adding order detail: ${response.statusCode}');
    }
  } catch (error) {
    print('Error adding order detail: $error');
  }
}

  static Future<int> createOrder(int pointId, int userId) async {
    final String baseUrl = defaultTargetPlatform == TargetPlatform.android
        ? "http://192.168.43.200:7700/createOrder"
        : "http://localhost:7700/createOrder";
    final url = Uri.parse(baseUrl);
    final headers = {'Content-Type': 'application/json'};
    final body = jsonEncode({'point_id': pointId, 'user_id': userId});
    int orderId = -1;

    try {
      final response = await http.post(url, headers: headers, body: body);
      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        var orderData = data['order_id'];
        orderId = int.parse(orderData[0]['create_order'].toString());
        print('Order created with ID: $orderId');
      } else {
        print('Error creating order: ${response.statusCode}');
      }
    } catch (error) {
      print('Error creating order: $error');
    }

    return orderId;
  }

  Future<Item> deleteItem(String name) async {
  final String baseUrl = defaultTargetPlatform == TargetPlatform.android
    ? "http://192.168.43.200:7700/delete"
      : "http://localhost:7700/delete";

  final Map<String, dynamic> requestData = {"itemId": name}; // Изменено здесь

  try {
    final response = await http.post(
      Uri.parse(baseUrl),
      headers: {"Content-Type": "application/json"},
      body: json.encode(requestData),
    );

    if (response.statusCode == 200) {
      print("Item deleted successfully!");
      print(response.body);
      return Item.fromJson(json.decode(response.body));
    } else {
      print("Error deleting item: ${response.statusCode}");
      print(response.body);
      throw Exception("Failed to delete item.");
    }
  } catch (e) {
    print("Error deleting item: $e");
    throw Exception("Failed to delete item.");
  }
}

  static Future<List<Point>> fetchPoints() async {
    final String baseUrl = defaultTargetPlatform == TargetPlatform.android
        ? "http://192.168.43.200:7700/points"
        : "http://localhost:7700/points";

    final response = await http.get(Uri.parse(baseUrl));

    if (response.statusCode == 200) {
      final data = jsonDecode(response.body) as List<dynamic>;

      return data.map((json) => Point.fromJson(json)).toList();
    } else {
      throw Exception('Failed to fetch points');
    }
  }

    static Future<List<Item>> fetchItems() async {
      final String baseUrl = defaultTargetPlatform == TargetPlatform.android
        ? "http://192.168.43.200:7700/items"
          : "http://localhost:7700/items";

      final response = await http.get(Uri.parse(baseUrl));

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body) as List<dynamic>;
        // Выводим в консоль полученные объекты перед их возвратом
        print('Received items: $data');
        return data.map((json) => Item.fromJson(json)).toList();
      } else {
        throw Exception('Failed to fetch items');
      }
    }

  static Future<void> updateOrderStatus(int orderId, String status) async {
    final String baseUrl = defaultTargetPlatform == TargetPlatform.android
        ? "http://192.168.43.200:7700/updateOrderStatus"
        : "http://localhost:7700/updateOrderStatus";

    final Map<String, dynamic> requestData = {"order_id": orderId, "order_status" : status};
    try {
      final response = await http.post(
        Uri.parse(baseUrl),
        headers: {"Content-Type": "application/json"},
        body: json.encode(requestData),
      );

      if (response.statusCode == 200) {
        print("Order status updated!");
        print(response.body);
      } else {
        print("Error updating order: ${response.statusCode}");
        print(response.body);
        throw Exception("Failed to update order.");
      }
    } catch (e) {
      print("Error updating order: $e");
      throw Exception("Failed to update order.");
    }
  }

  static Future<List<Order>> fetchUserOrders(int userID) async {
    final String baseUrl = defaultTargetPlatform == TargetPlatform.android
        ? "http://192.168.43.200:7700/getUserOrders"
        : "http://localhost:7700/getUserOrders";
    final Map<String, dynamic> requestData = {"user_id": userID};
    try {
      final response = await http.post(
        Uri.parse(baseUrl),
        headers: {"Content-Type": "application/json"},
        body: json.encode(requestData),
      );

      if (response.statusCode == 200) {
        print("Orders got!");
        print(response.body);
        final data = jsonDecode(response.body) as List<dynamic>;
        return data.map((json) => Order.fromJson(json)).toList();
      } else {
        print("Error getting orders: ${response.statusCode}");
        print(response.body);
        throw Exception("Failed to get orders.");
      }
    } catch (e) {
      print("Error getting orders: $e");
      throw Exception("Failed to get orders.");
    }
  }

  static Future<List<OrderDetail>> fetchOrderDetails(int orderID) async {
  final String baseUrl = defaultTargetPlatform == TargetPlatform.android
   ? "http://192.168.43.200:7700/getOrderDetails"
      : "http://localhost:7700/getOrderDetails";

  final Map<String, dynamic> requestData = {"order_id": orderID};
  try {
    final response = await http.post(
      Uri.parse(baseUrl),
      headers: {"Content-Type": "application/json"},
      body: json.encode(requestData),
    );

    if (response.statusCode == 200) {
      print("Order details got!");
      print(response.body);
      final data = jsonDecode(response.body) as List<dynamic>;
      return data.map((json) => OrderDetail.fromJson(json)).toList();
    } else {
      print("Error getting order details: ${response.statusCode}");
      print(response.body);
      throw Exception("Failed to get order details.");
    }
  } catch (e) {
    print("Error getting order details: $e");
    throw Exception("Failed to get order details.");
  }
}



  static Future<int> getOrderId() async {
    final response = await http.get(Uri.http('localhost:7700', 'order', {'userId': '${User.currentUser.id}'}));

    if (response.statusCode == 200) {
      final data = jsonDecode(response.body) as List<dynamic>;
      if (data.isNotEmpty) {
        final firstItem = data.first;
        return int.parse(firstItem['orderId']);
      } else {
        throw Exception('No order data found');
      }
    } else {
      throw Exception('Failed to fetch points');
    }
  }

  static Future<List<Item>> fetchOrderItems(int orderId) async {
    print(orderId);
    final response = await http.get(Uri.http('localhost:7700', 'items', {'orderId': '$orderId'}));

    if (response.statusCode == 200) {
      final data = jsonDecode(response.body) as List<dynamic>;

      return data.map((json) => Item.fromJson(json)).toList();
    } else {
      throw Exception('Failed to fetch order items');
    }
  }

  static Future<List<Order>> showOrdersInAdmin() async {
    final response = await http.get(Uri.http('localhost:7700', 'showorders'));

    if (response.statusCode == 200) {
      final data = jsonDecode(response.body) as List<dynamic>;
      print(data);

      return data.map((json) => Order.fromJson(json)).toList();
    } else {
      throw Exception('Failed to fetch orders');
    }
  }

Future<Item> createItem(
  String name, String description, String cost, String count, String category, String image, int raiting) async {
  final String baseUrl = defaultTargetPlatform == TargetPlatform.android
   ? "http://192.168.43.200:7700/newItem"
      : "http://localhost:7700/newItem";

  final Map<String, dynamic> requestData = {
    "name": name,
    "description": description,
    "cost": cost,
    "count": count,
    "category": category,
    "image": image,
    "raiting": raiting // Добавление нового поля в запрос
  };

  try {
    final response = await http.post(
      Uri.parse(baseUrl),
      headers: {"Content-Type": "application/json"},
      body: json.encode(requestData),
    );

    if (response.statusCode == 200) {
      print("Item created successfully!");
      var responseBody = json.decode(response.body);
      if (responseBody is List && responseBody.isNotEmpty) {
        var itemData = responseBody.first; // Предполагается, что первый элемент списка содержит данные Item
        return Item.fromJson(itemData); // Преобразование первого элемента списка в Item
      } else {
        throw Exception("Unexpected response format from server.");
      }
    } else {
      print("Error creating item: ${response.statusCode}");
      print(response.body);
      throw Exception("Failed to create item.");
    }
  } catch (e) {
    print("Error creating item: $e");
    throw Exception("Failed to create item.");
  }
}


  Future<void> createUser(
      String name,
      String password,
      String phoneNumber,
      String login,
      ) async {
    final String baseUrl = defaultTargetPlatform == TargetPlatform.android
        ? "http://192.168.43.200:7700/users/create"
        : "http://localhost:7700/users/create";

    final Map<String, dynamic> requestData = {
      "name": name,
      "password": password,
      "phonenumber": phoneNumber,
      "login": login,
    };

    try {
      final response = await http.post(
        Uri.parse(baseUrl),
        headers: {"Content-Type": "application/json"},
        body: json.encode(requestData),
      );

      if (response.statusCode == 201) {
        print("User created successfully!");
        print(response.body);
      } else {
        print("Error creating user: ${response.statusCode}");
        print(response.body);
        throw Exception("Failed to create user.");
      }
    } catch (e) {
      print("Error creating user: $e");
      throw Exception("Failed to create user.");
    }
  }
  Future<bool> checkIfUserExists(String login, String phoneNumber) async {
  final String baseUrl = defaultTargetPlatform == TargetPlatform.android
    ? "http://192.168.43.200:7700/users/check"
     : "http://localhost:7700/users/check";

  final Map<String, dynamic> requestData = {
    "login": login,
    "phoneNumber": phoneNumber,
  };

  try {
    final response = await http.post(
      Uri.parse(baseUrl),
      headers: {"Content-Type": "application/json"},
      body: json.encode(requestData),
    );

    if (response.statusCode == 200) {
      final responseData = json.decode(response.body);
      return responseData['exists'];
    } else {
      throw Exception("Failed to check user existence.");
    }
  } catch (e) {
    print("Error checking user existence: $e");
    throw Exception("Failed to check user existence.");
  }
}

  
  Future<void> updateUserProfile(User user) async {
 final String baseUrl = "http://192.168.43.200:7700/updateProfile";
 final Map<String, dynamic> requestData = {
    "id": user.id,
    "name": user.name,
    "login": user.login,
    "phonenumber": user.phonenumber,
    "user_image": user.user_image,
    'password': user.password,
 };

 try {
 final response = await http.post(
    Uri.parse(baseUrl),
    headers: {"Content-Type": "application/json"},
    body: json.encode(requestData),
 );

 if (response.statusCode == 200) {
    // Обновление данных в локальной базе данных
 } else {
    throw Exception("Failed to update profile. Status code: ${response.statusCode}");
 }
} catch (e) {
 print("Error updating profile: $e");
 throw Exception("Failed to update profile. Error: $e");
}

}


  static Future<User?> login(String username, String password) async {
  final String baseUrl = defaultTargetPlatform == TargetPlatform.android
     ? "http://192.168.43.200:7700/login"
      : "http://localhost:7700/login";

  final Map<String, dynamic> requestData = {
    "login": username,
    "password": password,
  };

  try {
    final response = await http.post(
      Uri.parse(baseUrl),
      headers: {"Content-Type": "application/json"},
      body: json.encode(requestData),
    );

    if (response.statusCode == 200) {
      Map<String, dynamic> bodyBuffer = jsonDecode(response.body);
      User user = User.fromJson(bodyBuffer);
      return user;
    } else if (response.statusCode == 401) {
      // Пользователь не найден или пароль неверен
      return null;
    } else {
      print("Error logging in: ${response.statusCode}");
      print(response.body);
      throw Exception("Failed to login.");
    }
  } catch (e) {
    print("Error logging in: $e");
    throw Exception("Failed to login.");
  }
}


  //Коментарии
  Future<Comment> addComment(int userid, int itemid, String commentText) async {
  final String baseUrl = defaultTargetPlatform == TargetPlatform.android
   ? "http://192.168.43.200:7700/addComment"
      : "http://localhost:7700/addComment";

  // Проверяем, не пустая ли строка комментария
  if (commentText.isEmpty) {
    throw Exception("Комментарий не может быть пустым.");
  }

  final Map<String, dynamic> requestData = {
    "userId": userid, // Используйте userId вместо id_user
    "itemId": itemid, // Используйте itemId вместо id_tems
    "commentText": commentText // Используйте commentText вместо description
  };

  try {
    final response = await http.post(
      Uri.parse(baseUrl),
      headers: {"Content-Type": "application/json"},
      body: json.encode(requestData),
    );

    if (response.statusCode == 200) {
      print("Comment added successfully!");
      print(response.body);
      return Comment.fromJson(json.decode(response.body));
    } else {
      print("Error adding comment: ${response.statusCode}");
      print(response.body);
      throw Exception("Failed to add comment.");
    }
  } catch (e) {
    print("Error adding comment: $e");
    throw Exception("Failed to add comment.");
  }
}


//
Future<List<Comment>> fetchCommentsForItem(int itemId) async {
 final String baseUrl = defaultTargetPlatform == TargetPlatform.android
    ? "http://192.168.43.200:7700/getCommentsForItem"
      : "http://localhost:7700/getCommentsForItem";

 final response = await http.get(
    Uri.parse("$baseUrl/$itemId"),
    headers: {"Content-Type": "application/json"},
 );

 if (response.statusCode == 200) {
    List<dynamic> body = json.decode(response.body);
    return body.map((dynamic item) => Comment.fromJson(item)).toList();
 } else {
    throw Exception("Failed to load comments.");
 }
}
static Future<List<Map<String, dynamic>>> fetchPurchaseStats() async {
  final String baseUrl = defaultTargetPlatform == TargetPlatform.android
     ? "http://192.168.43.200:7700/api/purchase-stats"
      : "http://localhost:7700/api/purchase-stats";

  Logger logger = Logger();

  try {
    final response = await http.get(Uri.parse(baseUrl));
    logger.d('Response status code: ${response.statusCode}'); // Логирование статуса ответа

    if (response.statusCode == 200) {
      List<dynamic> body = jsonDecode(response.body);
      logger.d('Fetched data successfully'); // Логирование успешного получения данных
      return body.cast<Map<String, dynamic>>();
    } else {
      logger.e('Failed to load purchase stats'); // Логирование ошибки загрузки данных
      throw Exception("Failed to load purchase stats");
    }
  } catch (e) {
    logger.e(e.toString()); // Логирование исключений
    rethrow;
  }
}

Future<void> deleteComment(int idComment) async {
  final String baseUrl = defaultTargetPlatform == TargetPlatform.android
   ? "http://192.168.43.200:7700/deleteComment"
    : "http://localhost:7700/deleteComment";

  try {
    final response = await http.delete(
      Uri.parse(baseUrl + "/$idComment"), // Добавляем idComment в URL
      headers: {"Content-Type": "application/json"},
    );

    if (response.statusCode == 200) {
      print("Comment deleted successfully!");
      print(response.body);
    } else {
      print("Error deleting comment: ${response.statusCode}");
      print(response.body);
      throw Exception("Failed to delete comment.");
    }
  } catch (e) {
    print("Error deleting comment: $e");
    throw Exception("Failed to delete comment.");
  }
}
Future<bool> deleteComment2(int idComment) async {
    final String baseUrl = defaultTargetPlatform == TargetPlatform.android
        ? "http://192.168.43.200:7700/deleteComment"
        : "http://localhost:7700/deleteComment";

    try {
      final response = await http.delete(
        Uri.parse(baseUrl + "/$idComment"),
        headers: {"Content-Type": "application/json"},
      );

      if (response.statusCode == 200) {
        print("Comment deleted successfully!");
        print(response.body);
        return true; // Возвращаем true при успешном удалении
      } else {
        print("Error deleting comment: ${response.statusCode}");
        print(response.body);
        return false; // Возвращаем false при ошибке удаления
      }
    } catch (e) {
      print("Error deleting comment: $e");
      return false; // Возвращаем false при исключении
    }
  }
Future<void> updateComment(int idComment, String description) async {
  final String baseUrl = defaultTargetPlatform == TargetPlatform.android
     ? "http://192.168.43.200:7700/updateComment/$idComment"
      : "http://localhost:7700/updateComment/$idComment";
  final DateTime startTime = DateTime.now();

  try {
    final response = await http.put(
      Uri.parse(baseUrl),
      headers: {"Content-Type": "application/json"},
      body: jsonEncode({'description': description}),
    );

    final DateTime endTime = DateTime.now();
    print('Update comment request completed in ${endTime.difference(startTime)}');

    if (response.statusCode == 200) {
      print("Comment updated successfully!");
      print(response.body);
    } else {
      print("Error updating comment: ${response.statusCode}");
      print(response.body);
      throw Exception("Failed to update comment.");
    }
  } catch (e) {
    print("Error updating comment: $e");
    throw Exception("Failed to update comment.");
  }
}
static Future<List<User>> fetchUsers() async {
  final String baseUrl = defaultTargetPlatform == TargetPlatform.android
     ? "http://192.168.43.200:7700/users" // Используйте IP-адрес, если на Android
      : "http://localhost:7700/users"; // Или localhost, если на iOS

  final response = await http.get(Uri.parse(baseUrl));

  if (response.statusCode == 200) {
    final data = jsonDecode(response.body) as List<dynamic>;
    return data.map((json) => User.fromJson(json)).toList();
  } else {
    throw Exception('Failed to fetch users');
  }
}


static Future<void> updateItem(int idItem, Map<String, dynamic> newItemData) async {
  final String baseUrl = defaultTargetPlatform == TargetPlatform.android
    ? "http://192.168.43.200:7700/updateItem/$idItem"
      : "http://localhost:7700/updateItem/$idItem";

  final DateTime startTime = DateTime.now();

  try {
    final response = await http.put(
      Uri.parse(baseUrl),
      headers: {"Content-Type": "application/json"},
      body: jsonEncode(newItemData),
    );

    final DateTime endTime = DateTime.now();
    print('Update item request completed in ${endTime.difference(startTime)}');

    if (response.statusCode == 200) {
      print("Item updated successfully!");
      print(response.body);
    } else {
      print("Error updating item: ${response.statusCode}");
      print(response.body);
      throw Exception("Failed to update item.");
    }
  } catch (e) {
    print("Error updating item: $e");
    throw Exception("Failed to update item.");
  }
}
 static Future<void> changeUserRole(String userId, String newRole) async {
    final String baseUrl = defaultTargetPlatform == TargetPlatform.android
       ? "http://192.168.43.200:7700/changeRole/$userId/$newRole"
        : "http://localhost:7700/changeRole/$userId/$newRole";

    final response = await http.put(Uri.parse(baseUrl));

    if (response.statusCode == 200) {
      print('User role changed successfully');
    } else {
      throw Exception('Failed to change user role');
    }
  }

Future<List<Comment>> fetchAllComments() async {
    final String baseUrl = defaultTargetPlatform == TargetPlatform.android
       ? "http://192.168.43.200:7700/getAllComments"
        : "http://localhost:7700/getAllComments";

    final response = await http.get(Uri.parse(baseUrl),
        headers: {"Content-Type": "application/json"});

    if (response.statusCode == 200) {
      List<dynamic> body = json.decode(response.body);
      return body.map((dynamic item) => Comment.fromJson(item)).toList();
    } else {
      throw Exception("Failed to load comments.");
    }
  }

}
