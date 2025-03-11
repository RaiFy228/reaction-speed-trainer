import 'dart:async';
import 'dart:math';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:reaction_speed_trainer/providers/reaction_provider.dart';

class Level2Widget extends StatefulWidget {
  const Level2Widget({super.key});

  @override
  State<Level2Widget> createState() => _Level2Widget();
}

class _Level2Widget extends State<Level2Widget> {
  // Состояния экрана
  bool _isWaitingForStart = true;
  bool _isShowingHint = false;
  bool _isShowingObjects = false;
  
  // Таймеры и время
  Timer? _timer;
  DateTime? _startTime;
  
  // Результаты
  double? _reactionTimeSum;
  int _currentRepetition = 1;
  int _errors = 0;
  int _selectedRepetitions = 5;
  final List<double> _reactionTimes = [];
  
  // Цвета
  Color? _hintColor;
  Color? _correctColor;
  Color? _wrongColor;
  final List<Color> _availableColors = [
    Colors.red, 
    Colors.green, 
    Colors.blue, 
    Colors.yellow
  ];
  
  // Флаг для случайного расположения правильного цвета
  bool _isCorrectOnLeft = true;

  // Флаг для блокировки повторных нажатий
  bool _inputHandled = false;

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
      _isShowingHint = false;
      _isShowingObjects = false;
      _startTime = null;
      _reactionTimeSum = null;
      _currentRepetition = 1;
      _errors = 0;
      _reactionTimes.clear();
      _timer?.cancel();
      _inputHandled = false;
    });
  }

  void _startTest() {
    _generateNewColors();
    // Сбрасываем флаг для нового раунда
    _inputHandled = false;
    setState(() {
      _isWaitingForStart = false;
      _isShowingHint = true;
    });
    
    // Показываем подсказку 500 мс
    _timer = Timer(const Duration(milliseconds: 500), () {
      if (mounted){
        setState(() => _isShowingHint = false);
        _startWaitingPeriod();
      }
    });
  }

  void _generateNewColors() {
    final random = Random();
    _hintColor = _availableColors[random.nextInt(_availableColors.length)];
    _correctColor = _hintColor;
    do {
      _wrongColor = _availableColors[random.nextInt(_availableColors.length)];
    } while (_wrongColor == _correctColor);
    // Определяем случайное расположение правильного цвета
    _isCorrectOnLeft = random.nextBool();
  }

  void _startWaitingPeriod() {
    _timer = Timer(Duration(seconds: Random().nextInt(2) + 1), () {
      if (mounted){
        _showObjects();
      }
  });
  }

  void _showObjects() {
    setState(() {
      _isShowingObjects = true;
      _startTime = DateTime.now();
    });
  }

  void _handleColorSelection(Color selectedColor) {
    // Если нажатие уже обработано, игнорируем повторные клики
    if (_inputHandled) return;
    _inputHandled = true;

    // Если объекты ещё не показаны, значит пользователь нажал раньше времени
    if (!_isShowingObjects) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Ошибка, слишком рано!'), duration: Duration(milliseconds: 500))
      );
      setState(() {
        _timer?.cancel();
        _isShowingObjects = false;
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
    final reactionTime = DateTime.now().difference(_startTime!).inMilliseconds;
      
    if (selectedColor == _correctColor) {
      _reactionTimes.add(reactionTime.toDouble());
      _reactionTimeSum = (_reactionTimeSum ?? 0) + reactionTime;
      
      if (_currentRepetition >= _selectedRepetitions) {
        _showResults();
      } else {
        _nextRound();
      }
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Ошибка, неправильный выбор!'), duration: Duration(milliseconds: 500))
      );
      setState(() {
        _errors++;
        _isShowingObjects = false;
      });
      _startTest();
    }
  }

  void _nextRound() {
    setState(() {
      _currentRepetition++;
      _isShowingObjects = false;
    });
    _startTest();
  }

  void _showResults() {
    Provider.of<ReactionProvider>(context, listen: false).addResult(
      type: 'levels',
      levelId: '2',
      time: _reactionTimeSum! / _selectedRepetitions,
      repetitions: _selectedRepetitions,
      errors: _errors,
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
              Text('Среднее время: ${(_reactionTimeSum! / _selectedRepetitions).toStringAsFixed(2)} мс',
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

  Widget _buildHintBlock() {
    return Container(
      width: 200,
      height: 200,
      decoration: BoxDecoration(
        color: _isShowingHint ? _hintColor : Colors.transparent,
        borderRadius: BorderRadius.circular(15),
        border: Border.all(
          color: Theme.of(context).textTheme.bodyLarge!.color!,
          width: 2,
        ),
      ),
    );
  }

  Widget _buildChoiceBlocks() {
    // Если цвета ещё не сгенерированы, используем прозрачный цвет
    Color leftColor = Colors.transparent;
    Color rightColor = Colors.transparent;
    if (_correctColor != null && _wrongColor != null) {
      leftColor = _isCorrectOnLeft ? _correctColor! : _wrongColor!;
      rightColor = _isCorrectOnLeft ? _wrongColor! : _correctColor!;
    }
    
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        ColorSquare(
          _isShowingObjects ? leftColor : Colors.transparent,
          onTap: () {
            if (_isWaitingForStart) return;
            if (_correctColor != null && _wrongColor != null) {
              _handleColorSelection(leftColor);
            }
          },
        ),
        const SizedBox(width: 20),
        ColorSquare(
          _isShowingObjects ? rightColor : Colors.transparent,
          onTap: () {
            if (_isWaitingForStart) return;
            if (_correctColor != null && _wrongColor != null) {
              _handleColorSelection(rightColor);
            }
          },
        ),
      ],
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
                      Padding(
                        padding: const EdgeInsets.only(bottom: 2.0),
                        child: Text(
                          'Повторение: $_currentRepetition/$_selectedRepetitions',
                          style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                        ),
                      ),
                      Padding(
                        padding: const EdgeInsets.only(bottom: 2.0),
                        child: Text(
                          'Ошибки: $_errors',
                          style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                        ),
                      ),
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
      body: Column(
        children: [
          const Padding(
              padding: EdgeInsets.symmetric(vertical: 20),
              child: Text(
                'Запомни цвет сверху и нажми на него снизу',
                style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                textAlign: TextAlign.center,
              ),
            ),
          Expanded(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.spaceAround,
              children: [
                // Верхний блок для подсказки
                _buildHintBlock(),
                // Нижние блоки для выбора
                _buildChoiceBlocks(),
              ],
            ),
          ),
          _buildControlButton(),
        ],
      ),
    );
  }
}

class ColorSquare extends StatelessWidget {
  final Color color;
  final double size;
  final VoidCallback? onTap;

  const ColorSquare(this.color, {
    super.key, 
    this.size = 150,
    this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
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
      ),
    );
  }
}
