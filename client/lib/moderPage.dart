import 'package:flutter/material.dart';
import 'package:file_picker/file_picker.dart';
import 'package:untitled/models/User.dart';
import 'package:untitled/utils/DbHandler.dart';
import 'package:untitled/utils/SqliteHandler.dart';
import 'main.dart';
import 'models/items.dart';
import 'models/orders.dart';
import 'models/points.dart';
import 'models/coments.dart'; // Исправлен импорт модели
import 'package:flutter/material.dart';
import 'package:untitled/models/User.dart';
import 'package:untitled/utils/DbHandler.dart';


class UsersPage extends StatefulWidget {
  @override
  _UsersPageState createState() => _UsersPageState();
}

class _UsersPageState extends State<UsersPage> {
  late Future<List<User>> futureUsers;

  @override
  void initState() {
    super.initState();
    futureUsers = DbHandler.fetchUsers();
  }

  void refreshUsers() {
    setState(() {
      futureUsers = DbHandler.fetchUsers();
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Все комментарии', style: TextStyle(color: Colors.white)),
        backgroundColor: Color.fromARGB(255, 81, 20, 114),
        iconTheme: IconThemeData(color: Colors.white), // Изменение цвета иконок
          actions: <Widget>[
          IconButton(
            icon: Icon(Icons.refresh),
            onPressed: refreshUsers, // При нажатии вызывается refreshComments
          ),
        ],
      ),
      body: FutureBuilder<List<User>>(
        future: futureUsers,
        builder: (context, snapshot) {
          if (snapshot.hasData) {
            return ListView.builder(
              itemCount: snapshot.data!.length,
              itemBuilder: (context, index) {
                var user = snapshot.data![index];
                return ListTile(
                  title: Text('Name: ${user.name?? ''}'),
                  subtitle: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text('Login: ${user.login?? ''}'),
                      Text('Role: ${user.role}'),
                    ],
                  ),
                  leading: CircleAvatar(
                    backgroundImage: NetworkImage(user.user_image?? ''),
                  ),
                  trailing: user.role == 'customer'
                     ? Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Text('Up to seller'),
                            SizedBox(width: 2),
                            IconButton(
                              icon: Icon(Icons.sell),
                              onPressed: () async {
                                try {
                                  await DbHandler.changeUserRole(user.id.toString(), 'seller');
                                } catch (e) {
                                  print(e);
                                }
                              },
                            ),
                          ],
                        )
                      : user.role == 'seller'
                         ? Row(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                Text('Down to customer'),
                                SizedBox(width: 2),
                                IconButton(
                                  icon: Icon(Icons.arrow_downward),
                                  onPressed: () async {
                                    try {
                                      await DbHandler.changeUserRole(user.id.toString(), 'customer');
                                    } catch (e) {
                                      print(e);
                                    }
                                  },
                                ),
                              ],
                            )
                          : null,
                );
              },
            );
          } else if (snapshot.hasError) {
            return Center(child: Text("${snapshot.error}"));
          }
          return Center(child: CircularProgressIndicator());
        },
      ),
    );
  }
}


class AllCommentsPage extends StatefulWidget {
  @override
  _AllCommentsPageState createState() => _AllCommentsPageState();
}

class _AllCommentsPageState extends State<AllCommentsPage> {
  late Future<List<Comment>> futureComments; // Использование модели Comment

  @override
  void initState() {
    super.initState();
    futureComments = DbHandler().fetchAllComments(); // Загрузка всех комментариев
  }
 void refreshComments() {
    setState(() {
      futureComments = DbHandler().fetchAllComments(); // Перезагрузка данных
    });
  }
  @override
  Widget build(BuildContext context) {
    return Scaffold(
     appBar: AppBar(
        title: Text('Все комментарии', style: TextStyle(color: Colors.white)),
        backgroundColor: Color.fromARGB(255, 81, 20, 114),
        iconTheme: IconThemeData(color: Colors.white), // Изменение цвета иконок
          actions: <Widget>[
          IconButton(
            icon: Icon(Icons.refresh),
            onPressed: refreshComments, // При нажатии вызывается refreshComments
          ),
        ],
      ),
      body: FutureBuilder<List<Comment>>(
        future: futureComments,
        builder: (context, snapshot) {
          if (snapshot.hasData) {
            return ListView.builder(
              itemCount: snapshot.data!.length,
              itemBuilder: (context, index) {
                var comment = snapshot.data![index];
                return Card(
                  margin: EdgeInsets.all(8.0),
                  child: ListTile(
                    leading: CircleAvatar(
                      backgroundColor: Colors.blueAccent,
                      child: Text('${comment.id_comment}'),
                    ),
                    title: Text('User id: ${comment.id_user?? ''}'), // Исправление для пустого значения
                    subtitle: Text('Содержание: ${comment.description?? ''}'), // Исправление для пустого значения
                    trailing: IconButton(
                      icon: Icon(Icons.delete, color: Colors.red),
                      onPressed: () async {
                        bool success = await DbHandler().deleteComment2(comment.id_comment!); // Удаление комментария
                        if (success) {
                          setState(() {
                            futureComments = DbHandler().fetchAllComments(); // Обновление списка комментариев после удаления
                          });
                        }
                      },
                    ),
                  ),
                );
              },
            );
          } else if (snapshot.hasError) {
            return Center(child: Text("${snapshot.error}")); // Отображение сообщения об ошибке
          }
          // По умолчанию показываем загрузочный индикатор
          return Center(child: CircularProgressIndicator());
        },
      ),
      drawer: Drawer(
        child: Column(
          children: [
            UserAccountsDrawerHeader(
              accountName: Text('Модератор'),
              accountEmail: Text('${User.currentUser.login!}'),
              currentAccountPicture: CircleAvatar(
                backgroundColor: Colors.white,
                child: Text('М'),
              ),
            ),
             ListTile(
              title: Text('Модерировать коментарии'),
              onTap: () {
                Navigator.push(context, MaterialPageRoute(builder: (context) => AllCommentsPage()));
              },
            ),
            ListTile(
  title: Text('Список всех user'),
  onTap: () {
    Navigator.push(context, MaterialPageRoute(builder: (context) => UsersPage()));
  },
),
            ListTile(
              title: Text('Выход'),
              onTap: () {
                Navigator.push(context, MaterialPageRoute(builder: (context) => LoginPage()));
              },
            ),
          ],
        ),
      ),
    );
  }
}
