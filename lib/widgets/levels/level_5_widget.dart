import 'dart:async';
import 'dart:math';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:reaction_speed_trainer/providers/reaction_provider.dart';

class Level5Widget extends StatefulWidget {
  const Level5Widget({super.key});

  @override
  State<Level5Widget> createState() => _Level5WidgetState();
}

class _Level5WidgetState extends State<Level5Widget> {
  // Состояния экрана
  bool _isWaitingForStart = true;
  bool _isShowingTarget = false; // Флаг: показан ли цвет в верхнем блоке

  // Таймер и время реакции
  Timer? _timer;
  DateTime? _startTime;

  // Результаты теста
  double? _reactionTimeSum;
  int _currentRepetition = 1;
  int _errors = 0;
  int _selectedRepetitions = 5;
  final List<double> _reactionTimes = [];

  // Цвета для уровня (6 цветов)
  final List<Color> _availableColors = [
    Colors.red,
    Colors.green,
    Colors.blue,
    Colors.yellow,
    Colors.orange,
    Colors.purple,
  ];

  // Цвета для 6 нижних объектов
  List<Color> _bottomColors = [];

  // Цвет, который появляется в 7‑ом (верхнем) объекте
  Color? _targetColor;

  // Флаг для блокировки повторных нажатий
  bool _inputHandled = false;

