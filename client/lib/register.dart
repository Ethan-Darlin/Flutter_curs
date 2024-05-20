import 'dart:ui';

import 'package:flutter/material.dart';
import 'package:untitled/utils/DbHandler.dart';
import 'main.dart';


class Register extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'Регистрация',
      home: RegistrationPage(),
    );
  }
}

class RegistrationPage extends StatefulWidget {
  
  @override
  _RegistrationPageState createState() => _RegistrationPageState();
  
}

class _RegistrationPageState extends State<RegistrationPage> {
  final TextEditingController _nameController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();
  final TextEditingController _phoneNumberController = TextEditingController();
  final TextEditingController _loginController = TextEditingController();
  final TextEditingController _emailController = TextEditingController();
  String? _nameError;
  String? _passwordError;
  String? _phoneError;
  String? _emailError;

  bool validateForm() {
    bool isValid = true;
    final name = _nameController.text;
    final password = _passwordController.text;
    final phoneNumber = _phoneNumberController.text;
    final email = _emailController.text;

   RegExp emailPattern = RegExp(r'[\w.-]+\@[\w.-]+\.\w+');

    RegExp phonePattern = RegExp(r'^\+[0-9]{1,}$');

    if (name.isEmpty) {
      _nameError = 'Пожалуйста, введите имя';
      isValid = false;
    } else {
      _nameError = null;
    }

    if (password.isEmpty) {
      _passwordError = 'Пожалуйста, введите пароль';
      isValid = false;
    } else {
      _passwordError = null;
    }

    if (phoneNumber.isEmpty || !phonePattern.hasMatch(phoneNumber)) {
      _phoneError = 'Пожалуйста, введите правильный номер телефона';
      isValid = false;
    } else {
      _phoneError = null;
    }

    if (email.isEmpty || !emailPattern.hasMatch(email)) {
      _emailError = 'Пожалуйста, введите правильный email';
      isValid = false;
    } else {
      _emailError = null;
    }

    setState(() {});
    return isValid;
  }
@override
Widget build(BuildContext context) {
  Size size = MediaQuery.of(context).size;
  return Scaffold(
    body: Stack(
      children: [
        Positioned(
          top: 16.0,
          left: 16.0,
          child: IconButton(
            icon: Icon(Icons.arrow_back, color: Colors.purple),
            onPressed: () {
              Navigator.push(context, MaterialPageRoute(builder: (context) => LoginPage()));
            },
          ),
        ),
        Container(
          decoration: const BoxDecoration(
            image: DecorationImage(
              image: AssetImage("assets/images/background.jpg"),
              fit: BoxFit.cover,
              colorFilter: ColorFilter.mode(Colors.black54, BlendMode.darken),
            ),
          ),
          padding: const EdgeInsets.all(16.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
            SizedBox(height: size.width * 0.1,
            ),
            Stack(
              children: [
                Center(
                  child: ClipOval(
                    child: BackdropFilter(
                      filter: ImageFilter.blur(sigmaX: 6, sigmaY: 6),
                      child: CircleAvatar(
                        radius: size.width * 0.1,
                        backgroundColor: Colors.grey[400]?.withOpacity(0.5),
                        child: Icon(
                          Icons.person_outline,
                          color: Colors.white,
                          size: size.width * 0.13,
                        ),
                      ),
                    ),
                  ),
                ),
              ],
            ),

            Padding(
                padding: const EdgeInsets.only(top: 50),
                child: Container(
                  height: 50,
                  width: size.width * 0.9,
                  decoration: BoxDecoration(color: Colors.grey[200]?.withOpacity(0.2),
                  borderRadius: BorderRadius.circular(16),
                  ),
                 child: TextField(
                   style: const TextStyle(color: Colors.white, fontSize: 16),
                  controller: _nameController,
                  decoration: const InputDecoration(
                    labelStyle: TextStyle(color: Colors.white),
                    labelText: "Имя",
                  ),
                ),
                ),
              ),
               if (_nameError != null)
            Padding(
              padding: const EdgeInsets.only(top: 8.0),
              child: Text(
                _nameError!,
                style: const TextStyle(color: Colors.red),
              ),
            ),
            Padding(
              padding: const EdgeInsets.only(top: 15),
              child: Container(
                height: 50,
                width: size.width * 0.9,
                decoration: BoxDecoration(color: Colors.grey[200]?.withOpacity(0.2),
                  borderRadius: BorderRadius.circular(16),
                ),
                child: TextField(
                  style: const TextStyle(color: Colors.white, fontSize: 16),
                  controller: _passwordController,
                  decoration: const InputDecoration(
                    labelStyle: TextStyle(color: Colors.white),
                    labelText: "Пароль",
                  ),
                ),
              ),
            ),
             if (_passwordError != null)
            Padding(
              padding: const EdgeInsets.only(top: 8.0),
              child: Text(
                _passwordError!,
                style: const TextStyle(color: Colors.red),
              ),
            ),
            Padding(
              padding: const EdgeInsets.only(top: 15),
              child: Container(
                height: 50,
                width: size.width * 0.9,
                decoration: BoxDecoration(color: Colors.grey[200]?.withOpacity(0.2),
                  borderRadius: BorderRadius.circular(16),
                ),
                child: TextField(
                  style: const TextStyle(color: Colors.white, fontSize: 16),
                  controller: _phoneNumberController,
                  decoration: const InputDecoration(
                    labelStyle: TextStyle(color: Colors.white),
                    labelText: "Телефон",
                  ),
                ),
              ),
            ),
            
          if (_phoneError != null)
            Padding(
              padding: const EdgeInsets.only(top: 8.0),
              child: Text(
                _phoneError!,
                style: const TextStyle(color: Colors.red),
              ),
            ),
            Padding(
              padding: const EdgeInsets.only(top: 15),
              child: Container(
                height: 50,
                width: size.width * 0.9,
                decoration: BoxDecoration(color: Colors.grey[200]?.withOpacity(0.2),
                  borderRadius: BorderRadius.circular(16),
                ),
                child: TextField(
                  style: const TextStyle(color: Colors.white, fontSize: 16),
                  controller: _emailController,
                  decoration: const InputDecoration(
                    labelStyle: TextStyle(color: Colors.white),
                    labelText: "Электронная почта",
                  ),
                ),
              ),
            ),
          if (_emailError != null)
            Padding(
              padding: const EdgeInsets.only(top: 8.0),
              child: Text(
                _emailError!,
                style: const TextStyle(color: Colors.red),
              ),
            ),
            SizedBox(height: 16.0),
            Align(
              alignment: Alignment.center,
              child: TextButton(
                style: ButtonStyle(backgroundColor: MaterialStateProperty.all(Colors.grey.withOpacity(0.0)),
                    foregroundColor: MaterialStateProperty.all(Colors.black)),
                onPressed: () async {
  if (validateForm()) {
    DbHandler user = DbHandler();
    bool exists = await user.checkIfUserExists(_emailController.text.trim(), _phoneNumberController.text.trim());

    if (!exists) {
      await user.createUser(_nameController.text, _passwordController.text, _phoneNumberController.text, _emailController.text);
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(builder: (context) => MyApp()),
      );
    } else {
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Пользователь с таким логином или номером телефона уже существует')));
    }
  } else {
    ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Заполните все поля корректно')));
  }
},

                child: const Text('Зарегистрироваться', style: TextStyle(color: Colors.white, fontSize: 22)),
              ),
            ),
          ],
        ),
      ),
      ],
    )
    );
  }
}