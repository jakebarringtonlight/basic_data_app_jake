import 'package:flutter/material.dart';
import 'package:my_menu_app/menu_page.dart';

class ViewLogPage extends StatefulWidget {
  const ViewLogPage({Key? key}) : super(key: key);

  @override
  State<ViewLogPage> createState() => _ViewLogPageState();
}

class _ViewLogPageState extends State<ViewLogPage> {

  List<Map<String, dynamic>> logs = [];

  @override
  Widget build(BuildContext context) {
        return Scaffold(
      appBar: AppBar(
        title: Text('View/Edit Logs'),
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
              leading: Icon(Icons.home),
              title: Text('Home'),
              onTap: () { Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => const MenuScreen(),
                  ),
                );},
            ),
            ListTile(
              leading: Icon(Icons.settings),
              title: Text('Settings'),
              onTap: () {},
            ),
            ListTile(
              leading: Icon(Icons.logout),
              title: Text('Logout'),
              onTap: () {},
            ),
          ],
        ),
      ),
      body: ListView.builder(
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
