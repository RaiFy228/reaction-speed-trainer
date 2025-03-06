import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:reaction_speed_trainer/screens/tabbed_home_screen.dart';
import 'package:reaction_speed_trainer/widgets/auth_screen_widget.dart';

class AuthWrapper extends StatelessWidget {
  const AuthWrapper({super.key});

  @override
  Widget build(BuildContext context) {
    final firebaseUser = FirebaseAuth.instance.currentUser;

    if (firebaseUser == null) {
      return AuthScreen(); // Экран входа
    } else {
      return const TabbedHomeScreen(); // Главный экран
    }
  }
}