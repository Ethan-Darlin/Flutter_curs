class OrderDetail {
  int? id;
  int? itemId;
  String? name;
  int? cost;
  int? count;
  int? total;
  DateTime? dateBuy; // Добавленное поле для даты покупки
  int? orderId; // Добавленное поле для идентификатора заказа


  OrderDetail.undef() {
    id = -1;
    dateBuy = null; // Инициализация поля даты покупки
  }

  OrderDetail({
    this.id,
    this.itemId,
    this.name,
    this.cost,
    this.count,
    this.total,
    this.dateBuy, // Добавленное поле для даты покупки
    this.orderId, // Добавленное поле для идентификатора заказа

  });
  
static List<OrderDetail> sortOrderDetailsByDate(List<OrderDetail> orderDetails) {
  return orderDetails..sort((a, b) => 
    (b.dateBuy!= null && a.dateBuy!= null)? b.dateBuy!.compareTo(a.dateBuy!) : 0);
}
  static List<OrderDetail> sortOrderDetailsByCount(List<OrderDetail> orderDetails) {
    return orderDetails..sort((a, b) => 
      (b.count!= null && a.count!= null)? b.count!.compareTo(a.count!) : 0);
  }

  factory OrderDetail.fromJson(Map<String, dynamic> json) {
  return OrderDetail(
    id: json['id'],
    itemId: json['item_id'],
    name: json['name']?? '', // Обработка null для имени
    cost: json['cost']?? 0, // Обработка null для стоимости
    count: json['count']?? 0, // Обработка null для количества
    total: json['total']?? 0, // Обработка null для общей суммы
    dateBuy: json['date_buy']!= null? DateTime.parse(json['date_buy']) : null, // Обработка null для даты покупки
    orderId: json['orderid']?? 0, // Обработка null для идентификатора заказа
  );
}


  @override
  String toString() {
    return 'OrderDetail{id: $id, name: $name, dateBuy: $dateBuy}';
  }
}
