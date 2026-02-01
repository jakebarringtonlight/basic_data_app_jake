import 'package:flutter/material.dart';
import 'package:my_menu_app/login_page.dart';
import 'package:my_menu_app/menu_page.dart';
import 'package:my_menu_app/warehouse_api.dart';

class ViewLogPage extends StatefulWidget {
  const ViewLogPage({Key? key}) : super(key: key);

  @override
  State<ViewLogPage> createState() => _ViewLogPageState();
}

class _ViewLogPageState extends State<ViewLogPage> {

  final api = WarehouseApi(baseUrl: 'http://127.0.0.1:8080');

  List<Map<String, dynamic>> logs = [];
  bool loadingLogs = true;
  String? error;

  @override
  void initState()
  {
    super.initState();
    loadLogs();
  }


  Future<void> loadLogs() async
  {
    setState(() {
      loadingLogs = true;
      error = null;
    });

    try
    {
      final data = await api.listLogs();

      if (!mounted) return;

      setState(() {
        logs = data;
      });

    }
        catch (exception)
    {
      setState(() {
        error = "Loading logs failed $exception";
      });
    }
    finally
    {
      setState(() {
        loadingLogs = false;
      });
    }
  }
  @override
  Widget build(BuildContext context) {
        return Scaffold(
      appBar: AppBar(
        title: Text('View Logs'),
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh_rounded),
            onPressed: loadLogs,
          )
        ],
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
                    builder: (context) => const MenuPage(),
                  ),
                );},
            ),
            ListTile(
              leading: Icon(Icons.logout),
              title: Text('Logout'),
              onTap: () {Navigator.pushAndRemoveUntil(
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
            if (logs.isEmpty) ...[
              const Text("No logs found.")
            ],
            if (error != null) ...[
              Text(error!, style: const TextStyle(color: Colors.red)),
              const SizedBox(height: 12),
            ]
            else ...
            [
              ListView.builder(
                shrinkWrap: true,
                physics: const NeverScrollableScrollPhysics(),
                itemCount: logs.length,
                itemBuilder: (context, index){
                  final log = logs[index];

                  final id = log["id"]?.toString() ?? "";
                  final summary = log["summary"]?.toString() ?? "";
                  final aircraft_reg = log["aircraft_reg"]?.toString() ?? "";
                  final priority = log["priority"]?.toString() ?? "";
                  final created_at = log["created_at"]?.toString() ?? "";

                  return Card(
                    margin: const EdgeInsets.all(12),
                    child: ListTile(
                      leading: const Icon(Icons.event_note),
                      title: Text("Log $id : $summary"),
                      subtitle: Text("$aircraft_reg, $priority, $created_at"),

                      trailing: IconButton(
                        icon: const Icon(Icons.delete_outline_rounded),
                        tooltip: "Delete Log",
                        onPressed: () async {
                          try {
                            await api.deleteLog(int.parse(id));
                            setState(() {
                              logs.removeAt(index);
                              error = null;
                            });
                          }
                          catch(e)
                          {
                            setState(() {
                              error = "Delete log failed.";
                            });
                          }
                        },
                      ),
                    ),
                  );
                },
              )
            ]
          ]
        )
      )
    );
  }
}
