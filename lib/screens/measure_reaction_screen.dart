import 'dart:async';
import 'dart:math';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/reaction_provider.dart';

class MeasureReactionScreen extends StatefulWidget {
  const MeasureReactionScreen({super.key});

  @override
  State<MeasureReactionScreen> createState() => _MeasureReactionScreenState();
}

class _MeasureReactionScreenState extends State<MeasureReactionScreen> {
  bool _isWaiting = true;
  late Timer _timer;
  DateTime? _startTime;

  @override
  void initState() {
    super.initState();
    _startTest();
  }

  void _startTest() {
    setState(() {
      _isWaiting = true;
    });
    _timer = Timer(Duration(seconds: Random().nextInt(5) + 2), () {
      setState(() {
        _isWaiting = false;
        _startTime = DateTime.now();
      });
    });
  }

  void _onTap() {
    if (!_isWaiting && _startTime != null) {
      final reactionTime = DateTime.now().difference(_startTime!).inMilliseconds / 1000;
      Provider.of<ReactionProvider>(context, listen: false).addResult(reactionTime);
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
  void dispose() {
    _timer.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Измерить скорость реакции')),
      body: Center(
        child: GestureDetector(
          onTap: _onTap,
          child: Container(
            width: 200,
            height: 200,
            color: _isWaiting ? Colors.grey : Colors.green,
            child: Center(
              child: Text(_isWaiting ? 'Ждите...' : 'Нажмите!'),
            ),
          ),
        ),
      ),
    );
  }
}