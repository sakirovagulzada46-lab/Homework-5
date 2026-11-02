import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'Список задач',
      theme: ThemeData(primarySwatch: Colors.blue),
      home: const TaskListScreen(),
    );
  }
}

// ==================== ЭКРАН 1: Список задач ====================
class TaskListScreen extends StatefulWidget {
  const TaskListScreen({super.key});

  @override
  State<TaskListScreen> createState() => _TaskListScreenState();
}

class _TaskListScreenState extends State<TaskListScreen> {
  // 3 захардкоженные задачи по заданию
  List<String> tasks = [
    'Купить продукты',
    'Сделать домашку по Flutter',
    'Помыть машину',
  ];

  // Метод добавления новой задачи через AlertDialog
  void _showAddTaskDialog() {
    TextEditingController addController = TextEditingController();

    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: const Text('Новая задача'),
          content: TextField(
            controller: addController,
            decoration: const InputDecoration(hintText: 'Введите название'),
          ),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.pop(context);
              },
              child: const Text('Отмена'),
            ),
            TextButton(
              onPressed: () {
                if (addController.text.isNotEmpty) {
                  setState(() {
                    tasks.add(addController.text);
                  });
                }
                Navigator.pop(context);
              },
              child: const Text('Добавить'),
            ),
          ],
        );
      },
    );
  }

  // Метод открытия второго экрана для редактирования через .then()
  void _editTask(int index) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => EditTaskScreen(initialTitle: tasks[index]),
      ),
    ).then((result) {
      if (result != null && result is String && result.isNotEmpty) {
        setState(() {
          tasks[index] = result;
        });
      }
    });
  }

  // Бонус: подтверждение удаления через CupertinoAlertDialog
  void _showDeleteConfirmation(int index) {
    showCupertinoDialog(
      context: context,
      builder: (context) {
        return CupertinoAlertDialog(
          title: const Text('Удаление'),
          content: const Text('Вы уверены?'),
          actions: [
            CupertinoDialogAction(
              onPressed: () {
                Navigator.pop(context);
              },
              child: const Text('Отмена'),
            ),
            CupertinoDialogAction(
              isDestructiveAction: true,
              onPressed: () {
                setState(() {
                  tasks.removeAt(index);
                });
                Navigator.pop(context);
              },
              child: const Text('Удалить'),
            ),
          ],
        );
      },
    );
  }

  // Метод показа BottomSheet при долгом нажатии
  void _showBottomSheet(int index) {
    showModalBottomSheet(
      context: context,
      builder: (context) {
        return SafeArea(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              ListTile(
                leading: const Icon(Icons.edit),
                title: const Text('Редактировать'),
                onTap: () {
                  Navigator.pop(context); // Сначала закрываем шторку
                  _editTask(index);
                },
              ),
              ListTile(
                leading: const Icon(Icons.delete, color: Colors.red),
                title: const Text('Удалить', style: TextStyle(color: Colors.red)),
                onTap: () {
                  Navigator.pop(context); // Сначала закрываем шторку
                  _showDeleteConfirmation(index); // Затем показываем диалог
                },
              ),
            ],
          ),
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Мой список задач'),
      ),
      body: ListView.builder(
        itemCount: tasks.length,
        itemBuilder: (context, index) {
          return GestureDetector(
            onLongPress: () => _showBottomSheet(index), // Долгий тап
            child: ListTile(
              title: Text(tasks[index]),
              onTap: () => _editTask(index), // Обычный тап для перехода
              trailing: IconButton(
                icon: const Icon(Icons.delete, color: Colors.grey),
                onPressed: () {
                  _showDeleteConfirmation(index);
                },
              ),
            ),
          );
        },
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: _showAddTaskDialog,
        child: const Icon(Icons.add),
      ),
    );
  }
}

// ==================== ЭКРАН 2: Редактирование задачи ====================
class EditTaskScreen extends StatefulWidget {
  final String initialTitle;

  const EditTaskScreen({super.key, required this.initialTitle});

  @override
  State<EditTaskScreen> createState() => _EditTaskScreenState();
}

class _EditTaskScreenState extends State<EditTaskScreen> {
  late TextEditingController _controller;

  @override
  void initState() {
    super.initState();
    _controller = TextEditingController(text: widget.initialTitle);
  }

  @override
  void dispose() {
    _controller.dispose(); // Очистка контроллера по заданию
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Редактировать задачу'),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
            TextField(
              controller: _controller,
              decoration: const InputDecoration(
                labelText: 'Название задачи',
                border: OutlineInputBorder(),
              ),
            ),
            const SizedBox(height: 20),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: [
                ElevatedButton(
                  onPressed: () {
                    Navigator.pop(context, null); // Возвращаем null при отмене
                  },
                  style: ElevatedButton.styleFrom(backgroundColor: Colors.grey),
                  child: const Text('Отмена'),
                ),
                ElevatedButton(
                  onPressed: () {
                    Navigator.pop(context, _controller.text); // Возвращаем новый текст
                  },
                  child: const Text('Сохранить'),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}