import 'package:flutter/material.dart';
import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';
import 'package:http/http.dart' as http;
import 'package:untitled/models/OrderDetail.dart';
import 'package:untitled/utils/DbHandler.dart';
import 'package:untitled/utils/SqliteHandler.dart';
import 'main.dart';
import 'models/User.dart';
import 'models/items.dart';
import 'models/orders.dart';
import 'models/points.dart';
import 'models/coments.dart';
import 'itempage.dart';
import 'package:intl/intl.dart';

class MainPageOfShop extends StatefulWidget {
  const MainPageOfShop({Key? key}) : super(key: key);

  @override
  _MainPageOfShopState createState() => _MainPageOfShopState();
}



class EditProfilePage extends StatefulWidget {
 final User user;

 EditProfilePage({required this.user});

 @override
 _EditProfilePageState createState() => _EditProfilePageState();
}

class _EditProfilePageState extends State<EditProfilePage> {
 final _formKey = GlobalKey<FormState>();
 late TextEditingController _nameController;
 late TextEditingController _loginController;
 late TextEditingController _phoneController;
 late TextEditingController _imageUrlController;
  late TextEditingController _passwordController;
 final DbHandler dbHandler = DbHandler();

 @override
 void initState() {
    super.initState();
    _nameController = TextEditingController(text: widget.user.name);
    _loginController = TextEditingController(text: widget.user.login);
    _phoneController = TextEditingController(text: widget.user.phonenumber);
    _imageUrlController = TextEditingController(text: '');
    _passwordController = TextEditingController(text: '');
 }

 @override
 void dispose() {
    _nameController.dispose();
    _loginController.dispose();
    _phoneController.dispose();
    _imageUrlController.dispose();
    _passwordController.dispose();
    super.dispose();
 }

 @override
Widget build(BuildContext context) {
  return Scaffold(
    appBar: AppBar(
      backgroundColor: Colors.purple, // Изменение фона на белый
      foregroundColor: Colors.white, // Изменение цвета текста на черный
      leading: IconButton(
        icon: Icon(Icons.arrow_back), // Стрелка назад
        onPressed: () {
          Navigator.pop(context); // Возвращение на предыдущий экран
        },
      ),
      title: Text('Редактирование профиля'), // Текст "Редактирование профиля"
    ),
    body: Form(
      key: _formKey,
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
            TextFormField(
              controller: _nameController,
              decoration: InputDecoration(labelText: 'Имя'),
              validator: (value) {
                if (value == null || value.isEmpty) {
                  return 'Пожалуйста, введите имя';
                }
                return null;
              },
            ),
            TextFormField(
              controller: _loginController,
              decoration: InputDecoration(labelText: 'Логин'),
              validator: (value) {
                if (value == null || value.isEmpty) {
                  return 'Пожалуйста, введите логин';
                }
                return null;
              },
            ),
            TextFormField(
              controller: _phoneController,
              decoration: InputDecoration(labelText: 'Телефон'),
              validator: (value) {
                if (value == null || value.isEmpty) {
                  return 'Пожалуйста, введите телефон';
                }
                return null;
              },
            ),
            TextFormField(
              controller: _imageUrlController,
              decoration: InputDecoration(labelText: 'URL изображения'),
              validator: (value) {
                if (value == null || value.isEmpty) {
                  return null;
                }
                return null;
              },
            ),
            TextFormField(
              controller: _passwordController,
              decoration: InputDecoration(labelText: 'Новый пароль'),
              validator: (value) {
                if (value == null || value.isEmpty) {
                  return null;
                }
                return null;
              },
            ),
            SizedBox(width: 20,height: 20,),
ElevatedButton(
  onPressed: () {
    if (_formKey.currentState!.validate()) {
      // Получаем значение из контроллера пароля
      String newPassword = _passwordController.text;
      
      // Создаем обновленного пользователя с учетом нового пароля
      User updatedUser = User(
        id: widget.user.id,
        name: _nameController.text,
        login: _loginController.text,
        phonenumber: _phoneController.text,
        user_image: _imageUrlController.text,
        password: newPassword.isEmpty ? widget.user.password : newPassword,
      );
      
      // Обновляем профиль пользователя в базе данных
      dbHandler.updateUserProfile(updatedUser).then((_) {
        User.currentUser = updatedUser;
        
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Профиль успешно обновлен')),
        );
        
        Navigator.pop(context, updatedUser);
      }).catchError((error) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Ошибка обновления профиля: $error')),
        );
      });
    }
  },
  style: ElevatedButton.styleFrom(
    backgroundColor: Colors.purple,
    shape: RoundedRectangleBorder(
      borderRadius: BorderRadius.circular(10),
    ),
  ),
  child: Text(
    'Сохранить изменения',
    style: TextStyle(color: Colors.white),
  ),
),

          ],
        ),
      ),
    ),
  );

}
}



