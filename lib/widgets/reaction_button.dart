import 'package:flutter/material.dart';

class ReactionButton extends StatelessWidget {
  final VoidCallback onPressed;

  const ReactionButton({super.key, required this.onPressed});

  @override
  Widget build(BuildContext context) {
    return ElevatedButton(
      onPressed: onPressed,
      style: ElevatedButton.styleFrom(
        minimumSize: const Size(double.infinity, 50),
      ),
      child: const Text('Нажмите кнопку'),
    );
  }
}