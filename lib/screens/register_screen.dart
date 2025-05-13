// ignore_for_file: use_build_context_synchronously

import 'package:flutter/material.dart';
import '../services/auth_service.dart';
import 'login_screen.dart';

class RegisterScreen extends StatefulWidget {
  const RegisterScreen({super.key});

  @override
  State<RegisterScreen> createState() => _RegisterScreenState();
}

class _RegisterScreenState extends State<RegisterScreen> {
  final AuthService _authService = AuthService();
  final _formKey = GlobalKey<FormState>();
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  final _fullNameController = TextEditingController();
  bool _isLoading = false;
  bool _isPasswordVisible = false;

  Future<void> _handleRegistration() async {
    if (!_formKey.currentState!.validate()) return;
    
    setState(() => _isLoading = true);
    
    try {
      await _authService.register(
        _emailController.text.trim(),
        _passwordController.text.trim(),
        _fullNameController.text.trim(),
      );
      
      if (mounted) {
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(builder: (context) => const LoginScreen()),
        );
      }
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(e.toString())),
      );
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Регистрация'),
        automaticallyImplyLeading: false,
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Form(
          key: _formKey,
          child: Column(
            children: [
              TextFormField(
                controller: _fullNameController,
                decoration: const InputDecoration(labelText: 'Полное имя'),
                validator: (value) {
                  if (value?.isEmpty ?? true) return 'Введите имя';
                  return null;
                },
              ),
              TextFormField(
                controller: _emailController,
                decoration: const InputDecoration(labelText: 'Email'),
                validator: (value) {
                  if (value?.isEmpty ?? true) return 'Введите email';
                  if (!value!.contains('@')) return 'Неверный формат email';
                  return null;
                },
              ),
              TextFormField(
                controller: _passwordController,
                obscureText: !_isPasswordVisible,
                decoration: InputDecoration(
                  labelText: 'Пароль',
                  suffixIcon: IconButton(
                    icon: Icon(_isPasswordVisible 
                      ? Icons.visibility_off 
                      : Icons.visibility),
                    onPressed: () => setState(() => 
                      _isPasswordVisible = !_isPasswordVisible),
                  ),
                ),
                validator: (value) {
                  if (value?.isEmpty ?? true) return 'Введите пароль';
                  if (value!.length < 6) return 'Минимум 6 символов';
                  return null;
                },
              ),
              const SizedBox(height: 20),
              ElevatedButton(
                onPressed: _isLoading ? null : _handleRegistration,
                child: _isLoading 
                  ? const CircularProgressIndicator()
                  : const Text('Зарегистрироваться'),
              ),
              TextButton(
                onPressed: () => Navigator.pushNamed(context, '/login'),
                child: const Text('Уже есть аккаунт? Войдите'),
              ),
            ],
          ),
        ),
      ),
    );
  }
}