class UserProfilePage extends StatefulWidget {
  User user;

  UserProfilePage({required this.user});

  @override
  _UserProfilePageState createState() => _UserProfilePageState();
}

class _UserProfilePageState extends State<UserProfilePage> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
      ),
      body: Padding(
        padding: EdgeInsets.only(top: 20),
        child: Column(
          children: <Widget>[
            SizedBox(height: 40),
            // Центрирование изображения
            Align(
              alignment: Alignment.topCenter,
              child: widget.user.user_image == null
                  ? CircleAvatar(
                      radius: 50,
                      child: Icon(
                        Icons.person, // Иконка пользователя
                        size: 50, // Размер иконки
                        color: Colors.white, // Цвет иконки
                      ),
                      backgroundColor: Colors.blue, // Фон иконки
                    )
                  : CircleAvatar(
                      radius: 50,
                      backgroundImage: NetworkImage(widget.user.user_image!),
                    ),
            ),
            SizedBox(height: 20),
            // Текст, прижатый к левому краю
            Align(
              alignment: Alignment.centerLeft,
              child: Padding(
                padding: EdgeInsets.symmetric(horizontal: 20),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Имя: ${widget.user.name!}',
                      style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
                    ),
                    Text(
                      'Логин: ${widget.user.login!}',
                      style: TextStyle(fontSize: 18, fontWeight: FontWeight.w500),
                    ),
                    Text(
                      'Номер телефона: ${widget.user.phonenumber!}',
                      style: TextStyle(fontSize: 18, fontWeight: FontWeight.w500),
                    ),
                  ],
                ),
              ),
            ),
            SizedBox(height: 20),
            // Кнопка по центру
           Center(
  child: ElevatedButton(
    onPressed: () async {
      final updatedUser = await Navigator.push(
        context,
        MaterialPageRoute(
          builder: (context) => EditProfilePage(user: widget.user),
        ),
      );
      if (updatedUser!= null) {
        setState(() {
          widget.user = updatedUser;
        });
      }
    },
    style: ButtonStyle(
      backgroundColor: MaterialStateProperty.all(Colors.purple), // Фон кнопки
      shape: MaterialStateProperty.all<RoundedRectangleBorder>(
        RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(10), // Закругление углов
        ),
      ),
      foregroundColor: MaterialStateProperty.all(Colors.white), // Цвет текста
    ),
    child: Container(
      width: 200, // Ширину контейнера устанавливаем равной 200 пикселям
      child: Center( // Центрирование текста внутри контейнера
        child: Text(
          'Редактировать профиль', // Текст кнопки
          style: TextStyle(color: Colors.white), // Стиль текста
          textAlign: TextAlign.center, // Выравнивание текста по центру
        ),
      ),
    ),
  ),
),

          ],
        ),
      ),
    );
  }
}






class _MainPageOfShopState extends State<MainPageOfShop> {
  TextEditingController pointOneController = TextEditingController();
  TextEditingController pointOTwoController = TextEditingController();
  TextEditingController pointThreeController = TextEditingController();

  TextEditingController searchController = TextEditingController();

  final DbHandler itemService = DbHandler();
  List<Item> _items = [];
  List<Item> _searchItems = [];
  List<Order> _orders = [];
  List<OrderDetail> _orderDetails = [];
  Point? _selectedPoint;
  List<Point> _pointsList = [];
  List<Point> outputPointList = [];
  bool _isPublic = false;
  List<Item> _orderItems = [];
  List<Item> _filteredItems = [];

  

