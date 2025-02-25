import 'package:flutter/material.dart';

class Level2Widget extends StatefulWidget {
  const Level2Widget({super.key});

  @override
  State<Level2Widget> createState() => _Level2WidgetState();
}

class _Level2WidgetState extends State<Level2Widget> with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _animation;

  @override
  void initState() {
    super.initState();

    // Инициализация контроллера анимации
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 5), // Продолжительность анимации
    );

    // Анимация движения объекта
    _animation = Tween<double>(begin: 0, end: 1).animate(_controller)
      ..addListener(() {
        setState(() {});
      })
      ..addStatusListener((status) {
        if (status == AnimationStatus.completed) {
          _controller.reset(); // Сброс анимации
          _controller.forward(); // Запуск заново
        }
      });

    _controller.forward(); // Запуск анимации
  }

  @override
  void dispose() {
    _controller.dispose(); // Освобождение ресурсов
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final screenWidth = MediaQuery.of(context).size.width;

    return Stack(
      children: [
        Positioned(
          left: _animation.value * screenWidth, // Используем анимацию для позиции
          top: 200,
          child: GestureDetector(
            onTap: () {
              showDialog(
                context: context,
                builder: (context) => AlertDialog(
                  title: const Text('Успех!'),
                  content: const Text('Вы поймали объект!'),
                  actions: [
                    TextButton(
                      onPressed: () => Navigator.pop(context),
                      child: const Text('OK'),
                    ),
                  ],
                ),
              );
            },
            child: Container(
              width: 50,
              height: 50,
              color: Colors.blue,
            ),
          ),
        ),
      ],
    );
  }
}