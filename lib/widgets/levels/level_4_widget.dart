import 'dart:async';
import 'dart:math';

import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:reaction_speed_trainer/providers/reaction_provider.dart';

class Level4Widget extends StatefulWidget {
  const Level4Widget({super.key});

  @override
  State<Level4Widget> createState() => _Level4WidgetState();
}

class _Level4WidgetState extends State<Level4Widget> {
  bool _isWaitingForStart = true;
  bool _isObjectVisible = false;
  bool _isReady = false; // Флаг, показывающий, что круг достиг цели

  // Параметры роста круга
  double _currentDiameter = 30.0;
  double _targetDiameter = 150.0; // Будет меняться случайным образом
  double _growthStep = 2.0; // Будет меняться случайным образом
  final int _growthInterval = 50;

  Timer? _delayTimer;
  Timer? _growthTimer;
  DateTime? _startTime;

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
      _isReady = false;
      _currentDiameter = 30.0;
      _startTime = null;
      _reactionTimeSum = 0;
      _currentRepetition = 1;
      _errors = 0;
      _reactionTimes.clear();
      _delayTimer?.cancel();
      _growthTimer?.cancel();
    });
  }

  void _startTest() {
    setState(() {
      _isWaitingForStart = false;
      _isObjectVisible = false;
      _isReady = false;
    });

    // Генерация случайных параметров:
    // - Конечный диаметр теперь от 200 до 350 (больше чем раньше)
    _targetDiameter = Random().nextInt(190) + 200; // 200 - 390
    _currentDiameter = Random().nextInt(100) + 20;    // Начальный диаметр: от 20 до 120
    _growthStep = Random().nextDouble() * 20 + 2;       // Скорость роста: от 2 до 22

    _delayTimer = Timer(Duration(milliseconds: 500), _startGrowingCircle);
  }

  void _startGrowingCircle() {
    setState(() {
      _isObjectVisible = true;
    });

    // Таймер роста: останавливаем, когда круг достигнет целевого диаметра.
    _growthTimer = Timer.periodic(Duration(milliseconds: _growthInterval), (timer) {
      if (_currentDiameter + _growthStep >= _targetDiameter) {
        setState(() {
          _currentDiameter = _targetDiameter;
          _isReady = true; // Круг готов, становится зелёным
        });
        timer.cancel();
        // Время реакции начинается в этот момент
        _startTime = DateTime.now();
      } else {
        // Случайным образом меняем скорость роста (примерно 20% шанс на тик)
        if (Random().nextDouble() < 0.2) {
          _growthStep = Random().nextDouble() * 20 + -2;
        }
        setState(() => _currentDiameter += _growthStep);
      }
    });
  }

  void _handleObjectTap() {
    if (!_isObjectVisible) return;

    // Если круг ещё не достиг нужного размера, считаем, что нажатие слишком рано
    if (!_isReady) {
      _growthTimer?.cancel();
      setState(() => _isObjectVisible = false);
      _errors++;
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Слишком рано!'), duration: Duration(milliseconds: 500)),
      );
      _startTest();
      return;
    }

    // Измеряем время реакции с момента, когда круг стал готов
    final reactionTime = DateTime.now().difference(_startTime!).inMilliseconds;
    _reactionTimes.add(reactionTime.toDouble());
    _reactionTimeSum += reactionTime;

    setState(() => _isObjectVisible = false);

    if (_reactionTimes.length >= _selectedRepetitions) {
      _showResults();
    } else {
      _currentRepetition++;
      _startTest();
    }
  }

  void _showResults() {
    final details = _reactionTimes.asMap().entries.map((entry) {
    return {
      'reactionTimeMs': entry.value.toInt(),
      'attemptNumber': entry.key + 1,
    };
    }).toList();

    Provider.of<ReactionProvider>(context, listen: false).addResult(
      exerciseTypeId: 5,
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
    _growthTimer?.cancel();
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
                  'Нажми, когда круг достигнет нужного размера!',
                  style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                  textAlign: TextAlign.center,
                ),
              ),
              Expanded(child: Container()),
              _buildControlButton(),
            ],
          ),
          if (_isObjectVisible)
            Center(
              child: GestureDetector(
                onTap: _handleObjectTap,
                child: Stack(
                  alignment: Alignment.center,
                  children: [
                    // Черная граница целевого диаметра
                    Container(
                      width: _targetDiameter,
                      height: _targetDiameter,
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        border: Border.all(
                          color: Theme.of(context).textTheme.bodyLarge!.color!,
                          width: 2,
                        ),
                      ),
                    ),
                    // Анимированный круг
                    AnimatedContainer(
                      duration: const Duration(milliseconds: 50),
                      width: _currentDiameter,
                      height: _currentDiameter,
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        color: _isReady ? Colors.green : Colors.transparent,
                        border: Border.all(
                          color: Theme.of(context).textTheme.bodyLarge!.color!,
                          width: 2,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
        ],
      ),
    );
  }
}
