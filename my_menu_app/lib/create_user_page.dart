import 'package:flutter/material.dart';
import 'package:my_menu_app/login_page.dart';
import 'package:my_menu_app/menu_page.dart';
import 'package:my_menu_app/warehouse_api.dart';

class CreateUserPage extends StatefulWidget {
  const CreateUserPage({Key? key}) : super(key: key);

  @override
  State<CreateUserPage> createState() => _CreateUserPageState();
}

class _CreateUserPageState extends State<CreateUserPage> {
  final TextEditingController usernameController = TextEditingController();
  final TextEditingController passwordController = TextEditingController();

  String? role;
  final api = WarehouseApi(baseUrl: 'http://127.0.0.1:8080');
  String? error;
  bool createUser = false;

  Future<void> attemptCreateUser() async {
    final username = usernameController.text.trim();
    final password = passwordController.text.trim();
    final selectedRole = role;

    setState(() {
      error = null;
      createUser = true;
    });
    if (username.isEmpty || password.isEmpty) {
      setState((){
        error = "Please enter a username and password.";
        createUser = false;
      });
      return;
    }
    if (selectedRole == null || selectedRole.isEmpty) {
      setState(() {
        error = "Please select a role.";
        createUser = false;
      });
      return;
    }
    try{  
      await api.createUser(username: username, password: password, role: selectedRole);
      Navigator.push(
        context,
        MaterialPageRoute(
          builder: (context) => const MenuPage(),
        ),
      );
    }
    catch(e){
      setState(() {
        error = "User creation failed. $e";
      });
    }
    finally{
      setState(() {
        createUser = false;
      });
    }
  }
  
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Create User'),
        leading: Builder(
          builder: (context) => IconButton(
            icon: Icon(Icons.menu),
            onPressed: () => Scaffold.of(context).openDrawer(),
          ),
        ),
      ),
      drawer: Drawer(
        child: ListView(
          padding: EdgeInsets.zero,
          children: [
            DrawerHeader(
              decoration: BoxDecoration(
                color: Colors.blue,
              ),
              child: Text(
                'Menu',
                style: TextStyle(
                  color: Colors.white,
                  fontSize: 14,
                ),
              ),
            ),
            ListTile(
              leading: Icon(Icons.login),
              title: Text('Login'),
              onTap: () { Navigator.pushAndRemoveUntil(
                  context,
                  MaterialPageRoute(
                    builder: (context) => const LoginPage(),
                  ),
                  (route) => false,
                );},
            ),
          ],
        ),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            
            const SizedBox(height: 20),
            TextField(
              controller: usernameController,
              decoration: InputDecoration(
                labelText: 'Create Username',
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(8),
                ),
                prefixIcon: const Icon(Icons.person_2_rounded),
              ),
            ),

            const SizedBox(height: 20),
            TextField(
              controller: passwordController,
              obscureText: true,
              decoration: InputDecoration(
                labelText: 'Create Password',
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(8),
                ),
                prefixIcon: const Icon(Icons.password_rounded),
              ),
            ),

            const SizedBox(height: 20),
            DropdownButtonFormField<String>(
              initialValue: role,
              decoration: InputDecoration(
                labelText: 'Role',
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(8),
                ),
                prefixIcon: const Icon(Icons.work_rounded),
              ),
              items: [
                "Technician",
                "Admin",
              ]
                  .map((type) => DropdownMenuItem<String>(
                        value: type,
                        child: Text(type),
                      ))
                  .toList(),
              onChanged: (value) {
                setState(() {
                  role = value;
                });
              },
            ),

            if (error != null) ...[
              Text(error!, style: const TextStyle(color: Colors.red)),
              const SizedBox(height: 12),
            ],

            const SizedBox(height: 20),
            ElevatedButton(
              onPressed: createUser? null : attemptCreateUser,
              child: const Text('Create'),
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
