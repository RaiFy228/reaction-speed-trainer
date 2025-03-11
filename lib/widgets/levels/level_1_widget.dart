import 'dart:async';
import 'dart:math';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:reaction_speed_trainer/providers/reaction_provider.dart';

class Level1Widget extends StatefulWidget {
  const Level1Widget({super.key});

  @override
  State<Level1Widget> createState() => _Level1WidgetState();
}

class _Level1WidgetState extends State<Level1Widget> {
  bool _isWaitingForStart = true;
  bool _isWaitingForGreen = false;
  bool _isShowingResult = false;
  bool _isRedActive = false; // Флаг для активности красного
  Timer? _timer;
  DateTime? _startTime;
  double? _reactionTimeSum;
  int _currentRepetition = 1;
  int _errors = 0;
  int _selectedRepetitions = 5;
  final List<double> _reactionTimes = [];



  @override
  void initState() {
    super.initState();
    _loadSelectedRepetitions();
  }

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
      _isRedActive = false;
      _startTime = null;
      _reactionTimeSum = null;
      _currentRepetition = 1;
      _errors = 0;
      _reactionTimes.clear();
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

  void _nextMeasurement() {
    _timer = Timer(Duration(seconds: Random().nextInt(2) + 2), () {
      if (mounted) {
        setState(() {
          _isWaitingForGreen = false;
          _isRedActive = Random().nextBool(); // Случайное включение красного
            if (_isRedActive) {
            // Таймер для того, чтобы красный цвет исчезал через 1-2 секунды
             _timer = Timer(const Duration(seconds: 1), () {
              if (mounted) {
                setState(() {
                  _isRedActive = false;
                  _isWaitingForGreen = true;
                });
                _nextMeasurement();
              }
            });
          } else {
            _startTime = DateTime.now();
          }
        });
      }
    });
  }

  void _onTap() {
    if (_isWaitingForStart) {
      return;
    } else if (_isWaitingForGreen) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Ошибка, слишком рано!'), duration: Duration(milliseconds: 500))
      );
      setState(() {
        _timer?.cancel();
        _isWaitingForGreen = true;
        _errors++;
      });
      _nextMeasurement();
    } else if (_isRedActive) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Ошибка, не тот цвет!'), duration: Duration(milliseconds: 500))
      );
      setState(() {
        _timer?.cancel();
        _errors++;
        _isRedActive = false;
        _isWaitingForGreen = true;
      });
      _nextMeasurement();
    } else if (!_isWaitingForGreen && !_isShowingResult) {
      final reactionTime = DateTime.now().difference(_startTime!).inMilliseconds.toDouble();
      
      setState(() {
        _reactionTimes.add(reactionTime);
        _reactionTimeSum = (_reactionTimeSum ?? 0) + reactionTime;
      });

      if (_currentRepetition >= _selectedRepetitions) {
        _showResults();
      } else {
        setState(() {
          _currentRepetition++;
          _isWaitingForGreen = true;
        });
        _nextMeasurement();
      }
    }
  }

  void _showResults() {
    Provider.of<ReactionProvider>(context, listen: false).addResult(
      type: 'levels',
      levelId: '1',
      time: _reactionTimeSum! / _selectedRepetitions,
      repetitions: _selectedRepetitions,
      errors: _errors,
    );

    _showResultsDialog();
  }

  void _showResultsDialog() {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text('Результат', textAlign: TextAlign.center),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Text('Среднее время: ${(_reactionTimeSum! / _selectedRepetitions).toStringAsFixed(2)} мс',
                  style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
              const SizedBox(height: 10),
              Text('Ошибки: $_errors', style: const TextStyle(fontSize: 16, color: Colors.red)),
              const SizedBox(height: 10),
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: List.generate(
                  _reactionTimes.length,
                  (index) => Text('Повторение ${index + 1} - ${_reactionTimes[index].toStringAsFixed(2)} мс'),
                ),
              ), 
            ],
          ),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.of(context).pop();
                _resetState();
              },
              child: const Text('Продолжить'),
            ),
          ],
        );
      },
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
      body: Center(
        child: Column(
          mainAxisSize: MainAxisSize.max,
          children: [
            const Padding(
              padding: EdgeInsets.symmetric(vertical: 20),
              child: Text(
                'Нажимай только на зеленый',
                style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                textAlign: TextAlign.center,
              ),
            ),
            const SizedBox(height: 50),
            GestureDetector(
              onTap: _onTap,
              child: Container(
                width: 300,
                height: 350,
                decoration: BoxDecoration(
                  color: _isWaitingForStart ? Colors.transparent : _getColor(),
                  borderRadius: BorderRadius.circular(15),
                  border: Border.all(
                    color: Theme.of(context).textTheme.bodyLarge!.color!,
                    width: 2,
                  ),
                ),
              ),
            ),
            Padding(
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
            ),
          ],
        ),
      ),
    );
  }

  Color _getColor() {
    if (_isRedActive) return Colors.red; // Появляется красный, если флаг установлен
    if (_isWaitingForGreen) return Colors.transparent;
    return Colors.green;
  }

}