 void showAddCommentDialog(BuildContext context, int itemId) {
  TextEditingController commentController = TextEditingController();

  showDialog(
    context: context,
    builder: (BuildContext context) {
      return AlertDialog(
        title: const Text('Добавить комментарий'),
        content: TextField(
          controller: commentController,
          decoration: const InputDecoration(hintText: 'Введите ваш комментарий'),
        ),
        actions: [
          TextButton(
            onPressed: () {
              Navigator.of(context).pop(); // Закрыть диалоговое окно
            },
            child: const Text('Отмена'),
          ),
          TextButton(
  onPressed: () async {
    try {
      // Создаем экземпляр DbHandler
      DbHandler dbHandler = DbHandler();
      // Используем вашу функцию addComment для отправки запроса на сервер
      Comment newComment = await dbHandler.addComment(itemId, User.currentUser.id!, commentController.text);
      print(newComment); // Выводим информацию о добавленном комментарии
      Navigator.of(context).pop(); // Закрыть диалоговое окно
    } catch (e) {
      print("Ошибка при добавлении комментария: $e");
      // Отображаем AlertDialog с сообщением об ошибке
      showDialog(
        context: context,
        builder: (BuildContext context) {
          return AlertDialog(
            title: const Text('Ошибка'),
            content: const Text('Комментарий не может быть пустым.'),
            actions: [
              TextButton(
                onPressed: () {
                  Navigator.of(context).pop(); // Закрыть диалоговое окно
                },
                child: const Text('OK'),
              ),
            ],
          );
        },
      );
    }
  },
  child: const Text('Добавить'),
),

        ],
      );
    },
  );
}


void showCommentsDialog(BuildContext context, int itemId) {
 // Создаем экземпляр DbHandler
 DbHandler dbHandler = DbHandler();

 showDialog(
    context: context,
    builder: (BuildContext context) {
      return AlertDialog(
        title: const Text('Комментарии к товару'),
        content: Container(
          width: double.maxFinite, // Задаем максимальную ширину
          height: 300, // Задаем высоту
          child: FutureBuilder<List<Comment>>(
            future: dbHandler.fetchCommentsForItem(itemId), // Используем метод из DbHandler
            builder: (context, snapshot) {
              if (snapshot.connectionState == ConnectionState.waiting) {
                return Center(child: CircularProgressIndicator());
              } else if (snapshot.hasError) {
                return Text("Ошибка при загрузке комментариев");
              } else if (snapshot.hasData) {
                return ListView.builder(
                 itemCount: snapshot.data!.length,
                 itemBuilder: (context, index) {
                    return ListTile(
                      title: Text(snapshot.data![index].description!),
                      // Добавьте здесь другие поля комментария, если необходимо
                    );
                 },
                );
              }
              return Container(); // Возвращаем пустой контейнер, если ни одно из условий не выполняется
            },
          ),
        ),
        actions: [
          TextButton(
            onPressed: () {
              Navigator.of(context).pop(); // Закрыть диалоговое окно
            },
            child: const Text('Закрыть'),
          ),
        ],
      );
    },
 );
}

void getUserOrders(){
    DbHandler.fetchUserOrders(User.currentUser.id!).then((result){
      print(result);
      setState(() {
        _orders = result;
        
       // _orderDetails = _orders.map((order) => OrderDetail.fromOrder(order)).toList();
      });
      SqliteHandler.deleteUsers().then((result){
        SqliteHandler.deleteOrders().then((result){
          SqliteHandler.insertUser(User.currentUser.id!, User.currentUser.name!, User.currentUser.login!, User.currentUser.phonenumber!);
          for(var o in _orders){
            SqliteHandler.insertOrder(o.id!, o.point_id!, o.user_id!, o.status!, o.createdAt.toString());
          }
        });
      });

    }).catchError((error){
      print(error);
    });
  }

void sortItemsByPrice() {
  setState(() {
    _items = _items.where((item) => item!= null).toList(); // Удаляем null элементы
    _items.sort((a, b) => a.cost?.compareTo(b.cost!)?? 0); // Проверяем на null перед сравнением
  });


}



  void sortItemsByPriceDesc() {
  setState(() {
    _items.sort((a, b) => b.cost?.compareTo(a.cost!)?? 0);
  });
}






void getItems(){
  DbHandler.fetchItems().then((items) {
    setState(() {
      _items = items;
    });
    _searchItems.clear();
    for(var i in _items){
      // Создаем новый объект Item с полным набором данных
      _searchItems.add(Item(
        id: i.id, 
        name: i.name, 
        description: i.description, 
        cost: i.cost, 
        count: i.count, 
        image: i.image, 
        category: i.category, 
        raiting: i.raiting, 
        createdAt: i.createdAt
      ));
    }
    print(items);
    SqliteHandler.deleteItems().then((result){
      for(var i in _items){
        SqliteHandler.insertItem(i.id!, i.name!, i.description!, i.cost!, i.count!, i.raiting!, i.createdAt);
      }
    });
  });
}



