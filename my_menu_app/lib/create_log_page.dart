import 'package:flutter/material.dart';
import 'package:my_menu_app/login_page.dart';
import 'package:my_menu_app/menu_page.dart';

class CreateLogPage extends StatefulWidget {
  const CreateLogPage({Key? key}) : super(key: key);

  @override
  State<CreateLogPage> createState() => _CreateLogPageState();
}

class _CreateLogPageState extends State<CreateLogPage> {
  final TextEditingController _datetextController = TextEditingController();
  final TextEditingController _registrationtextController = TextEditingController();
  final TextEditingController _summarytextController = TextEditingController();
  final TextEditingController _techniciantextController = TextEditingController();
  final TextEditingController _notestextController = TextEditingController();

  String? maintenanceType;
  String? priority;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Create Log'),
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
              leading: Icon(Icons.settings),
              title: Text('Settings'),
              onTap: () {},
            ),
            ListTile(
              leading: Icon(Icons.logout),
              title: Text('Logout'),
              onTap: () {Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => const LoginPage(),
                  ),
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
              controller: _summarytextController,
              decoration: InputDecoration(
                labelText: 'Summary',
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(8),
                ),
                prefixIcon: const Icon(Icons.title_rounded),
              ),
            ),

            const SizedBox(height: 20),
            TextField(
              controller: _registrationtextController,
              decoration: InputDecoration(
                labelText: 'Aircraft Registration Number',
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(8),
                ),
                prefixIcon: const Icon(Icons.airplanemode_active_rounded),
              ),
            ),

            const SizedBox(height: 20),
            DropdownButtonFormField<String>(
              initialValue: maintenanceType,
              decoration: InputDecoration(
                labelText: 'Maintenance Type',
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(8),
                ),
                prefixIcon: const Icon(Icons.build_rounded),
              ),
              items: [
                "Routine",
                "Inspection",
                "Repair",
                "Emergency Repair",
              ]
                  .map((type) => DropdownMenuItem<String>(
                        value: type,
                        child: Text(type),
                      ))
                  .toList(),
              onChanged: (value) {
                setState(() {
                  maintenanceType = value;
                });
              },
            ),

            const SizedBox(height: 20),
            DropdownButtonFormField<String>(
              initialValue: priority,
              decoration: InputDecoration(
                labelText: 'Priority',
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(8),
                ),
                prefixIcon: const Icon(Icons.warning_amber_rounded),
              ),
              items: [
                "High",
                "Medium",
                "Low",
              ]
                  .map((type) => DropdownMenuItem<String>(
                        value: type,
                        child: Text(type),
                      ))
                  .toList(),
              onChanged: (value) {
                setState(() {
                  priority = value;
                });
              },
            ),

            const SizedBox(height: 20),
            TextField(
              controller: _techniciantextController,
              decoration: InputDecoration(
                labelText: 'Technician Name',
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(8),
                ),
                prefixIcon: const Icon(Icons.perm_identity_rounded),
              ),
            ),

            const SizedBox(height: 20),
            OutlinedButton(
              style: OutlinedButton.styleFrom(
                minimumSize: const Size(double.infinity, 56),
                alignment: Alignment.centerLeft,
                padding: const EdgeInsets.symmetric(horizontal: 16),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(8)
                ),  
                side: BorderSide(
                  color: Theme.of(context).colorScheme.outline,
                  width: 1.5,
                )
              ),
              onPressed: () async {
                final date = await showDatePicker(
                  context: context,
                  initialDate: DateTime.now(),
                  firstDate: DateTime(1999),
                  lastDate: DateTime(2030),
                );

                if (date == null) return;

                final time = await showTimePicker(
                  context: context,
                  initialTime: TimeOfDay.now(),
                );

                if (time == null) return;

                final dateTime = DateTime(
                  date.year,
                  date.month, 
                  date.day, 
                  time.hour, 
                  time.minute, 
                );
                
                final dateTimeString = "${dateTime.day}/${dateTime.month}/${dateTime.year}  ${time.format(context)}";

                setState(() {
                  _datetextController.text = dateTimeString;
                });
              },
              child: Row(
                children: [
                  Icon(
                    Icons.calendar_today_rounded, 
                    color: Theme.of(context).hintColor,
                  ),
                const SizedBox(width: 12),
                  Text(
                    _datetextController.text.isEmpty ? "Date" : _datetextController.text,
                    style: TextStyle(
                      color: _datetextController.text.isEmpty ? Theme.of(context).hintColor : Theme.of(context).textTheme.bodyLarge!.color,
                    ),
                  )
                ]
                
              ),
            ),
            
            const SizedBox(height: 20),
            TextField(
              controller: _notestextController,
              decoration: InputDecoration(
                labelText: 'Notes',
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(8),
                ),
                prefixIcon: const Icon(Icons.notes_rounded),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
