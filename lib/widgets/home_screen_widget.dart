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
  bool _isTooEarly = false;
  bool _isEnd = false; // Состояние "слишком рано"
  Timer? _timer;
  DateTime? _startTime;
  double? _reactionTime;
  double? _reactionTimeSum;
  int _currentRepetition = 1; // Текущее повторение
  int _errors = 0; // Количество ошибок
  int _selectedRepetitions = 5; // Выбранное количество повторений

  @override
  void initState() {
    super.initState();
    _loadSelectedRepetitions();
  }

  // Загрузка сохраненного количества повторений
  Future<void> _loadSelectedRepetitions() async {
    final reactionProvider = Provider.of<ReactionProvider>(context, listen: false);
    final repetitions = await reactionProvider.getSelectedRepetitions();
    setState(() {
      _selectedRepetitions = repetitions;
    });
  }

  void _resetState() {
    setState(() {
      _isWaitingForStart = true;
      _isWaitingForGreen = false;
      _isShowingResult = false;
      _isTooEarly = false;
      _isEnd = false; 
      _startTime = null;
      _reactionTime = null;
      _reactionTimeSum = null;
      _currentRepetition = 1;
      _errors = 0;
      _timer?.cancel();
    });
  }

  void _startTest() {
    setState(() {
      _isWaitingForStart = false;
      _isWaitingForGreen = true;
    });

    _nextMeasurement();
  }

  void _nextMeasurement() async{

    _timer = Timer(Duration(seconds: Random().nextInt(2) + 2), () {
      if (mounted) {
        setState(() {
          _isWaitingForGreen = false;
          _startTime = DateTime.now();
        });
      }
    });
  }

  void _onTap() {
   if (_isEnd) {
      _resetState();
    }
    if (_isWaitingForStart) {
      // Первое нажатие для начала теста
      _startTest();
    } else if (_isWaitingForGreen) {
      // Ошибка: нажатие до появления зеленого цвета
      setState(() {
        _timer?.cancel();
        _isWaitingForGreen = false;
        _errors++;
        _isTooEarly = true; // Переключаемся в состояние "слишком рано"
      });
    } else if (_isTooEarly) {
      // После ошибки возвращаемся к желтому цвету
      _nextMeasurement();
      setState(() {
        _isTooEarly = false;
        _isWaitingForGreen = true;
      });
    } else if (!_isWaitingForGreen && !_isShowingResult) {
      
      // Корректное нажатие на зеленый блок
      final reactionTime = DateTime.now().difference(_startTime!).inMilliseconds.toDouble();
      setState(() {
        _reactionTimeSum = (_reactionTimeSum ?? 0) + reactionTime;
        _reactionTime = reactionTime;
        _isShowingResult = true;
      });
      if (_currentRepetition == _selectedRepetitions){
        _showResults();
        _isShowingResult = false;
        _isEnd = true;
      }
    }
     else if (_isShowingResult) {
      // Нажатие после отображения результата
      _nextMeasurement();
      setState(() {
        _isShowingResult = false;
        _isWaitingForGreen = true;
        _currentRepetition++;// Возвращаемся к начальному состоянию
      });
    }
    
  }

  void _showResults() {
    Provider.of<ReactionProvider>(context, listen: false).addResult(
      type: 'measurements',
      time: _reactionTimeSum! / _selectedRepetitions,
      repetitions: _selectedRepetitions,
      errors: _errors,
    );

    setState(() {
      _isShowingResult = true;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Тренинг Реакции'),
        actions: [
          Padding(
            padding: const EdgeInsets.all(16.0),
            child: Text(
              '$_currentRepetition/$_selectedRepetitions',
              style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
            ),
          ),
          IconButton(
            icon: Icon(Icons.refresh),
            onPressed: _resetState,
          ),
        ],
      ),
      body: Center(
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
            const SizedBox(height: 20),
            ElevatedButton(
              onPressed: () {
                Navigator.pushNamed(context, '/history');
              },
              child: const Text('История результатов'),
            ),
          ],
        ),
      ),
    );
  }

  Color _getColor() {
    if (_isWaitingForStart) {
      return Colors.grey; // Серый цвет до начала теста
    } else if (_isWaitingForGreen) {
      return Colors.yellow; // Желтый цвет во время ожидания
    } else if (_isTooEarly) {
      return Colors.red; // Красный цвет при ошибке
    } else if (_isShowingResult || _isEnd) {
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
    } else if (_isTooEarly) {
      return const Text(
        'Слишком рано!\nНажмите, чтобы продолжить',
        textAlign: TextAlign.center,
      );
      } else if (_isShowingResult) {
      return Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Text('${(_reactionTime!).toStringAsFixed(0)} мс'),
          Text('Среднее время реакции: ${(_reactionTimeSum! / (_currentRepetition)).toStringAsFixed(0)} мс'),
          const Text('Нажмите, чтобы продолжить'),
        ],
      );
    } else if (_isEnd) {
      return Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Text('${(_reactionTime!).toStringAsFixed(0)} мс'),
          Text('Среднее время реакции: ${(_reactionTimeSum! / (_currentRepetition)).toStringAsFixed(0)} мс'),
          Text('Ошибок: $_errors'),
          const Text('Нажмите, чтобы начать заново'),
        ],
      );
    } else {
      return const Text('Жмите!');
    }
  }
}