  void sortItemsByDateCreated() {
  setState(() {
    _items = Item.sortItemsByCreatedAt(_items);
  });
}
  void sortItemsByDateCreated2() {
  setState(() {
    _items = Item.sortItemsByCreatedAt2(_items);
  });
}
  void sortItemsByCount() {
  setState(() {
    _items = Item.sortItemsByCount(_items);
  });
}

  void logout(){
    Navigator.push(
        context,
        MaterialPageRoute(
            builder: (context) => const MyApp()));
  }
List<Item> filterItemsBySearch(String searchValue) {
  return _items.where((item) => item.toSearchString().contains(searchValue)).toList();
}



void onSearchTextChanged(String value) {
  setState(() {
    _filteredItems = filterItemsBySearch(value);
  });
}
bool _isFormActive = true;
FocusNode _focusNode = FocusNode();
  @override
  void initState() {
    super.initState();
      _focusNode.addListener(() {
     if (!_focusNode.hasFocus && _isFormActive) {
      // Фокус убран, так что скрываем клавиатуру
      _focusNode.unfocus();
      setState(() {
        _isFormActive = false;
      });
    } else if (_focusNode.hasFocus && !_isFormActive) {
      setState(() {
        _isFormActive = true;
      });
    }
  });
    print(User.currentUser);
    
    pointOneController = TextEditingController();
    pointOTwoController = TextEditingController();
    pointThreeController = TextEditingController();
    getItems();
    getUserOrders();
    DbHandler.fetchPoints().then((points) {
      setState(() {
        _pointsList = points;
      });
      SqliteHandler.deletePoints().then((result){
        for(var p in _pointsList){
          SqliteHandler.insertPointOfIssue(p.id!, p.name!, p.adress!);
        }
      });
      
    });

    // DbHandler.getOrderId().then((value) => {
    //       DbHandler.fetchOrderItems(value)
    //           .then((value) => {_orderItems = value})
    //     });
  }
void sortItemsByRating() {
  setState(() {
    _items = Item.sortItemsByRating(_items);
  });
}

