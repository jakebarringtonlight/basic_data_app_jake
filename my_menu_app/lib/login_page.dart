import 'package:flutter/material.dart';
import 'package:my_menu_app/menu_page.dart';

class LoginPage extends StatefulWidget {
  const LoginPage({Key? key}) : super(key: key);


@override
  State<LoginPage> createState() => _LoginPageState();
}
  List<Map<String, dynamic>> logs = [];

class _LoginPageState extends State<LoginPage> {


  @override
  Widget build(BuildContext context) {
        return Scaffold(
      appBar: AppBar(
        title: Text('Login'),
        leading: Builder(
          builder: (context) => IconButton(
            icon: Icon(Icons.menu),
            onPressed: () => Scaffold.of(context).openDrawer(),
          ),
        ),
      ),
      body: 
      ListView.builder(
        padding: const EdgeInsets.all(20),
        itemCount: logs.length,
        itemBuilder: (context, logId){
        final log = logs[logId];
        return Card(
          child: ListTile(
            leading: const Icon(Icons.event_note),
            title: Text(log["id"] ?? ""),
            subtitle: Text(log["date"] ?? ""),
          ),
         );
        }
      )
    );
  }
}