import 'package:flutter/material.dart';
import 'package:file_picker/file_picker.dart';
import 'package:untitled/utils/DbHandler.dart';
import 'package:untitled/utils/SqliteHandler.dart';
import 'main.dart';
import 'models/items.dart';
import 'models/orders.dart';
import 'models/points.dart';

class PurchaseStat {
  int itemId;
  int totalPurchases;
  int purchasesLastMonth;
  int purchasesLastTwoMonths;
  int purchasesAllOtherMonths;

  PurchaseStat({
    required this.itemId,
    required this.totalPurchases,
    required this.purchasesLastMonth,
    required this.purchasesLastTwoMonths,
    required this.purchasesAllOtherMonths,
  });

 PurchaseStat.fromJson(Map<String, dynamic> json)
     : itemId = int.parse(json['item_id'].toString()),
        totalPurchases = int.parse(json['total_purchases'].toString()),
        purchasesLastMonth = int.parse(json['purchases_last_month'].toString()),
        purchasesLastTwoMonths = int.parse(json['purchases_last_two_months'].toString()),
        purchasesAllOtherMonths = int.parse(json['purchases_all_other_months'].toString());

  // Остальные методы класса...
}



class AdminPage extends StatefulWidget {
  const AdminPage({Key? key}) : super(key: key);

  @override
  _AdminPageState createState() => _AdminPageState();
}

class _AdminPageState extends State<AdminPage> {
  int _currentIndex = 0;
  List<Order> orders = [];
  late bool isLoading = true;

  final _formKey = GlobalKey<FormState>();
  final _nameController = TextEditingController();
  final _descriptionController = TextEditingController();
  final _costController = TextEditingController();
  final _countController = TextEditingController();
  final _categoryController = TextEditingController();
  final _itemToDeleteController = TextEditingController();
  final _imageController = TextEditingController();
  final _raitingController = TextEditingController();
List<PurchaseStat>? _purchaseStats;
  PlatformFile? file;

  final DbHandler itemService = DbHandler();
  List<Item> _items = [];
  List<Item> _searchItems = [];

  List<Point> outputPointList = [];

  void getItems(){
    DbHandler.fetchItems().then((items) {
      setState(() {
        _items = items;
      });
      _searchItems.clear();
      for(var i in _items){
        _searchItems.add(i);
      }
      print(items);
      SqliteHandler.deleteItems().then((result){
        for(var i in _items){
          SqliteHandler.insertItem(i.id!, i.name!, i.description!, i.cost!, i.count!,i.raiting!,i.createdAt!);
        }
      });
    });
  }
void editItem(int itemId) {
  try {
    // Найдите элемент по ID
    Item item = _items.firstWhere((element) => element.id == itemId);

    // Заполните поля формы данными элемента
    _nameController.text = item.name ?? '';
    _descriptionController.text = item.description ?? '';
    _costController.text = item.cost.toString();
    _countController.text = item.count.toString();
    _categoryController.text = item.category ?? '';
    _raitingController.text = item.raiting.toString() ?? '';

    // Откройте форму редактирования
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text('Редактирование элемента'),
          content: SingleChildScrollView(
            child: Form(
              key: _formKey,
              child: Column(
                children: [
                  _buildTextField("Название", Icons.edit, _nameController),
                  SizedBox(height: 18.0),
                  _buildFormField("Описание", _descriptionController, isNumeric: false),
                  SizedBox(height: 18.0),
                  _buildFormField("Стоимость", _costController, isNumeric: true, isNonNegative: true, validator: validateNumeric),
                  SizedBox(height: 18.0),
                  _buildFormField("Количество", _countController, isNumeric: true, isNonNegative: true, validator: validateNumeric),
                  SizedBox(height: 18.0),
                  _buildFormField("Категория", _categoryController, isNumeric: false),
                  SizedBox(height: 18.0),
                  _buildFormField("Рейтинг", _raitingController, isNumeric: true, isNonNegative: true, validator: validateRating),
                ],
              ),
            ),
          ),
          actions: [
            TextButton(
              onPressed: () async {
                if (_formKey.currentState!.validate()) {
                  // Создайте map с новыми данными элемента
                  Map<String, dynamic> newItemData = {
                    'name': _nameController.text,
                    'description': _descriptionController.text,
                    'cost': double.parse(_costController.text).toInt(),
                    'count': int.parse(_countController.text),
                    'category': _categoryController.text,
                    'rating': int.parse(_raitingController.text),
                  };

                  // Сохраните обновленный элемент в базе данных
                  await DbHandler.updateItem(itemId, newItemData).then((_) {
                    // После успешного обновления перезагрузите список элементов
                    getItems();
                    Navigator.pop(context); // Закройте диалоговое окно
                  }).catchError((error) {
                    // Обработка ошибок
                    print("Ошибка при обновлении элемента: $error");
                    Navigator.pop(context); // Закройте диалоговое окно
                  });
                }
              },
              child: Text('Сохранить'),
            ),
            TextButton(
              onPressed: () {
                Navigator.pop(context);
              },
              child: Text('Отмена'),
            ),
          ],
        );
      },
    );
  } catch (e) {
    print("Элемент с ID $itemId не найден");
  }
}


  void getOrders(){
    DbHandler.fetchUserOrders(-1).then((result){
      setState(() {
        print(result);
        orders = result;
      });
    });
  }

  void logout(){
    Navigator.push(
        context,
        MaterialPageRoute(
            builder: (context) => MyApp()));
  }

  @override
  void initState() {
    super.initState();
    getItems();
    _loadPurchaseStats();
    // DbHandler.showOrdersInAdmin().then((value) {
    //   orders = value;
    //   isLoading = false;
    // });
    getOrders();
  }

  String? validateText(String value) {
  if (value.isEmpty) {
    return 'Это поле не может быть пустым';
  }
  // Другие проверки, если необходимо
  return null;
}