  @override
  void dispose() {
    super.dispose();
    pointOneController.dispose();
    pointOTwoController.dispose();
    pointThreeController.dispose();
    _focusNode.dispose();
  }
@override
Widget build(BuildContext context) {
  return MaterialApp(
    debugShowCheckedModeBanner: false,
    title: "_title",
    home: DefaultTabController(
      initialIndex: 0,
      length: 4,
      child: Scaffold(
        appBar: AppBar(
          backgroundColor: const Color.fromARGB(255, 81, 20, 114),
          title: Center(
            child: TextField(
              controller: searchController,
              autofocus: false,
              focusNode: _focusNode,
               onTap: () {
      if (!_isFormActive) {
        setState(() {
          _isFormActive = true;
        });
      } else {
        _isFormActive = false;
      }
    },
    onChanged: (value) {
      if (value == "") {
        getItems();
      } else {
        try {
          for (var i in _items) {
            if (!i.toSearchString().contains(value)) {
              setState(() {
                _items.remove(i);
              });
            }
          }
        } catch (error) {}
      }
    },
              style: TextStyle(color: Colors.white),
              decoration: InputDecoration(
                hintStyle: TextStyle(color: Colors.white),
                hintText: 'Поиск/фильтрация',
                prefixIcon: GestureDetector(
                  onTap: () {
                    if (_isFormActive) {
                      // Clear the search text
                      searchController.clear();
                    } else {
                      // Perform your desired action when the form is inactive
                      print('Form is inactive');
                    }
                    // Hide the keyboard and remove the cursor
                    FocusScope.of(context).unfocus();
                    setState(() {
                      _isFormActive = !_isFormActive;
                    });
                  },
                  child: Icon(
                    Icons.search,
                    color: Colors.white,
                  ),
                ),
                border: InputBorder.none,
              ),
            ),
          ),
        

            actions: [

              Padding(
                padding: const EdgeInsets.only(right: 16.0),
                child: IconButton(
                  icon: const Icon(Icons.refresh),
                  color: Colors.white,
                  onPressed: () {
                    getItems();
                    getUserOrders();
                    searchController.clear();
                     setState(() { });
                  },
                ),
              ),
Padding(
  padding: const EdgeInsets.only(right: 16.0),
  child: IconButton(
    icon: const Icon(Icons.sort),
    color: Colors.white,
    onPressed: () {
      final RenderBox renderBox = context.findRenderObject() as RenderBox;
      final Offset offset = renderBox.localToGlobal(Offset.zero);

      showMenu(
        context: context,
        position: RelativeRect.fromRect(
          Rect.fromLTWH(offset.dx, offset.dy, 0, 0), // Используем текущее положение кнопки
          Rect.fromLTWH(0, 0, 0, 0), // Используем пустой прямоугольник для позиционирования относительно кнопки
        ),
        items: <PopupMenuEntry>[
          PopupMenuItem<String>(
            value: 'От большего к меньшему',
            child: Text('От большего к меньшему'),
          ),
          PopupMenuItem<String>(
            value: 'По рейтингу',
            child: Text('По рейтингу'),
          ),
          PopupMenuItem<String>(
            value: 'От меньшего к большему',
            child: Text('От меньшего к большему'),
          ),
          PopupMenuItem<String>(
            value: 'Более новые',
            child: Text('Более новые'),
          ),
           PopupMenuItem<String>(
            value: 'Более старые',
            child: Text('Более старые'),
          ),
          PopupMenuItem<String>(
      value: 'Сортировка по количеству',
      child: Text('Сортировка по количеству'),
    ),
        ],
        elevation: 8.0,
      ).then((selectedValue) {
        if (selectedValue!= null) {
          if (selectedValue == 'От большего к меньшему') {
            sortItemsByPriceDesc();
          } else if (selectedValue == 'По рейтингу') {
            sortItemsByRating();
          } else if (selectedValue == 'От меньшего к большему') {
            sortItemsByPrice();
          } else if (selectedValue == 'Более новые') {
            sortItemsByDateCreated();
          }
           else if (selectedValue == 'Более старые') {
            sortItemsByDateCreated2();
          }
          else if (selectedValue == 'Сортировка по количеству') {
            sortItemsByCount();
          }
        }
      });
    },
  ),
),



              Padding(
                padding: const EdgeInsets.only(right: 16.0),
                child: IconButton(
                  icon: const Icon(Icons.exit_to_app),
                  color: Colors.white,
                  onPressed: () {
                    logout();
                  },
                ),
              ),
            ],
            bottom: const TabBar(
              tabs: <Widget>[
                Tab(
                  icon: Icon(Icons.shop,color: Colors.white,),
                  
                ),
                Tab(
                  icon: Icon(Icons.place,color: Colors.white,),
                ),
                Tab(
                    icon: Icon(Icons.reorder,color: Colors.white,)
                ),
                Tab(
                  icon: Icon(Icons.person_2,color: Colors.white,),
                ),
              ],
            ),
          ),
          body: TabBarView(
            children: <Widget>[
//Страница с товарами=======================================================================================================================================
Align(
  child: Container(
    child: GridView.builder(
      itemCount: _items.length,
      gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 2, // Указываем количество столбцов
        crossAxisSpacing: 5, // Расстояние между столбцами
        mainAxisSpacing: 5, // Расстояние между строками
        childAspectRatio: 1 / 2, // Измененное отношение ширины к высоте
      ),
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
          child: Padding(
            padding: EdgeInsets.all(10), // Добавляем отступы для всего содержимого Card
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start, // Выравниваем по левому краю
              mainAxisAlignment: MainAxisAlignment.spaceBetween, // Распределяем пространство между элементами
              children: [
                Container(
                  width: 200, // Задаем ширину контейнера
                  height: 200, // Задаем высоту контейнера
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(15), // Закругляем углы
                    image: DecorationImage(
                      image: NetworkImage(itemImage), // Загружаем изображение из сети
                      fit: BoxFit.cover, // Указываем, как изображение должно заполнять контейнер
                    ),
                  ),
                ),
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      "Название: ${item.name!= null && item.name!.length > 8? item.name!.substring(0, 6) + '...' : item.name}",
                    ),
                    Text("Описание: ${item.description!= null && item.description!.length > 8? item.description!.substring(0, 6) + '...' : item.description}"),
                    Text("Цена: ${item.cost}"),

                  ],
                ),
            Center(
          child: ElevatedButton(
            onPressed: () {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => ItemDetailsPage(item: item, orderItems: _orderItems),
                ),
              ).then((value) {
                if (value != null) {
                  setState(() {
                    _orderItems += value;
                  });
                }
                setState(() {
                  _isFormActive = false; // Set the form to inactive when the route is popped
                });
              });
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.purple, // Заливка светло-фиолетового цвета
              shape: RoundedRectangleBorder( // Закругление углов
                borderRadius: BorderRadius.circular(10), // Радиус закругления
              ),
            ),
            child: Row(
              mainAxisSize: MainAxisSize.min, // Минимальная ширина для Row
              children: [
                Icon( // Иконка корзины
                  Icons.shopping_cart,
                  color: Colors.white, // Белый цвет иконки
                ),
                SizedBox(width: 3), // Отступ между иконкой и текстом
                Text(
                  'Подробнее',
                  style: TextStyle(color: Colors.white), // Белый цвет текста
                ),
              ],
            ),
          ),
        ),

              ],
            ),
          ),
        );
      },
    ),
  ),
),



