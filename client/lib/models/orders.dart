import 'package:untitled/models/OrderDetail.dart';

class Order {
  int? id;
  int? point_id;
  int? user_id;
  String? status;
  DateTime? createdAt;
  int? poiID;
  String? poiName;
  String? poiAdress;
  String? userPhone;

  Order.undef() {
    id = -1;
    point_id = null;
  }
  Order({
    this.id,
    this.point_id,
    this.user_id,
    this.status,
    this.createdAt,
    this.poiName,
    this.poiAdress,
    this.userPhone,
  });
static List<Order> sortOrderDetailsByDate(List<Order> orders) {
    return orders..sort((a, b) => 
      (b.createdAt!= null && a.createdAt!= null)? b.createdAt!.compareTo(a.createdAt!) : 0);
  }
  static List<Order> aggregateAndSortOrdersByItemCount(List<Order> orders, List<OrderDetail> orderDetails) {
    // Агрегация информации о количестве элементов для каждого заказа
    Map<int, int> itemCounts = {};
    for (var order in orders) {
      for (var detail in orderDetails) {
        if (detail.id == order.id) { // Предполагаем, что у OrderDetail есть поле orderId для связи с Order
          itemCounts[order.id!] = (itemCounts[order.id]?? 0) + detail.count!;
        }
      }
    }

    // Сортировка заказов по агрегированной информации о количестве элементов
    return orders..sort((a, b) => 
      (itemCounts[b.id]!= null && itemCounts[a.id]!= null)? itemCounts[b.id]!.compareTo(itemCounts[a.id]!) : 0);
  }
  factory Order.fromJson(Map<String, dynamic> json) {
    return Order(
      id: json['orders_id'],
      point_id: json['point_id'],
      user_id: json['user_id'],
      status: json['status'],
      createdAt: DateTime.tryParse(json['created_at'])?.toLocal(),
      poiName: json['poi_name'],
      poiAdress: json['poi_adress'],
      userPhone: json['user_phone'],
    );
  }

  @override
  String toString() {
    return 'Order{id: $id, point_id: $point_id, phome: $userPhone';
  }
}