String? validateNumeric(String? value) {
  if (value == null || value.isEmpty) {
    return 'Пожалуйста, введите число';
  }
  if (!RegExp(r'^[0-9]+$').hasMatch(value)) {
    return 'Пожалуйста, введите только цифры';
  }
  return null;
}

String? validateNonNegative(String? value) {
  if (value == null || value.isEmpty) {
    return 'Это поле не может быть пустым';
  }
  if (!RegExp(r'^[0-9]+$').hasMatch(value)) {
    return 'Введите только цифры';
  }
  int? numericValue = int.tryParse(value);
  if (numericValue != null && numericValue < 0) {
    return 'Введите неотрицательное значение';
  }
  return null;
}

String? validateRating(String? value) {
  if (value == null || value.isEmpty) {
    return 'Введите рейтинг';
  }
  int? numericValue = int.tryParse(value);
  if (numericValue == null || numericValue < 0 || numericValue > 10) {
    return 'Рейтинг должен быть числом от 0 до 10';
  }
  return null;
}


  Future pickImage() async {
    FilePickerResult? result = await FilePicker.platform.pickFiles();
    if(result != null){
      file = result.files.single;
      print("selected");
    }
  }
void _loadPurchaseStats() async {
  // No need to create an instance of DbHandler
  List<Map<String, dynamic>> rawStats = await DbHandler.fetchPurchaseStats();

  // Conversion of the list of maps to a list of PurchaseStat objects
  _purchaseStats = rawStats.map((rawStat) => PurchaseStat.fromJson(rawStat)).toList();

  setState(() {}); // Update UI after loading data
}