//Страница подтверждения товара=============================================================================================================================
              Center(
                child: Column(
                  children: [
                    DropdownButton<Point>(
                        value: _selectedPoint,
                        hint: const Text("Выберите пункт выдачи"),
                        isExpanded: true,
                        items: _pointsList.map((Point points) {
                          return DropdownMenuItem<Point>(
                            value: points,
                            child: Text(points.adress!),
                          );
                        }).toList(),
                        onChanged: (Point? value) {
                          setState(() {
                            _selectedPoint = value!;
                          });
                        }),
            Expanded(
  child: ListView.builder(
    shrinkWrap: true,
    physics: NeverScrollableScrollPhysics(),
    itemCount: _orderItems.length,
    itemBuilder: (context, index) {
      // Получаем ширину экрана
      double screenWidth = MediaQuery.of(context).size.width;

      // Вычисляем ширину контейнера, делая его меньше ширины экрана
      double containerWidth = screenWidth * 0.95; // Например, 95% ширины экрана

      return Container(
        width: 200, // Устанавливаем ширину контейнера
        decoration: BoxDecoration(
          color: Colors.grey.withOpacity(0.2), // Изменяем цвет и прозрачность фона
          borderRadius: BorderRadius.circular(15), // Закругление углов
          border: Border.all(
            color: Colors.purple.withOpacity(0.2), // Цвет границы
            width: 1, // Ширина границы
          ),
        ),
        child: ListTile(
          title: Text("Название: ${_orderItems[index].name!}"),
          subtitle: Text("Количество: ${_orderItems[index].orderCount.toString()}"),
          
        ),
      );
    },
  ),
),




                  Container(
  margin: const EdgeInsets.only(bottom: 48),
  child: TextButton(
    style: ButtonStyle(
      backgroundColor: MaterialStateProperty.all(Colors.purple), // Перенесенный фон
      shape: MaterialStateProperty.all<RoundedRectangleBorder>(
        RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(10), // Перенесенное закругление углов
        ),
      ),
      foregroundColor: MaterialStateProperty.all(Colors.white), // Перенесенный цвет текста
    ),
    onPressed: () async {
      if(_selectedPoint == null){
        showAlert(context, "Ошибка оформления", "Выберите пункт выдачи!");
      }
      else if(_orderItems.isEmpty){
        showAlert(context, "Ошибка оформления", "Выберите продукт!");
      }
      else{
        print(_selectedPoint.toString());
        int? pointId = _selectedPoint?.id!;
        int createdOrderID = await DbHandler.createOrder(pointId!, User.currentUser.id!);

        for(var item in _orderItems){
          await DbHandler.addOrderDetail(item.id!, createdOrderID, item.orderCount);
          print("${item.name} добавлено, номер = ${item.orderCount}");
        }


        
        setState(() {
          _orderItems.clear();
          getItems();
          getUserOrders();
        });
        showAlert(context, "Заказ", "Заказ оформлен");
      }
    },
    child:Container(
  width: 200, // Устанавливаем ширину контейнера равной 250 пикселям
  child: Center( // Оборачиваем Text в Center для выравнивания по центру
    child: Text(
      'Оформить заказ',
      style: TextStyle(color: Colors.white),
      textAlign: TextAlign.center, // Используем TextAlign.center для выравнивания текста
    ),
  ),
)



  ),
)

                  ],
                ),
              ),
