import 'dart:async';
import 'dart:math';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:reaction_speed_trainer/providers/reaction_provider.dart';

class Level3Widget extends StatefulWidget {
  const Level3Widget({super.key});

  @override
  State<Level3Widget> createState() => _Level3WidgetState();
}

class _Level3WidgetState extends State<Level3Widget> {
  // Состояния Level3Widget
  bool _isWaitingForStart = true;
  bool _isObjectVisible = false;

  // Параметры появления объекта
  bool? _isValidObject; // true – целевой, false – ложный
  double _objectX = 0.0;
  double _objectY = 0.0;
  final double _objectSize = 80.0; // размер объекта

  // Таймеры и время
  Timer? _delayTimer;
  Timer? _objectTimer;
  DateTime? _startTime;

  // Результаты
  final List<double> _reactionTimes = [];
  double _reactionTimeSum = 0;
  int _currentRepetition = 1;
  int _errors = 0;
  int _selectedRepetitions = 5;

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    final reactionProvider = Provider.of<ReactionProvider>(context);
    setState(() {
      _selectedRepetitions = reactionProvider.selectedRepetitions;
    });
  }

  void _resetState() {
    setState(() {
      _isWaitingForStart = true;
      _isObjectVisible = false;
      _startTime = null;
      _reactionTimeSum = 0;
      _currentRepetition = 1;
      _errors = 0;
      _reactionTimes.clear();
      _delayTimer?.cancel();
      _objectTimer?.cancel();
    });
  }

  void _startTest() {
    // Сбрасываем состояние появления объекта
    setState(() {
      _isWaitingForStart = false;
      _isObjectVisible = false;
    });
    // Задержка перед появлением объекта (от 1 до 3 секунд)
    int delayMs = Random().nextInt(1000) + 1000;
    _delayTimer = Timer(Duration(milliseconds: delayMs), _showObject);
  }

  void _handleObjectTap() {
  if (!_isObjectVisible) return;
  _objectTimer?.cancel();
  setState(() {
    _isObjectVisible = false;
  });

  if (_isValidObject == true) {
    // Засекаем время реакции
    final reactionTime = DateTime.now().difference(_startTime!).inMilliseconds;
    _reactionTimes.add(reactionTime.toDouble());
    _reactionTimeSum += reactionTime;
    if (_reactionTimes.length >= _selectedRepetitions) {
      _showResults();
    } else {
     _currentRepetition++; 
       _nextRound(); 
    }
  } else {
    // Ошибка – ложный объект нажат
    _errors++;
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('Ошибка, ложный объект!'), duration: Duration(milliseconds: 500))
    );
    _nextRound(); 
  }
}

void _showObject() {
  _isValidObject = Random().nextInt(100) < 50;

  final screenSize = MediaQuery.of(context).size;
  double maxX = screenSize.width - _objectSize;
  double maxY = screenSize.height - _objectSize - 370;
  _objectX = Random().nextDouble() * maxX;
  _objectY = Random().nextDouble() * maxY + 100;

  setState(() {
    _isObjectVisible = true;
  });

  if (_isValidObject == true) {
    _startTime = DateTime.now();
  }

  _objectTimer = Timer(const Duration(milliseconds: 1000), () {
    if (_isObjectVisible) {
      setState(() {
        _isObjectVisible = false;
      });

      if (_isValidObject == true) {
        _errors++;
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Ошибка, не успел!'), duration: Duration(milliseconds: 500))
        );
      }

      _nextRound();
    }
  });
}

void _nextRound() {
    Timer(const Duration(milliseconds: 500), () {
      if (mounted) _startTest();
    });
  }


  void _showResults() {
    final details = _reactionTimes.asMap().entries.map((entry) {
    return {
      'reactionTimeMs': entry.value.toInt(),
      'attemptNumber': entry.key + 1,
    };
    }).toList();

    Provider.of<ReactionProvider>(context, listen: false).addResult(
      exerciseTypeId: 4,
      time: _reactionTimeSum / _selectedRepetitions,
      repetitions: _selectedRepetitions,
      errors: _errors,
      details: details,
    );


    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text('Результаты', textAlign: TextAlign.center),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Text('Среднее время: ${(_reactionTimeSum / _selectedRepetitions).toStringAsFixed(2)} мс',
                  style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
              const SizedBox(height: 10),
              Text('Ошибки: $_errors', style: const TextStyle(fontSize: 16, color: Colors.red)),
              const SizedBox(height: 20),
              ..._reactionTimes.asMap().entries.map((e) => 
                Text('Повторение ${e.key + 1}: ${e.value.toStringAsFixed(2)} мс')
              ),
            ],
          ),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.of(context).pop();
                _resetState();
              },
              child: const Text('Повторить'),
            ),
          ],
        );
      },
    );
  }

  Widget _buildControlButton() {
    return Padding(
      padding: const EdgeInsets.all(16.0),
      child: ElevatedButton(
        onPressed: _isWaitingForStart ? _startTest : null,
        style: ElevatedButton.styleFrom(
          foregroundColor: Theme.of(context).textTheme.bodyLarge!.color,
          backgroundColor: Theme.of(context).scaffoldBackgroundColor,
          shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(8), // Скругление углов
            ),
          side: BorderSide(
            color: Theme.of(context).textTheme.bodyLarge!.color!,
            width: 2,
          ),
        ),
        child: Text(
          _isWaitingForStart ? 'Начать тест' : 'Идет тест...',
          style: const TextStyle(fontSize: 16),
        ),
      ),
    );
  }

  @override
  void dispose() {
    _delayTimer?.cancel();
    _objectTimer?.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
       appBar: AppBar(
        automaticallyImplyLeading: false,
        toolbarHeight: 70.0,
        actions: [
          Expanded(
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 5.0),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text('Повторение: $_currentRepetition/$_selectedRepetitions',
                          style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
                      Text('Ошибки: $_errors',
                          style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
                    ],
                  ),
                ),
                IconButton(
                  icon: const Icon(Icons.refresh),
                  onPressed: _resetState,
                ),
              ],
            ),
          ),
        ],
      ),
      body: Stack(
        children: [
          Column(
            children: [
              const Padding(
                padding: EdgeInsets.symmetric(vertical: 20),
                child: Text(
                  'Нажимай только на зеленый круг!',
                  style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                  textAlign: TextAlign.center,
                ),
              ),
              Expanded(child: Container()),
              _buildControlButton(),
            ],
          ),
          // Объект появляется в случайном месте экрана
          if (_isObjectVisible)
            Positioned(
              left: _objectX,
              top: _objectY,
              child: GestureDetector(
                onTap: _handleObjectTap,
                child: Container(
                  width: _objectSize,
                  height: _objectSize,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    color: _isValidObject == true ? Colors.green : Colors.red,
                     border: Border.all(
                      color: Theme.of(context).textTheme.bodyLarge!.color!,
                      width: 2,
                    ),
                  ),
                ),
              ),
            ),
        ],
      ),
    );
  }
}
