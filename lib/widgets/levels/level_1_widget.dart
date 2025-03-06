import 'dart:async';
import 'dart:math';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:reaction_speed_trainer/providers/reaction_provider.dart';

class Level1EasyWidget extends StatefulWidget {
  const Level1EasyWidget({super.key});

  @override
  State<Level1EasyWidget> createState() => _Level1EasyWidgetState();
}

class _Level1EasyWidgetState extends State<Level1EasyWidget> {
  bool _isWaitingForStart = true; // Ожидание первого нажатия
  bool _isWaitingForGreen = false; // Ожидание смены цвета на зеленый
  bool _isShowingResult = false; // Отображение результата
  Timer? _timer;
  DateTime? _startTime;
  double? _reactionTime;

  void _resetState() {
    setState(() {
      _isWaitingForStart = true;
      _isWaitingForGreen = false;
      _isShowingResult = false;
      _startTime = null;
      _reactionTime = null;
      _timer?.cancel(); // Отменяем таймер, если он активен
    });
  }

  void _startTest() {
    setState(() {
      _isWaitingForStart = false;
      _isWaitingForGreen = true;
    });

    // Случайная задержка перед сменой цвета на зеленый
    _timer = Timer(Duration(seconds: Random().nextInt(5) + 2), () {
      if (mounted) {
        setState(() {
          _isWaitingForGreen = false;
          _startTime = DateTime.now(); // Начало измерения времени реакции
        });
      }
    });
  }

  void _onTap() {
    if (_isWaitingForStart) {
      // Первое нажатие для начала теста
      _startTest();
    } else if (!_isWaitingForGreen && !_isShowingResult) {
      // Нажатие на зеленый блок
      final reactionTime = DateTime.now().difference(_startTime!).inMilliseconds.toDouble();
      Provider.of<ReactionProvider>(context, listen: false).addResult(
        type: 'levels',
        levelId: '1', // ID уровня
        difficulty: 'Легко', // Сложность
        time: reactionTime,
      );
      setState(() {
        _reactionTime = reactionTime;
        _isShowingResult = true; // Показываем результат
      });
    } else if (_isShowingResult) {
      // Нажатие после отображения результата
      _resetState(); // Возвращаемся к начальному состоянию
    }
  }

  @override
  void dispose() {
    _timer?.cancel(); // Отменяем таймер при уничтожении виджета
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Text(_isShowingResult ? '${(_reactionTime!).toStringAsFixed(0)} мс' : 'Уровень 1 - Легко'),
          const SizedBox(height: 20),
          GestureDetector(
            onTap: _onTap,
            child: Container(
              width: 200,
              height: 200,
              color: _getColor(),
              child: Center(
                child: _getText(),
              ),
            ),
          ),
          const SizedBox(height: 20),
          ElevatedButton(
            onPressed: _resetState,
            child: const Text('Сбросить'),
          ),
        ],
      ),
    );
  }

  Color _getColor() {
    if (_isWaitingForStart) {
      return Colors.grey; // Серый цвет до начала теста
    } else if (_isWaitingForGreen) {
      return Colors.grey; // Серый цвет во время ожидания
    } else if (_isShowingResult) {
      return Colors.blue; // Синий цвет при отображении результата
    } else {
      return Colors.green; // Зеленый цвет для нажатия
    }
  }

  Widget _getText() {
    if (_isWaitingForStart) {
      return const Text('Нажмите, чтобы начать');
    } else if (_isWaitingForGreen) {
      return const Text('Ждите...');
    } else if (_isShowingResult) {
      return Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Text('${(_reactionTime!).toStringAsFixed(0)} мс'),
          const Text('Нажмите, чтобы продолжить'),
        ],
      );
    } else {
      return const Text('Нажмите!');
    }
  }
}

class Level1MediumWidget extends StatefulWidget {
  const Level1MediumWidget({super.key});

  @override
  State<Level1MediumWidget> createState() => _Level1MediumWidgetState();
}

class _Level1MediumWidgetState extends State<Level1MediumWidget> {
  bool _isWaitingForStart = true; // Ожидание первого нажатия
  bool _isWaitingForGreen = false; // Ожидание смены цвета на зеленый
  bool _isShowingResult = false; // Отображение результата
  Timer? _timer;
  DateTime? _startTime;
  double? _reactionTime;

  void _resetState() {
    setState(() {
      _isWaitingForStart = true;
      _isWaitingForGreen = false;
      _isShowingResult = false;
      _startTime = null;
      _reactionTime = null;
      _timer?.cancel(); // Отменяем таймер, если он активен
    });
  }

  void _startTest() {
    setState(() {
      _isWaitingForStart = false;
      _isWaitingForGreen = true;
    });

    // Случайная задержка перед сменой цвета на зеленый
    _timer = Timer(Duration(seconds: Random().nextInt(5) + 2), () {
      if (mounted) {
        setState(() {
          _isWaitingForGreen = false;
          _startTime = DateTime.now(); // Начало измерения времени реакции
        });
      }
    });
  }

  void _onTap() {
    if (_isWaitingForStart) {
      // Первое нажатие для начала теста
      _startTest();
    } else if (!_isWaitingForGreen && !_isShowingResult) {
      // Нажатие на зеленый блок
      final reactionTime = DateTime.now().difference(_startTime!).inMilliseconds.toDouble();
      Provider.of<ReactionProvider>(context, listen: false).addResult(
        type: 'levels',
        levelId: '1', // ID уровня
        difficulty: 'Средне', // Сложность
        time: reactionTime,
      );
      setState(() {
        _reactionTime = reactionTime;
        _isShowingResult = true; // Показываем результат
      });
    } else if (_isShowingResult) {
      // Нажатие после отображения результата
      _resetState(); // Возвращаемся к начальному состоянию
    }
  }

  @override
  void dispose() {
    _timer?.cancel(); // Отменяем таймер при уничтожении виджета
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Text(_isShowingResult ? '${(_reactionTime!).toStringAsFixed(0)} мс' : 'Уровень 1 - средне'),
          const SizedBox(height: 20),
          GestureDetector(
            onTap: _onTap,
            child: Container(
              width: 200,
              height: 200,
              color: _getColor(),
              child: Center(
                child: _getText(),
              ),
            ),
          ),
          const SizedBox(height: 20),
          ElevatedButton(
            onPressed: _resetState,
            child: const Text('Сбросить'),
          ),
        ],
      ),
    );
  }

  Color _getColor() {
    if (_isWaitingForStart) {
      return Colors.grey; // Серый цвет до начала теста
    } else if (_isWaitingForGreen) {
      return Colors.grey; // Серый цвет во время ожидания
    } else if (_isShowingResult) {
      return Colors.blue; // Синий цвет при отображении результата
    } else {
      return Colors.green; // Зеленый цвет для нажатия
    }
  }

  Widget _getText() {
    if (_isWaitingForStart) {
      return const Text('Нажмите, чтобы начать');
    } else if (_isWaitingForGreen) {
      return const Text('Ждите...');
    } else if (_isShowingResult) {
      return Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Text('${(_reactionTime!).toStringAsFixed(0)} мс'),
          const Text('Нажмите, чтобы продолжить'),
        ],
      );
    } else {
      return const Text('Нажмите!');
    }
  }
}

class Level1HardWidget extends StatelessWidget {
  const Level1HardWidget({super.key});

  @override
  Widget build(BuildContext context) {
    return const Center(
      child: Text('Уровень 1 - Сложно'),
    );
  }
}