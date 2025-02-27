import 'dart:math';
import 'package:flutter/material.dart';

class Level1Widget extends StatefulWidget {
  const Level1Widget({super.key});

  @override
  State<Level1Widget> createState() => _Level1WidgetState();
}

class _Level1WidgetState extends State<Level1Widget> {
  bool _isWaiting = true;
  late DateTime _startTime;
  bool _isDisposed = false; // Флаг для проверки состояния виджета

  void _startTest() {
    setState(() {
      _isWaiting = true;
    });

    Future.delayed(Duration(seconds: Random().nextInt(5) + 2), () {
      if (_isDisposed) return; // Проверяем, не уничтожен ли виджет

      setState(() {
        _isWaiting = false;
        _startTime = DateTime.now();
      });
    });
  }

  void _onTap() {
    if (!_isWaiting) {
      final reactionTime = DateTime.now().difference(_startTime).inMilliseconds / 1000;
      showDialog(
        context: context,
        builder: (context) => AlertDialog(
          title: const Text('Результат'),
          content: Text('Ваша скорость реакции: $reactionTime сек'),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.pop(context);
                _startTest();
              },
              child: const Text('Повторить'),
            ),
          ],
        ),
      );
    }
  }

  @override
  void initState() {
    super.initState();
    _startTest();
  }

  @override
  void dispose() {
    _isDisposed = true; // Устанавливаем флаг, чтобы остановить асинхронный процесс
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: _onTap,
      child: Container(
        width: 200,
        height: 200,
        color: _isWaiting ? Colors.grey : Colors.green,
        child: Center(
          child: Text(_isWaiting ? 'Ждите...' : 'Нажмите!'),
        ),
      ),
    );
  }
}