  @override
  void initState() {
    super.initState();
    // Изначально нижние объекты без цвета (прозрачные)
    _bottomColors = List.filled(6, Colors.transparent);
  }

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
      _isShowingTarget = false;
      _startTime = null;
      _reactionTimeSum = null;
      _currentRepetition = 1;
      _errors = 0;
      _reactionTimes.clear();
      _timer?.cancel();
      _inputHandled = false;
      // Нижние объекты снова без цвета
      _bottomColors = List.filled(6, Colors.transparent);
    });
  }

  void _startTest() {
    // Генерируем неповторяющуюся последовательность для 6 нижних объектов
    _bottomColors = List.from(_availableColors);
    _bottomColors.shuffle();

    // Выбираем случайно один из цветов нижних объектов для показа в верхнем блоке
    final random = Random();
    int targetIndex = random.nextInt(_bottomColors.length);
    _targetColor = _bottomColors[targetIndex];

    setState(() {
      _isWaitingForStart = false;
      _isShowingTarget = false; // Пока не показываем верхний блок
      _inputHandled = false;
    });

    // После случайной задержки (от 1 до 2 секунд) появляется цвет в верхнем блоке
    _timer = Timer(Duration(seconds: random.nextInt(2) + 1), () {
      if (mounted){
        setState(() {
          _isShowingTarget = true;
          _startTime = DateTime.now();
        });
      }
    });
  }

  void _handleBottomTap(Color selectedColor) {
    if (_inputHandled) return;
    _inputHandled = true;

    // Если верхний блок ещё не показал цвет – нажатие раньше времени
    if (!_isShowingTarget) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Ошибка, слишком рано!'),
          duration: Duration(milliseconds: 500),
        ),
      );
      setState(() {
        _timer?.cancel();
        _isShowingTarget = false;
        _errors++;
      });
      Timer(const Duration(seconds: 1), () {
        if (mounted) {
          _startTest();
        }
      });
      return;
    }

    // Засекаем время реакции
    final reactionTime =
        DateTime.now().difference(_startTime!).inMilliseconds;

    // Если выбран правильный цвет, сохраняем время и переходим к следующему повторению
    if (selectedColor == _targetColor) {
      _reactionTimes.add(reactionTime.toDouble());
      _reactionTimeSum = (_reactionTimeSum ?? 0) + reactionTime;

      if (_currentRepetition >= _selectedRepetitions) {
        _showResults();
      } else {
        _currentRepetition++;
        _nextRound();
      }
    } else {
      // Неправильный выбор – ошибка
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Ошибка, неправильный выбор!'),
          duration: Duration(milliseconds: 500),
        ),
      );
      setState(() {
        _errors++;
        _isShowingTarget = false;
      });
      Timer(const Duration(seconds: 1), () {
        if (mounted) {
          _startTest();
        }
      });
    }
  }

  void _nextRound() {
    setState(() {
      _isWaitingForStart = true;
      _isShowingTarget = false;
    });
    _startTest();
  }

  void _showResults() {
    final details = _reactionTimes.asMap().entries.map((entry) {
    return {
      'reactionTimeMs': entry.value.toInt(),
      'attemptNumber': entry.key + 1,
    };
    }).toList();

    Provider.of<ReactionProvider>(context, listen: false).addResult(
      exerciseTypeId: 6,
      time: _reactionTimeSum! / _selectedRepetitions,
      repetitions: _selectedRepetitions,
      errors: _errors,
      details: details,
    );


    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (BuildContext context) {
        return AlertDialog(
          title:
              const Text('Результаты', textAlign: TextAlign.center),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(
                'Среднее время: ${(_reactionTimeSum! / _selectedRepetitions).toStringAsFixed(2)} мс',
                style: const TextStyle(
                    fontSize: 18, fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 10),
              Text('Ошибки: $_errors',
                  style: const TextStyle(
                      fontSize: 16, color: Colors.red)),
              const SizedBox(height: 20),
              ..._reactionTimes.asMap().entries.map((e) => Text(
                  'Повторение ${e.key + 1}: ${e.value.toStringAsFixed(2)} мс')),
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

  // Верхний блок (7-ый объект), который показывает целевой цвет после задержки.
  // Надпись "Ожидание" убрана.
  Widget _buildTargetBlock() {
    return Container(
      width: 150,
      height: 150,
      decoration: BoxDecoration(
        color: _isShowingTarget ? _targetColor : Colors.transparent,
        borderRadius: BorderRadius.circular(15),
        border: Border.all(
          color: Theme.of(context).textTheme.bodyLarge!.color!,
          width: 2,
        ),
      ),
    );
  }

  // Нижняя часть – 6 объектов, расположенных в 2 ряда по 3
  Widget _buildBottomGrid() {
    return Column(
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceEvenly,
          children: _bottomColors.sublist(0, 3).map((color) {
            return GestureDetector(
              onTap: () => _handleBottomTap(color),
              child: ColorSquare(color: color),
            );
          }).toList(),
        ),
        const SizedBox(height: 20),
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceEvenly,
          children: _bottomColors.sublist(3, 6).map((color) {
            return GestureDetector(
              onTap: () => _handleBottomTap(color),
              child: ColorSquare(color: color),
            );
          }).toList(),
        ),
      ],
    );
  }

  // Кнопка управления тестом
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
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        automaticallyImplyLeading: false,
        toolbarHeight: 70.0,
        actions: [
          Expanded(
            child: Row(
              mainAxisAlignment:
                  MainAxisAlignment.spaceBetween,
              children: [
                Padding(
                  padding: const EdgeInsets.symmetric(
                      horizontal: 16.0, vertical: 5.0),
                  child: Column(
                    crossAxisAlignment:
                        CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Повторение: $_currentRepetition/$_selectedRepetitions',
                        style: const TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.bold),
                      ),
                      const SizedBox(height: 5),
                      Text('Ошибки: $_errors',
                          style: const TextStyle(
                              fontSize: 18,
                              fontWeight: FontWeight.bold)),
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
      body: Padding(
        padding:
            const EdgeInsets.symmetric(vertical: 20, horizontal: 16),
        child: Column(
          children: [
            const Text(
              'Нажми на нижний блок с тем же цветом, что появился сверху',
              style: TextStyle(
                  fontSize: 16, fontWeight: FontWeight.bold),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 20),
            // Верхний блок (целевой цвет)
            _buildTargetBlock(),
            const Spacer(),
            // Нижняя сетка с 6 объектами
            _buildBottomGrid(),
            const Spacer(),
            _buildControlButton(),
          ],
        ),
      ),
    );
  }
}

class ColorSquare extends StatelessWidget {
  final Color color;
  final double size;

  const ColorSquare({
    super.key,
    required this.color,
    this.size = 100,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      width: size,
      height: size,
      decoration: BoxDecoration(
        color: color,
        borderRadius: BorderRadius.circular(15),
        border: Border.all(
          color: Theme.of(context).textTheme.bodyLarge!.color!,
          width: 2,
        ),
      ),
    );
  }
}
