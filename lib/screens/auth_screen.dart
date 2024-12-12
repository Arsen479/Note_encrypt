import 'package:flutter/material.dart';
import 'package:local_auth/local_auth.dart';
import 'home_screen.dart';
import 'package:hive/hive.dart';

class AuthScreen extends StatefulWidget {
  const AuthScreen({super.key});

  @override
  State<AuthScreen> createState() => _AuthScreenState();
}

class _AuthScreenState extends State<AuthScreen> {
  final _localAuth = LocalAuthentication();
  final _pinController = TextEditingController();
  late Box authBox;

  @override
  void initState() {
    super.initState();
    authBox = Hive.box('auth');
  }

  Future<void> _authenticate() async {
    try {
      final isAuthenticated = await _localAuth.authenticate(
        localizedReason: 'Authenticate to access your notes',
        options:const AuthenticationOptions(
          biometricOnly: true,
        ),
      );
      if (isAuthenticated) {
        _navigateToHome();
      }
    } catch (e) {
      print('Authentication failed: $e');
    }
  }

  void _checkPin() {
    final savedPin = authBox.get('pin');
    if (_pinController.text == savedPin) {
      _navigateToHome();
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Incorrect PIN')),
      );
    }
  }

  void _navigateToHome() {
    Navigator.pushReplacement(
      context,
      MaterialPageRoute(builder: (context) => const HomeScreen()),
    );
  }

  @override
  Widget build(BuildContext context) {
    final savedPin = authBox.get('pin');

    return Scaffold(
      appBar: AppBar(title: const Text('Authentication')),
      body: Center(
        child: savedPin == null ? _buildSetPin() : _buildAuthOptions(savedPin),
      ),
    );
  }

  Widget _buildSetPin() {
    return Column(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        const Text('Set a PIN for your app'),
        Padding(
          padding: const EdgeInsets.all(16.0),
          child: TextField(
            controller: _pinController,
            obscureText: true,
            decoration: const InputDecoration(labelText: 'Enter PIN'),
          ),
        ),
        ElevatedButton(
          onPressed: () {
            authBox.put('pin', _pinController.text);
            ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(content: Text('PIN saved!')),
            );
          },
          child: const Text('Save PIN'),
        ),
      ],
    );
  }

  Widget _buildAuthOptions(String savedPin) {
    return Column(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        ElevatedButton(
          onPressed: _authenticate,
          child: const Text('Authenticate with Biometrics'),
        ),
        const Text('OR'),
        Padding(
          padding: const EdgeInsets.all(16.0),
          child: TextField(
            controller: _pinController,
            obscureText: true,
            decoration: const InputDecoration(labelText: 'Enter PIN'),
          ),
        ),
        ElevatedButton(
          onPressed: _checkPin,
          child: const Text('Authenticate with PIN'),
        ),
      ],
    );
  }
}
