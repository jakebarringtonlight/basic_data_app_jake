import 'package:flutter/material.dart';
import 'package:my_menu_app/create_user_page.dart';
import 'package:my_menu_app/menu_page.dart';
import 'package:my_menu_app/warehouse_api.dart';

class LoginPage extends StatefulWidget {
  const LoginPage({Key? key}) : super(key: key);

@override
  State<LoginPage> createState() => _LoginPageState();
}

class _LoginPageState extends State<LoginPage> {
  final TextEditingController _usernameController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();
  final api = WarehouseApi(baseUrl: 'http://127.0.0.1:8080');
  
  String? _error;
  bool _attemptingLogin = false;

  Future<void> _loginHandler() async {
    final username = _usernameController.text.trim();
    final password = _passwordController.text.trim();

    setState(() {
      _error = null;
    });

    if (username.isEmpty || password.isEmpty)
    {
      setState(() {
        _error = "Please enter username password.";
        return;
      });
    }

    setState(() {
      _attemptingLogin = true;
    });

    try
    {
      await api.login(username: username, password: password);
      
      Navigator.push(
        context,
        MaterialPageRoute(
          builder: (context) => const MenuPage(),
        ),
      );
    }
    catch (exception)
    {
      setState(() {
        _error = "Login Failed";
      });
    }
    finally
    {
      setState(() {
        _attemptingLogin = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
        return Scaffold(
      appBar: AppBar(
        title: Text('Login'),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            const SizedBox(height: 20),
            TextField(
              controller: _usernameController,
              decoration: InputDecoration(
                labelText: 'Username',
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(8),
                ),
                prefixIcon: const Icon(Icons.person_2_rounded),
              ),
            ),

            const SizedBox(height: 20),
            TextField(
              controller: _passwordController,
              decoration: InputDecoration(
                labelText: 'Password',
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(8),
                ),
                prefixIcon: const Icon(Icons.password_rounded),
              ),
            ),

            if (_error != null) ...[
              Text(_error!, style: const TextStyle(color: Colors.red)),
              const SizedBox(height: 12),
            ],

            const SizedBox(height: 20),
            ElevatedButton(
              onPressed: _attemptingLogin ? null : _loginHandler,
              
              child: const Text('Login'),
              style: ElevatedButton.styleFrom(
                padding: const EdgeInsets.symmetric(
                  horizontal: 40,
                  vertical: 15,
                ),
              ),
            ),

            const SizedBox(height: 20),
            ElevatedButton(
              onPressed: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => const CreateUserPage(),
                  ),
                );
              },
              child: const Text('Create User'),
              style: ElevatedButton.styleFrom(
                padding: const EdgeInsets.symmetric(
                  horizontal: 40,
                  vertical: 15,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}