@override
Widget build(BuildContext context) {
  Size size = MediaQuery.of(context).size;
  return Scaffold(
    appBar: AppBar(
      backgroundColor: Color.fromARGB(255, 81, 20, 114),
      title: Text("Продавец", style: TextStyle(color: Colors.white)), // Изменяем цвет текста на белый
      iconTheme: IconThemeData(color: Colors.white), // Изменяем цвет иконок на белый
      actions: [
        Padding(
          padding: EdgeInsets.only(right: 16.0),
          child: IconButton(
            icon: Icon(Icons.refresh),
            onPressed: () {
              getItems();
              getOrders();
            },
          ),
        ),
        Padding(
          padding: EdgeInsets.only(right: 16.0),
          child: IconButton(
            icon: Icon(Icons.exit_to_app),
            onPressed: () {
              logout();
            },
          ),
        ),
      ],
    ),
    body: _currentIndex == 0
      ? SingleChildScrollView( // Обертываем содержимое в SingleChildScrollView
         child: Container(
           child: Padding(
             padding: const EdgeInsets.all(16.0),
             child: Card(
               color: Color.fromARGB(255, 240, 238, 238).withOpacity(0.5),
               shape: RoundedRectangleBorder(
                 borderRadius: BorderRadius.circular(16.0),
               ),
               child: Padding(
                 padding: const EdgeInsets.all(16.0),
                 child: Form(
                   key: _formKey,
                   child: Column(
                     crossAxisAlignment: CrossAxisAlignment.start,
                     children: [
                        _buildTextField("Вставьте ссылку на изображение", Icons.image, _imageController),
              SizedBox(height: 18.0),
              _buildFormField("Название", _nameController, isNumeric: false),
              SizedBox(height: 18.0),
              _buildFormField("Описание", _descriptionController, isNumeric: false),
              SizedBox(height: 18.0),
              _buildFormField("Стоимость", _costController, isNumeric: true, isNonNegative: true, validator: validateNumeric),
              SizedBox(height: 18.0),
              _buildFormField("Количество", _countController, isNumeric: true, isNonNegative: true, validator: validateNumeric),
              SizedBox(height: 18.0),
              _buildFormField("Категория", _categoryController, isNumeric: false),
              SizedBox(height: 18.0),
              _buildFormField("Рейтинг", _raitingController, isNumeric: true, isNonNegative: true, validator: validateRating),



                       SizedBox(height: 18.0),
                       Padding(
                         padding: const EdgeInsets.only(top: 50.0),
                         child: Center(
                           child: Container(
                             height: 50,
                             decoration: BoxDecoration(borderRadius: BorderRadius.circular(16)),
                             child: TextButton(
  style: ButtonStyle(
    backgroundColor: MaterialStateProperty.all(Colors.grey.withOpacity(0.0)),
    foregroundColor: MaterialStateProperty.all(Colors.black),
  ),
 onPressed: () async {
  if (_formKey.currentState!.validate()) {
    // Если форма прошла валидацию, продолжаем обработку данных
    final String name = _nameController.text;
    final String description = _descriptionController.text;
    final String cost = _costController.text;
    final String count = _countController.text;
    final String category = _categoryController.text;
    final String image = _imageController.text;
    DbHandler dbHandler = DbHandler();
    // Проверяем, что рейтинг не пуст и является числом
    if (_raitingController.text.isNotEmpty && int.tryParse(_raitingController.text)!= null) {
      final int raiting = int.parse(_raitingController.text);
      DbHandler item = DbHandler();
      await item.createItem(name, description, cost, count, category, image, raiting);
      // Очистка полей после успешного добавления
      _nameController.clear();
      _descriptionController.clear();
      _costController.clear();
      _countController.clear();
      _categoryController.clear();
      _raitingController.clear();
      _imageController.clear();
    } else {
      print("Ошибка: рейтинг должен быть числом и не должен быть пустым");
    }
  } else {
    // Если форма не прошла валидацию, отображаем сообщения об ошибках
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text('Пожалуйста, исправьте ошибки в форме.'),
      ),
    );
  }
},
child: const Text('Добавить', style: TextStyle(color: Color.fromARGB(255, 81, 20, 114), fontSize: 18)),

),
                           ),
                         ),
                       ),
                       SizedBox(height: 16.0),
                     ],
                   ),
                 ),
               ),
             ),
           ),
         ),
       )
       : _currentIndex == 2
      ? Container(
           child: Column(
             mainAxisAlignment: MainAxisAlignment.start,
             children: [
               Expanded(
                 child: ListView.builder(
                   itemCount: orders.length,
                   itemBuilder: (context, index) {
                     Order order = orders[index];
                     return ListTile(
                       contentPadding: EdgeInsets.all(8),
                       onTap: (){
                         print(order);
                         DbHandler.fetchOrderDetails(order.id!).then((orderDetails){
                           print(orderDetails);
                           int orderTotalPrice = 0;
                           for(var detail in orderDetails){
                             orderTotalPrice += detail.total!;
                           }
                           showDialog(
                               context: context,
                               builder: (BuildContext context) {
                                 return Dialog(
                                   shape: RoundedRectangleBorder(
                                       borderRadius:
                                       BorderRadius.circular(1.0)),
                                   child: Container(
                                     height: MediaQuery.of(context).size.height,
                                     width: MediaQuery.of(context).size.width*0.25,
                                     child: Padding(
                                       padding: const EdgeInsets.all(12.0),
                                       child: Column(
                                         children: [
                                           Text(
                                             "Номер заказа: ${order.id}",
                                           ),
                                           Text(
                                               "Адрес: ${order.poiAdress}"
                                           ),
                                           Text(
                                             "Телефон заказчика: ${order.userPhone}",
                                           ),
                                           Text(
                                             "Статус: ${order.status}",
                                           ),
                                           Divider(thickness: 1,),
                                           SizedBox(height: 8,),
                                           Container(
                                              height: 300,
                                             child: ListView.builder(
                                               itemCount: orderDetails.length,
                                               itemBuilder: (BuildContext context, int index) {
                                                 final order = orderDetails[index];
                                                 return ListTile(
                                                   contentPadding: EdgeInsets.all(14),
                                                   title: Text('Название: ${order.name}'),
                                                   subtitle: Column(
                                                     crossAxisAlignment: CrossAxisAlignment.start,
                                                     children: [
                                                       Text('Стоимость: ${order.cost} BYN'),
                                                       Text('Количество: ${order.count}'),
                                                     ],
                                                   ),
                                                   trailing: Text('${order.total} BYN'),
                                                 );
                                               },
                                             ),
                                           ),
                                           Container(
                                             margin: EdgeInsets.all(32),
                                             child: Text(
                                               "Итого: ${orderTotalPrice} BYN",
                                               style: const TextStyle(
                                                   fontSize: 20
                                               ),
                                             ),
                                           ),
                                           Center(
                                             child: Container(
                                               height: 40,
                                               decoration:
                                               BoxDecoration(borderRadius: BorderRadius.circular(16) ),
                                               child: TextButton(
                                                 style: ButtonStyle(backgroundColor: MaterialStateProperty.all(Colors.grey.withOpacity(0.0)),
                                                     foregroundColor: MaterialStateProperty.all(Colors.black)),
                                                 onPressed: (){
                                                   DbHandler.updateOrderStatus(order.id!, "готов к отправлению").then((result){
                                                     getOrders();
                                                   });
                                                   Navigator.pop(context);
                                                 },
                                                 child: const Text('Готов к отправлению', style: TextStyle(color: Color.fromARGB(255, 0, 0, 0), fontSize: 18)),
                                               ),
                                             ),
                                           ),
                                           Center(
                                             child: Container(
                                               height: 40,
                                               decoration:
                                               BoxDecoration(borderRadius: BorderRadius.circular(16) ),
                                               child: TextButton(
                                                 style: ButtonStyle(backgroundColor: MaterialStateProperty.all(Colors.grey.withOpacity(0.0)),
                                                     foregroundColor: MaterialStateProperty.all(Colors.black)),
                                                 onPressed: (){
                                                   DbHandler.updateOrderStatus(order.id!, "доставлен").then((result){
                                                     getOrders();
                                                   });
                                                   Navigator.pop(context);
                                                 },
                                                 child: const Text('Доставлен', style: TextStyle(color: Color.fromARGB(255, 0, 0, 0), fontSize: 18)),
                                               ),
                                             ),
                                           ),
                                           Center(
                                             child: Container(
                                               height: 40,
                                               decoration:
                                               BoxDecoration(borderRadius: BorderRadius.circular(16) ),
                                               child: TextButton(
                                                 style: ButtonStyle(backgroundColor: MaterialStateProperty.all(Colors.grey.withOpacity(0.0)),
                                                     foregroundColor: MaterialStateProperty.all(Colors.black)),
                                                 onPressed: (){
                                                   Navigator.pop(context);
                                                 },
                                                 child: const Text('Выйти', style: TextStyle(color: Color.fromARGB(255, 0, 0, 0), fontSize: 18)),
                                               ),
                                             ),
                                           ),
                                         ],
                                       ),
                                     ),
                                   ),
                                 );
                               });
                         });
                       },
                       title: Column(
                         crossAxisAlignment: CrossAxisAlignment.start,
                         children: [
                           Text('Номер заказа: ${order.id}'),
                           Text('Дата оформления: ${order.createdAt}'),
                           Text('Пункт выдачи: ${order.poiName} – ${order.poiAdress}'),
                           Text('Статус: ${order.status}'),
                           const Divider(
                             height: 10,
                             thickness: 1,
                             indent: 1,
                             endIndent: 0,
                             color: Color.fromARGB(255, 81, 20, 114),
                           ),
                         ],
                       ),
                     );
                   },
                 ),
               ),
             ],
           ),
         )
        : _currentIndex == 4
      ? FutureBuilder<List<Map<String, dynamic>>>(
        
   future: DbHandler.fetchPurchaseStats(), // Assuming DbHandler has a constructor that accepts fetchPurchaseStats as a parameter
  builder: (BuildContext context, AsyncSnapshot<List<Map<String, dynamic>>> snapshot) {
    if (snapshot.connectionState == ConnectionState.waiting) {
      return CircularProgressIndicator(); // Display loading indicator
    } else if (snapshot.hasError) {
      return Text('Ошибка: ${snapshot.error}');
    } else {
      _purchaseStats = snapshot.data!.map((rawStat) => PurchaseStat.fromJson(rawStat)).toList();
      return ListView.builder(
        itemCount: _purchaseStats!= null? _purchaseStats?.length : 0, // Safely access length
        itemBuilder: (context, index) {
          final stat = _purchaseStats?[index]; // Safely access element
          if (stat!= null) { // Ensure stat is not null before accessing its properties
            return Card(
              child: Column(
                children: [
                  Text("ID: ${stat.itemId}"),
                  Text("Total Purchases: ${stat.totalPurchases}"),
                  Text("Last Month Purchases: ${stat.purchasesLastMonth}"),
                  Text("Last Two Months Purchases: ${stat.purchasesLastTwoMonths}"),
                  Text("All Other Months Purchases: ${stat.purchasesAllOtherMonths}"),
                ],
              ),
            );
          } else {
            return SizedBox.shrink(); // Return an empty widget if stat is null
          }
        },
      );
    }
  },
)


       : _currentIndex == 1
      ? Column(
           children: <Widget>[
             Expanded(
               child: Center(
                 child: Container(
                   height: double.infinity,
                   child: ListView.builder(
                     itemCount: _items.length,
                     itemBuilder: (context, index) {
                       final item = _items[index];
                       var itemImage = "";
                       if(item.image!= null){
                         itemImage = item.image!;
                       }
                       else{
                         itemImage = "https://vjoy.cc/wp-content/uploads/2020/07/sakura_7_27121154.jpg";
                       }
                       return Card(
                         child: Column(
                           children: [
                             Image.network(itemImage,       
                             width: 200,
                             height: 100, ),
                             Text("Идентификатор: ${item.id}"),
                             Text("Название: ${item.name}"),
                             Text("Описание: ${item.description}"),
                             Text("Цена: ${item.cost}"),
                           ],
                         ),
                       );
                     },
                   ),
                 ),
               ),
             ),
             Center(
               child: Padding(
                 padding: const EdgeInsets.symmetric(vertical: 10.0),
                 child: Container(
                   height: 50,
                   width: size.width * 0.7,
                   decoration: BoxDecoration(
                     color: Colors.grey[500]?.withOpacity(0.5),
                     borderRadius: BorderRadius.circular(1),
                   ),
                   child: TextFormField(
                     style: const TextStyle(color: Color.fromARGB(255, 81, 20, 114)),
                     controller: _itemToDeleteController,
                     decoration: const InputDecoration(
                       labelStyle: TextStyle(color: Color.fromARGB(255, 81, 20, 114)),
                       labelText: "Введите идентификатор товара",
                       border: OutlineInputBorder(),
                     ),
                     validator: (value) {
                       if (value == null || value.isEmpty) {
                         return "Введите название товара для удаления";
                       }
                       return null;
                     },
                   ),
                 ),
               ),
             ),
             Center(
               child: Container(
                 height: 50,
                 decoration: BoxDecoration(borderRadius: BorderRadius.circular(16)),
                 child: TextButton(
                   style: ButtonStyle(
                     backgroundColor: MaterialStateProperty.all(Colors.grey.withOpacity(0.0)),
                     foregroundColor: MaterialStateProperty.all(Colors.black),
                   ),
                   onPressed: () async {
                     final String name = _itemToDeleteController.text;
                     DbHandler item = DbHandler();
                     await item.deleteItem(name);
                     _itemToDeleteController.clear(); // Очистка поля ввода после удаления
  getItems(); // Обновление списка элементов
  setState(() {});
                   },
                   child: const Text('Удалить', style: TextStyle(color: Color.fromARGB(255, 81, 20, 114), fontSize: 18)),
                 ),
               ),
             ),
             SizedBox(height: 16.0),
           ],
         )
          : _currentIndex == 3
 ? Column(
  children: [
    if (_currentIndex == 3)
      Expanded(
        child: Center(
          child: Container(
            height: double.infinity,
            child: ListView.builder(
              itemCount: _items.length,
              itemBuilder: (context, index) {
                final item = _items[index];
                String itemImage = item.image!= null? item.image! : "https://vjoy.cc/wp-content/uploads/2020/07/sakura_7_27121154.jpg";
                return GestureDetector( // Используйте GestureDetector для обработки касаний
                  onTap: () => editItem(item.id!), // Обработчик нажатия
                  child: Card(
                    child: Column(
                      children: [
                        Image.network(itemImage, width: 200, height: 100),
                        Text("Идентификатор: ${item.id}"),
                        Text("Название: ${item.name}"),
                        Text("Описание: ${item.description}"),
                        Text("Цена: ${item.cost}"),
                      ],
                    ),
                  ),
                );
              },
            ),
          ),
        ),
      ),
    // Другой виджет или логика, которая должна отображаться при других условиях
  ],
)
       : Container(),

