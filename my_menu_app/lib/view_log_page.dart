import 'package:flutter/material.dart';

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
        title: const Text('View Logs'),
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
