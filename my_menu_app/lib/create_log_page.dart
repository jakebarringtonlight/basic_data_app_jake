import 'package:flutter/material.dart';
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

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Create Logs'),
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
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            // const SizedBox(height: 20),
            // TextField(
            //   controller: _datetextController,
            //   decoration: InputDecoration(
            //     labelText: 'Date',
            //     border: OutlineInputBorder(
            //       borderRadius: BorderRadius.circular(8),
            //     ),
            //     prefixIcon: const Icon(Icons.message),
            //   ),
            // ),

            const SizedBox(height: 20),
            TextField(
              controller: _registrationtextController,
              decoration: InputDecoration(
                labelText: 'Aircraft Registration Number',
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(8),
                ),
                prefixIcon: const Icon(Icons.message),
              ),
            ),

            const SizedBox(height: 20),
            DropdownButtonFormField<String>(
              value: maintenanceType,
              decoration: InputDecoration(
                labelText: 'Maintenance Type',
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(8),
                ),
                prefixIcon: const Icon(Icons.build),
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
            TextField(
              controller: _summarytextController,
              decoration: InputDecoration(
                labelText: 'Summary',
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(8),
                ),
                prefixIcon: const Icon(Icons.message),
              ),
            ),

            const SizedBox(height: 20),
            TextField(
              controller: _techniciantextController,
              decoration: InputDecoration(
                labelText: 'Technician Name',
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(8),
                ),
                prefixIcon: const Icon(Icons.message),
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
                prefixIcon: const Icon(Icons.message),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