drawer: Drawer(
  child: Column(
    children: [
      ListTile(
        title: Text('Добавить новый товар', style: TextStyle(color: _currentIndex == 0? Colors.white : Colors.black)),
        tileColor: _currentIndex == 0? Color.fromARGB(255, 81, 20, 114) : null,
        onTap: () {
          setState(() {
            _currentIndex = 0;
            Navigator.pop(context);
          });
        },
      ),
      ListTile(
        title: Text('Удалить товар', style: TextStyle(color: _currentIndex == 1? Colors.white : Colors.black)),
        tileColor: _currentIndex == 1? Color.fromARGB(255, 81, 20, 114) : null,
        onTap: () {
          setState(() {
            _currentIndex = 1;
            Navigator.pop(context);
          });
        },
      ),
      ListTile(
        title: Text('Изменить товар', style: TextStyle(color: _currentIndex == 3? Colors.white : Colors.black)),
        tileColor: _currentIndex == 3? Color.fromARGB(255, 81, 20, 114) : null,
        onTap: () {
          setState(() {
            _currentIndex = 3; // Correctly set to 3 for editing products
            Navigator.pop(context);
          });
        },
      ),
      ListTile(
        title: Text('Просмотреть текущие заказы', style: TextStyle(color: _currentIndex == 2? Colors.white : Colors.black)),
        tileColor: _currentIndex == 2? Color.fromARGB(255, 81, 20, 114) : null,
        onTap: () {
          setState(() {
            _currentIndex = 2;
            Navigator.pop(context);
          });
        },
      ),
      ListTile(
        title: Text('Посмотреть результаты продаж', style: TextStyle(color: _currentIndex == 4? Colors.white : Colors.black)),
        tileColor: _currentIndex == 4? Color.fromARGB(255, 81, 20, 114) : null,
        onTap: () {
          setState(() {
            _currentIndex = 4; // Correctly set to 4 for viewing sales results
            Navigator.pop(context);
          });
        },
      ),
    ],
  ),
),
    );
  }
}
Widget _buildTextField(String hintText, IconData? prefixIcon, TextEditingController controller) {
  return TextField(
    controller: controller,
    decoration: InputDecoration(
      border: OutlineInputBorder(
        borderRadius: BorderRadius.circular(16),
        borderSide: BorderSide(color: Colors.grey),
      ),
      focusedBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(16),
        borderSide: BorderSide(color: Color.fromARGB(255, 81, 20, 114)), // Цвет границы при активации
      ),
      prefixIcon: Container(
        child: Icon(prefixIcon, color: Color.fromARGB(255, 81, 20, 114)),
        padding: const EdgeInsets.only(left: 16, right: 16),
      ),
      hintStyle: const TextStyle(color: Color.fromARGB(255, 81, 20, 114)),
      hintText: hintText,
    ),
    style: const TextStyle(color: Color.fromARGB(255, 81, 20, 114)),
  );
}

Widget _buildFormField(String labelText, TextEditingController controller, {bool isNumeric = false, bool isNonNegative = false, String? Function(String?)? validator}) {
  return TextFormField(
    style: const TextStyle(color: Color.fromARGB(255, 81, 20, 114)),
    controller: controller,
    keyboardType: isNumeric? TextInputType.number : TextInputType.text,
    decoration: InputDecoration(
      labelStyle: const TextStyle(color: Color.fromARGB(255, 81, 20, 114)),
      labelText: labelText,
      border: OutlineInputBorder(
        borderRadius: BorderRadius.circular(16),
      ),
      focusedBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(16),
        borderSide: const BorderSide(color: Color.fromARGB(255, 81, 20, 114)), // Цвет границы при активации
      ),
    ),
    validator: validator,
  );
}


