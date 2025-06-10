import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../services/auth_service.dart';
import 'auth_screen.dart';
import 'user_profile_screen.dart';

class StoreFrontScreen extends StatefulWidget {
  final SharedPreferences prefs;

  const StoreFrontScreen({super.key, required this.prefs});

  @override
  State<StoreFrontScreen> createState() => _StoreFrontScreenState();
}

class _StoreFrontScreenState extends State<StoreFrontScreen> {
  late final AuthService _authService;

  @override
  void initState() {
    super.initState();
    _authService = AuthService();
  }

  Future<void> _handleLogout() async {
    await _authService.logout();
    if (mounted) {
      Navigator.of(context).pushReplacement(
        MaterialPageRoute(builder: (context) => AuthScreen(prefs: widget.prefs)),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Store'),
        actions: [
          IconButton(
            icon: const Icon(Icons.person),
            onPressed: () {
              Navigator.of(context).push(
                MaterialPageRoute(
                  builder: (context) => UserProfileScreen(prefs: widget.prefs),
                ),
              );
            },
          ),
          IconButton(
            icon: const Icon(Icons.logout),
            onPressed: _handleLogout,
          ),
        ],
      ),
      body: const Center(
        child: Text('Welcome to the Store!'),
      ),
    );
  }
} 