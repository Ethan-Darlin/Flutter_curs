import 'package:flutter/material.dart';
import 'package:untitled/register.dart';
import 'package:untitled/utils/DbHandler.dart';
import 'package:untitled/utils/SqliteHandler.dart';
import 'adminPage.dart';
import 'userPage.dart';
import 'models/User.dart';
import 'dart:ui';
import 'moderPage.dart';

/// Flutter code sample for [TextField].

void main() {
  runApp(const MyApp());
  SqliteHandler.getInstance();
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    final ThemeData theme = ThemeData();
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'Clothing-Store',
      theme: ThemeData(
        primarySwatch: Colors.blue,
      ),
      home: const LoginPage(),
    );
  }
}

class LoginPage extends StatefulWidget {
  const LoginPage({super.key});

  @override
  // ignore: library_private_types_in_public_api
  _LoginPageState createState() => _LoginPageState();
}

class _LoginPageState extends State<LoginPage> {
  final _formKey = GlobalKey<FormState>();
  final _usernameController = TextEditingController();
  final _passwordController = TextEditingController();
  String username = "";
  String password = "";
  void initState() {
    super.initState();
    _usernameController.addListener(updateTextValue);
    _passwordController.addListener(updateTextValue);
  }

  void updateTextValue() {
    setState(() {
      username = _usernameController.text;
      password = _passwordController.text;
    });
  }

  @override
  Widget build(BuildContext context) {
  Size size = MediaQuery.of(context).size;
    return Scaffold(
      body: Container(
        decoration: const BoxDecoration(
          image: DecorationImage(
            image: AssetImage("assets/images/background.jpg"),
            fit: BoxFit.cover, colorFilter: ColorFilter.mode
            ( Colors.black54, BlendMode.darken),
          ),
        ),
        padding: const EdgeInsets.all(16.0),
        child: Form(
          key: _formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.center,
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const Flexible(
                child: Center(
                  child: Text(
                    'Clothing-Store',
                    style: TextStyle(color: Colors.white,
                      fontSize: 38,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
              ),
              Padding(
                padding: const EdgeInsets.symmetric(vertical: 10.0),
                child: Container(
                  height: 50,
                  width: size.width * 0.9,
                  decoration: BoxDecoration(color: Colors.grey[500]?.withOpacity(0.2),
                  borderRadius: BorderRadius.circular(1),
                  ),
              child: TextFormField(
                style: const TextStyle(color: Colors.white),
                controller: _usernameController,
                decoration: const InputDecoration(
                  labelStyle: TextStyle(color: Colors.white, fontSize: 18),
                  border: OutlineInputBorder(),
                  labelText: 'Электронная почта',
                ),
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Введите Вашу электронную почту';
                  }
                  return null;
                },
              ),
                ),
              ),
                Padding(
                padding: const EdgeInsets.symmetric(vertical: 10.0),
                child: Container(
                  height: 50,
                  width: size.width * 0.9,
                  decoration: BoxDecoration(color: Colors.grey[500]?.withOpacity(0.2),
                  borderRadius: BorderRadius.circular(1),
                  ),
              child: TextFormField(
                style: const TextStyle(color: Colors.white),
                controller: _passwordController,
                decoration: const InputDecoration(
                  labelStyle: TextStyle(color: Colors.white, fontSize: 18),
                  border: OutlineInputBorder(),
                  labelText: 'Пароль',
                ),
                obscureText: true,
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Введите пароль';
                  }
                  return null;
                },
              ),
                ),
              ),
              const SizedBox(height: 16.0),
              Container(
                height: 50,
                decoration: 
                BoxDecoration(borderRadius: BorderRadius.circular(16) ),
                child: TextButton(
                  onPressed: () async {
  print(username);
  print(password);
  var result = await DbHandler.login(username, password);
  if (result == null) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text('Пользователь с такими данными не найден')),
    );
  } else {
    User.currentUser = result;
    print(User.currentUser.role);
    if (User.currentUser.id!= -1) {
      if (User.currentUser.role == 'seller') {
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(builder: (context) => AdminPage()),
        );
      } else if (User.currentUser.role == 'moder') {
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(builder: (context) => AllCommentsPage()),
        );
      } else {
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(builder: (context) => MainPageOfShop()),
        );
      }
    }
  }
                  },
                  style: ButtonStyle(backgroundColor: MaterialStateProperty.all(Colors.grey.withOpacity(0.0)),
                      foregroundColor: MaterialStateProperty.all(Colors.black)),
                  child: const Text('Войти', style: TextStyle(color: Colors.white, fontSize: 20)),
                ),
              ),
              Container(
                height: 50,
                decoration: 
                BoxDecoration(borderRadius: BorderRadius.circular(16) ),
                child: TextButton(
                  style: ButtonStyle(backgroundColor: MaterialStateProperty.all(Colors.grey.withOpacity(0.0)),
                  foregroundColor: MaterialStateProperty.all(Colors.black)),
                  onPressed: () {
                    Navigator.push(context,
                        MaterialPageRoute(builder: (context) => Register()));
                  },
                  child: const Text('Зарегистрироваться', style: TextStyle(color: Colors.white, fontSize: 20)),
                ),
              ),
            ],
          ),
        ),
      ),
      );
  }
}