//Страница заказов========
              Column(
                  children: [
                    Expanded(
                      child: ListView.builder(
                        itemCount: _orders.length,
                        itemBuilder: (context, index) {
                          Order order = _orders[index];
                          return ListTile(
                              contentPadding: const EdgeInsets.all(16),
                              onTap: (){
                                print(order);
                                DbHandler.fetchOrderDetails(order.id!).then((orderDetails){
                                  print(orderDetails);
                                  int orderTotalPrice = 0;
                                  for(var detail in orderDetails){
                                    orderTotalPrice += detail.total!;
                                  }
                                  SqliteHandler.deleteDetailsById(order.id!).then((result){
                                    for(var detail in orderDetails){
                                      SqliteHandler.insertOrderDetails(detail.itemId!, detail.count!, order.id!);
                                    }
                                  });
                                  showDialog(
                                      context: context,
                                      builder: (BuildContext context) {
                                        return Dialog(
                                          shape: RoundedRectangleBorder(
                                              borderRadius:
                                              BorderRadius.circular(20.0)), //this right here
                                          child: Container(
                                            height: MediaQuery.of(context).size.height,
                                            width: MediaQuery.of(context).size.width,
                                            child: Padding(
                                              padding: const EdgeInsets.all(12.0),
                                              child: Column(
                                                mainAxisAlignment: MainAxisAlignment.center,
                                                crossAxisAlignment: CrossAxisAlignment.center,
                                                children: [
                                                  Text('Номер заказа: ${order.id}'),
                                                  Text('Пункт выдачи: ${order.poiAdress}'),
                                                  Text('Статус: ${order.status}'),
                                                  const Divider(thickness: 1,),
                                                  const SizedBox(height: 8,),
                                                  Expanded(
                                                    child: ListView.builder(
                                                      itemCount: orderDetails.length,
                                                      itemBuilder: (BuildContext context, int index) {
                                                        final order = orderDetails[index];
                                                        return ListTile(
                                                          contentPadding: const EdgeInsets.all(14),
                                                          title: Text('${order.name!}'),
                                                          subtitle: Column(
                                                            crossAxisAlignment: CrossAxisAlignment.start,
                                                            children: [
                                                              Text('Цена: ${order.cost} BYN'),
                                                              Text('Количество: ${order.count}'),
                                                            ],
                                                          ),
                                                          trailing: Text('${order.total} BYN'),
                                                        );
                                                      },
                                                    ),
                                                  ),
                                                  Container(
                                                    margin: const EdgeInsets.all(32),
                                                    child: Text(
                                                      "Итого: ${orderTotalPrice} BYN",
                                                      style: const TextStyle(
                                                          fontSize: 26
                                                      ),
                                                    ),
                                                  ),
                                                  TextButton(
                                                    
                                                    style: ButtonStyle(backgroundColor: MaterialStateProperty.all(Colors.grey.withOpacity(0.0)),
                                                        foregroundColor: MaterialStateProperty.all(Colors.black)),
                                                    onPressed: (){
                                                      Navigator.pop(context);
                                                    },
                                                    child: const Text('Выйти', style: TextStyle(color: Color.fromARGB(255, 0, 0, 0), fontSize: 18)),
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
                                Text('Номер заказа: ${order.id!}'),
                                Text('Дата формления: ${DateFormat('dd.MM.yyyy').format(order.createdAt!)}'),
                                Text('Пункт выдачи: ${order.poiName!} – ${order.poiAdress!}'),
                                Text('Статус: ${order.status!}'),
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
                  ]
              ),
                UserProfilePage(user: User.currentUser),
            ],
            
          ),
        ),
      ),
    );
  }

  void showAlert(BuildContext context, String title, String message) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text(title),
          content: Text(message),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.of(context).pop();
              },
              child: const Text('OK'),
            ),
          ],
        );
      },
    );
  }
}

