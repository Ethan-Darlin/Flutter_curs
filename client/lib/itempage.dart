import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:intl/intl.dart';
import 'package:untitled/utils/DbHandler.dart';
import 'package:untitled/utils/SqliteHandler.dart';
import 'main.dart';
import 'models/User.dart';
import 'models/items.dart';
import 'models/orders.dart';
import 'models/points.dart';
import 'models/coments.dart';
import 'package:logger/logger.dart';

class ItemDetailsPage extends StatefulWidget {
  final Item item;
  final List<Item> orderItems;
  ItemDetailsPage({required this.item, required this.orderItems});

  @override
  _ItemDetailsPageState createState() => _ItemDetailsPageState();
}

class _ItemDetailsPageState extends State<ItemDetailsPage> {
  final TextEditingController _commentController = TextEditingController();
  List<Comment> _comments = [];
  final logger = Logger();
  final List<Item> _orderItems = [];

  Comment? _editingComment;

  @override
  void initState() {
    super.initState();
    loadComments();
  }

  void showEditCommentDialog(Comment comment) {
    _editingComment = comment;
    TextEditingController _commentController = TextEditingController(text: _editingComment?.description?? '');
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text('Редактировать комментарий'),
          content: TextField(
            controller: _commentController,
            onSubmitted: (value) async {
              _editingComment?.description = value;
              await updateCommentInDB(_editingComment!);
              Navigator.pop(context);
            },
          ),
          actions: [
            TextButton(
              child: Text('Отмена'),
              onPressed: () {
                Navigator.pop(context);
              },
            ),
            TextButton(
              child: Text('Сохранить'),
              onPressed: () async {
                _editingComment?.description = _commentController.text;
                await updateCommentInDB(_editingComment!);
                Navigator.pop(context);
              },
            ),
          ],
        );
      },
    );
  }

  void loadComments() async {
    DbHandler dbHandler = DbHandler();
    List<Comment> comments = await dbHandler.fetchCommentsForItem(widget.item.id!);
    setState(() {
      _comments = comments;
    });
  }

  Future<void> updateCommentInDB(Comment comment) async {
    await DbHandler().updateComment(comment.id_comment!, comment.description!);

    int index = _comments.indexWhere((c) => c.id_comment == comment.id_comment);
    if (index!= -1) {
      setState(() {
        _comments[index] = comment;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(  
      resizeToAvoidBottomInset: false,
      appBar: AppBar(
        title: Text(widget.item.name!,style: TextStyle(color: Colors.white),),
        backgroundColor: const Color.fromARGB(255, 81, 20, 114),
         leading: IconButton(
        icon: Icon(Icons.arrow_back, color: Colors.white), // Используйте иконку "Назад" с белым цветом
        onPressed: () {
          Navigator.pop(context);
        },
      ),
      ),
      body: Padding(
        padding: const EdgeInsets.all(8.0),
        child: Column(
          children: <Widget>[
            Row(
            
              crossAxisAlignment: CrossAxisAlignment.start, 
              children: [
                // Изображение слева с закругленными углами
                Container(
                  width: 150,
                  height: 150,
                  decoration: BoxDecoration(
                    image: DecorationImage(
                      fit: BoxFit.cover,
                      image: NetworkImage(widget.item.image!),
                    ),
                    borderRadius: BorderRadius.circular(10),
                  ),
                ),
                // Текст справа
                Expanded(
                  child: Padding(
                    padding: const EdgeInsets.only(left: 8.0),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: <Widget>[
                        Text("${widget.item.name}", style: TextStyle(fontSize: 24)),
                        SizedBox(height: 10),
                        Text("Рейтинг: ${widget.item.raiting} баллов", style: TextStyle(fontSize: 20)),
                        SizedBox(height: 10),
                        Text("Цена: ${widget.item.cost} BYN", style: TextStyle(fontSize: 20)),
                        
                      ],
                      
                    ),
                    
                  ),
                  
                ),
                
              ],
            ),
            SizedBox(height: 10),
           Align(
  alignment: Alignment.topLeft,
  child: Text("Описание: ${widget.item.description}",style: TextStyle(fontSize: 16,fontWeight: FontWeight.normal)),
),
SizedBox(height: 10),
          // Добавляем код для выбора количества
          const Text("Выберите количество:",style: TextStyle(fontSize: 20),),
Row(
  mainAxisAlignment: MainAxisAlignment.center,
  children: [
    TextButton(
      style: ButtonStyle(
        backgroundColor: MaterialStateProperty.all(Colors.grey.withOpacity(0.0)),
        foregroundColor: MaterialStateProperty.all(Colors.black),
      ),
      onPressed: () {
        setState(() {
          if (widget.item.orderCount > 0 && widget.item.orderCount <= widget.item.count!) {
            widget.item.orderCount--;
          }
        });
      },
      child: Stack(
        alignment: Alignment.center,
        children: [
          Container(
            width: 30, // Размер круга
            height: 30, // Размер круга
            decoration: BoxDecoration(
              shape: BoxShape.circle, // Форма круга
              color: Colors.purple.withOpacity(0.8), // Прозрачный фон
            ),
          ),
          const Text('—', style: TextStyle(color: Colors.white, fontSize: 18)),
        ],
      ),
    ),
    Container(
      padding: const EdgeInsets.only(left: 16, right: 16),
      child: Text(
        style: TextStyle(color: Colors.purple,fontSize: 18),
        widget.item.orderCount.toString(),
      ),
    ),
    TextButton(
      style: ButtonStyle(
        backgroundColor: MaterialStateProperty.all(Colors.grey.withOpacity(0.0)),
        foregroundColor: MaterialStateProperty.all(Colors.black),
      ),
      onPressed: () {
        setState(() {
          if (widget.item.orderCount >= 0 && widget.item.orderCount < widget.item.count!) {
            widget.item.orderCount++;
          }
        });
      },
      child: Stack(
        alignment: Alignment.center,
        children: [
          Container(
            width: 30, // Размер круга
            height: 30, // Размер круга
            decoration: BoxDecoration(
              shape: BoxShape.circle, // Форма круга
              color: Colors.purple.withOpacity(0.8), // Прозрачный фон
            ),
          ),
          const Text('+', style: TextStyle(color: Colors.white, fontSize: 18)),
        ],
      ),
    ),
  ],
),

          // Добавляем кнопку "В корзину"
         Center(
  child: ElevatedButton(
    onPressed: () {
      setState(() {
        if(widget.item.orderCount > 0){
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: const Text('Добавлено в корзину'),
              action: SnackBarAction(
                label: 'Ok',
                onPressed: () {
                  // Код для выполнения.
                },
              ),
            ),
          );
          _orderItems.add(widget.item); // Добавление товара в корзину
          Navigator.pop(context, _orderItems);
        }
        else{
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: const Text('Выберите хотя бы 1 предмет'),
              action: SnackBarAction(
                label: 'Ok',
                onPressed: () {
                  Navigator.pop(context, _orderItems);
                },
              ),
            ),
          );
        }
      });
    },
    style: ElevatedButton.styleFrom(
    backgroundColor: Colors.purple, // Заливка кнопки
    shape: RoundedRectangleBorder(
      borderRadius: BorderRadius.circular(10), // Радиус закругления
    ),
    padding: EdgeInsets.symmetric(horizontal: 28, vertical: 8), // Увеличенное горизонтальное поле вокруг текста
  ),
  child: const Text('В корзину', style: TextStyle(color: Colors.white, fontSize: 18)),
),
),
SizedBox(height: 30),
          // Поле для ввода нового комментария
          TextField(
  controller: _commentController,
  decoration: InputDecoration(
    labelText: 'Добавить комментарий',
    suffixIcon: IconButton(
      icon: Icon(Icons.send),
      onPressed: () async {
        // Проверяем, не пустой ли комментарий
        if (_commentController.text.trim().isEmpty) {
          // Если комментарий пустой, показываем SnackBar с предупреждением
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: const Text('Комментарий не может быть пустым.'),
              action: SnackBarAction(
                label: 'OK',
                onPressed: () {
                  Navigator.pop(context); // Закрыть SnackBar
                },
              ),
            ),
          );
        } else {
          // Добавьте новый комментарий
          await addComment();
          // Очистите поле ввода
          _commentController.clear();
        }
      },
    ),
  ),
),
          // Отображение всех комментариев
        Expanded(
  child: ListView.builder(
  itemCount: _comments.length,
  itemBuilder: (context, index) {
    Comment comment = _comments[index];
    bool isAuthor = comment.id_user == User.currentUser.id; // Проверка авторства

    return ListTile(
      title: Text(comment.description!),
      trailing: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          if (isAuthor) // Отображение иконок только для автора
            IconButton(
              icon: Icon(Icons.edit),
              onPressed: () {
                _editingComment = _comments[index];
                if (_editingComment!= null) {
                  showEditCommentDialog(_editingComment!);
                } else {
                  print("Ошибка: _editingComment равен null");
                }
              },
            ),
          if (isAuthor) // Отображение иконок только для автора
            IconButton(
              icon: Icon(Icons.delete),
              onPressed: () async {
                if (comment.id_user == User.currentUser.id) {
                  await DbHandler().deleteComment(comment.id_comment!);
                  setState(() {
                    _comments.removeAt(index);
                  });
                } else {
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(
                      content: Text('Вы не можете удалить этот комментарий'),
                      action: SnackBarAction(
                        label: 'Ok',
                        onPressed: () {},
                      ),
                    ),
                  );
                }
              },
            ),
        ],
      ),
    );
  },
),

),

        ],
      ),
    ),
  );
}


  Future<void> addComment() async {
    // Предполагается, что у вас есть метод для добавления комментария
    DbHandler dbHandler = DbHandler();
    Comment newComment = await dbHandler.addComment(widget.item.id!, User.currentUser.id!, _commentController.text);
    setState(() {
      _comments.add(newComment);
    });
  }
}
