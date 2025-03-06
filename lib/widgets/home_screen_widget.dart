import 'dart:async';
import 'dart:math';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/reaction_provider.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  bool _isWaitingForStart = true; // Ожидание первого нажатия
  bool _isWaitingForGreen = false; // Ожидание смены цвета на зеленый
  bool _isShowingResult = false; // Отображение результата
  Timer? _timer;
  DateTime? _startTime;
  double? _reactionTime;

  @override
  void initState() {
    super.initState();
    // Сбрасываем состояние при инициализации
    _resetState();
  }

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
      Provider.of<ReactionProvider>(context, listen: false).addResult(type: 'measurements', time: reactionTime);
      setState(() {
        _reactionTime = reactionTime;
        _isShowingResult = true; // Показываем результат
      });
    } else if (_isShowingResult) {
      // Нажатие после отображения результата
      setState(() {
        _isShowingResult = false;
        _isWaitingForStart = true; // Возвращаемся к начальному состоянию
      });
    }
  }
  @override
  void dispose() {
    _timer?.cancel(); // Отменяем таймер при уничтожении виджета
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    Provider.of<ReactionProvider>(context);

    return Scaffold(
      body: Center(
        child: SingleChildScrollView(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              GestureDetector(
                onTap: _onTap,
                child: Container(
                  width: 300,
                  height: 350,
                  color: _getColor(),
                  child: Center(
                    child: _getText(),
                  ),
                ),
              ),
              const SizedBox(height: 30),
              ElevatedButton(
                onPressed: () {
                  Navigator.pushNamed(context, '/history');
                },
                child: const Text('История результатов'),
              ),
              const SizedBox(height: 30),
            ],
          ),
        ),
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