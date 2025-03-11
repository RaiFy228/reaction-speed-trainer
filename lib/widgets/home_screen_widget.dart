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
  bool _isWaitingForStart = true;
  bool _isWaitingForGreen = false;
  bool _isShowingResult = false;
  bool _isTooEarly = false;
  Timer? _timer;
  DateTime? _startTime;
  double? _reactionTimeSum;
  int _currentRepetition = 1;
  int _errors = 0;
  int _selectedRepetitions = 0;
  final List<double> _reactionTimes = []; // Список для хранения времен реакций

@override
void didChangeDependencies() {
  super.didChangeDependencies();
  final reactionProvider = Provider.of<ReactionProvider>(context);
  setState(() {
    _selectedRepetitions = reactionProvider.selectedRepetitions;
  });
}

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
      _isTooEarly = false;
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
          _startTime = DateTime.now();
        });
      }
    });
  }

    void _onTap() {
    if (_isWaitingForStart) {
      _startTest();
    } else if (_isWaitingForGreen) {
      setState(() {
        _timer?.cancel();
        _isWaitingForGreen = false;
        _errors++;
        _isTooEarly = true;
      });
    } else if (_isTooEarly) {
      setState(() {
        _isTooEarly = false;
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
        _showResults(); // Показываем результат, но НЕ увеличиваем _currentRepetition
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
      type: 'measurements',
      time: _reactionTimeSum! / _selectedRepetitions,
      repetitions: _selectedRepetitions,
      errors: _errors,
    );

    _showResultsDialog();
     // Открываем окно с результатами
  }

  void _showResultsDialog() {
    showDialog(
      context: context,
      barrierDismissible: false, // Запрещаем закрытие кликом вне окна
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
                      // Повторение: ...
                      Padding(
                        padding: const EdgeInsets.only(bottom: 2.0),
                        child: Text(
                          'Повторение: $_currentRepetition/$_selectedRepetitions',
                          style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                        ),
                      ),
                      // Ошибки: ...
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
                // Кнопка рестарта
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
  child: SingleChildScrollView(
    padding: EdgeInsets.only(bottom: 100),
    child: Column(
      mainAxisSize: MainAxisSize.max,
      children: [
        const Padding(
          padding: EdgeInsets.symmetric(vertical: 20),
          child: Text(
            'Дождитесь зелёного цвета и нажмите!',
            style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
            textAlign: TextAlign.center,
          ),
        ),
        const SizedBox(height: 10),
        GestureDetector(
          onTap: _onTap,
          child: Container(
            width: 300,
            height: 350,
            decoration: BoxDecoration(
              color: _isWaitingForStart 
                ? Theme.of(context).scaffoldBackgroundColor 
                : _getColor(),
              borderRadius: BorderRadius.circular(15),
              border: Border.all(
                color: Theme.of(context).textTheme.bodyLarge!.color!,
                width: 2,
              ),
            ),
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
          style: ElevatedButton.styleFrom(
            foregroundColor: Theme.of(context).textTheme.bodyLarge!.color,
            backgroundColor: Theme.of(context).scaffoldBackgroundColor,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(8),
            ),
            side: BorderSide(
              color: Theme.of(context).textTheme.bodyLarge!.color!,
              width: 2,
            ),
          ),
          child: const Text('История результатов', style: TextStyle(fontSize: 16)),
        ),
      ],
    ),
  ),
),
    );
  }




  Color _getColor() {
    if (_isTooEarly) return Colors.transparent;
    if (_isWaitingForGreen) return Colors.transparent;
    return Colors.green;
  }

   Widget _getText() {
    if (_isWaitingForStart) {
      return const Text('Начать');
    } else if (_isWaitingForGreen){
      return const Text('Ждите');      
    } else if (_isTooEarly) {
      return Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          const Text(
            'Ошибка!',
            style: TextStyle(color: Colors.red, fontWeight: FontWeight.bold, fontSize: 24),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 8), // Отступ между строками
          const Text(
            'Нажмите, чтобы продолжить',
            style: TextStyle(fontSize: 16),
            textAlign: TextAlign.center,
          ),
        ],
      );
    } else {
      return const Text('');
    }
  }
}