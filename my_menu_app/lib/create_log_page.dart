import 'package:flutter/material.dart';
import 'package:my_menu_app/login_page.dart';
import 'package:my_menu_app/menu_page.dart';
import 'package:my_menu_app/offline_database.dart';
import 'package:my_menu_app/server_synchronize.dart';
import 'package:my_menu_app/warehouse_api.dart';
import 'package:flutter/foundation.dart';

class CreateLogPage extends StatefulWidget {
  const CreateLogPage({Key? key}) : super(key: key);

  @override
  State<CreateLogPage> createState() => _CreateLogPageState();
}

class _CreateLogPageState extends State<CreateLogPage> {
  // Controllers for the text input boxes.
  final TextEditingController _datetextController = TextEditingController();
  final TextEditingController _registrationtextController = TextEditingController();
  final TextEditingController _summarytextController = TextEditingController();
  final TextEditingController _techniciantextController = TextEditingController();
  final TextEditingController _notestextController = TextEditingController();

  // Instance of the synchronization class to use
  final ServerSynchronize synchronize = ServerSynchronize.instance;

  final api = WarehouseApi(baseUrl: 'http://127.0.0.1:8080');

  // Values from the drop down boxes
  String? maintenanceType;
  String? priority;

  // States for the create log handler frontend and backend
  String? error;
  String? success;
  bool creatingLog = false;

  Future<void> createLogHandler() async {
    // Get the values that the user inputs
    final summary = _summarytextController.text.trim();
    final aircraft_reg = _registrationtextController.text.trim();
    final technician_name = _techniciantextController.text.trim();
    final notes = _notestextController.text.trim();
    final date = _datetextController.text.trim();

    // Set an offline ID in case connection is down.
    final int offlineId;

    setState(() {
      error = null;
      success = null;
    });

    // Check the text fields are all filled in
    if(summary.isEmpty || aircraft_reg.isEmpty || technician_name.isEmpty || notes.isEmpty || date.isEmpty){
      setState(() {
        error = "Please fill all fields.";
      });
      return;
    }
    // Check thr dropdowns are both filled in
    if (maintenanceType == null || priority == null)
    {
      setState(() {
        error = "Please fill all dropdowns.";
      });
      return;
    }
    setState(() {
      creatingLog = true;
      error = null;
      success = null;
    });

    if (kIsWeb) {
      try {
        await api.createLog(
          summary: summary,
          aircraftReg: aircraft_reg,
          maintenanceType: maintenanceType!,
          priority: priority!,
          technicianName: technician_name,
          notes: notes,
        );

        if(!mounted) return;
        setState(() {
          success = "Log created and synchronized online.";
        });

        _summarytextController.clear();
        _registrationtextController.clear();
        _techniciantextController.clear();
        _notestextController.clear();
        _datetextController.clear();
        setState(() {
          maintenanceType = null;
          priority = null;
        });
      }
      catch (exception) {
        if(!mounted) return;
        setState(() {
          error = "Offline log creation failed. ";
        });
      }
      finally {
        if(!mounted) return;
        setState(() {
          creatingLog = false;
        });
      }
      return;
    }

    // Create offline log 
    try
    {
      offlineId = await OfflineDatabase.instance.addLog(summary: summary, aircraft_reg: aircraft_reg, maintenance_type: maintenanceType!, priority: priority!, technician_name: technician_name, notes: notes);
    }
    catch (exception)
    {
      if(!mounted) return;
      setState(() {
        error = "Offline log creation failed. ";
        creatingLog = false;
      });
      return;
    }
    if(!mounted) return;
    setState(() {
      success = "Offline log created.";
    });

    // Clear all the text fields since successful
    _summarytextController.clear();
    _registrationtextController.clear();
    _techniciantextController.clear();
    _notestextController.clear();
    _datetextController.clear();
    setState(() {
      maintenanceType = null;
      priority = null;
    });
    
    // Synchronize log with server
    try{  
      await synchronize.synchronizeLog(offlineId);
      if(!mounted) return;
      setState(() {
        success = "Log created and synchronized online.";
      });
    }
    catch(exception)
    {
      if(!mounted) return;
      setState(() {
        success = "Log created offline, awaiting online connection for synchronization.";
      });
    }
    finally
    {
      setState(() {
        creatingLog = false;
      });
    }
  }

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
                prefixIcon: const Icon(Icons.person_2_rounded),
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

            if (error != null) ...[
              Text(error!, style: const TextStyle(color: Colors.red)),
              const SizedBox(height: 12),
            ],

            if (success != null) ...
            [
              Text(success!, style: const TextStyle(color: Colors.green)),
              const SizedBox(height: 12),
            ],

            const SizedBox(height: 20),
            ElevatedButton(
              onPressed: creatingLog ? null : createLogHandler,
              child: const Text('Create'),
              style: ElevatedButton.styleFrom(
                padding: const EdgeInsets.symmetric(
                  horizontal: 40,
                  vertical: 15,
                ),
              ),
            ),

            const SizedBox(height: 15),
            TextButton(
              onPressed: () {
                Navigator.pop(context);
              },
              child: const Text('Back to Menu'),
            ),
          ],
        ),
      ),
    );
  }
}
