import 'package:flutter/material.dart';

void main() {
  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      home: MyHomePage(), // Cambiado a un nuevo widget MyHomePage
    );
  }
}

class MyHomePage extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.blue, // Change the color here
        title: Text('Button Example'),
        actions: <Widget>[
          IconButton(
            icon: Icon(Icons.settings),
            onPressed: () {
              Navigator.push(
                context,
                MaterialPageRoute(builder: (context) => SettingsScreen()),
              );
            },
          ),
        ],
      ),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: <Widget>[
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: <Widget>[
                ElevatedButton(
                  onPressed: () {
                    print('Elevated Button 1 Pressed');
                  },
                  child: Text('Reboot LG'),
                ),
                SizedBox(width: 20),
                ElevatedButton(
                  onPressed: () {
                    print('Elevated Button 2 Pressed');
                  },
                  child: Text('Go to Lleida'),
                ),
              ],
            ),
            SizedBox(height: 40),
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: <Widget>[
                ElevatedButton(
                  onPressed: () {
                    print('Elevated Button 3 Pressed');
                  },
                  child: Text('Orbit city'),
                ),
                SizedBox(width: 40),
                ElevatedButton(
                  onPressed: () {
                    print('Elevated Button 4 Pressed');
                  },
                  child: Text('Add Logos'),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
class SettingsScreen extends StatefulWidget {
  @override
  _SettingsScreenState createState() => _SettingsScreenState();
}

class _SettingsScreenState extends State<SettingsScreen> {
  final _formKey = GlobalKey<FormState>();
  TextEditingController _ipController = TextEditingController();
  TextEditingController _portController = TextEditingController();

  @override
  void initState() {
    super.initState();
    _loadSavedData();
  }

  _loadSavedData() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    setState(() {
      _ipController.text = prefs.getString('ipAddress') ?? '';
      _portController.text = prefs.getString('port') ?? '';
    });
  }

  _saveData() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    await prefs.setString('ipAddress', _ipController.text);
    await prefs.setString('port', _portController.text);
  }

  void _connectToLiquidGalaxy() {
    // Connect logic here
    print('Connecting to Liquid Galaxy...');
    print('IP: ${_ipController.text}, Port: ${_portController.text}');
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('LiquidGalaxy Configuration'),
      ),
      body: Padding(
        padding: EdgeInsets.all(16.0),
        child: Form(
          key: _formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: <Widget>[
              TextFormField(
                controller: _ipController,
                decoration: InputDecoration(labelText: 'IP Address'),
                validator: (value) {
                  if (value!.isEmpty) {
                    return 'Please enter an IP address';
                  }
                  return null;
                },
              ),
              TextFormField(
                controller: _portController,
                decoration: InputDecoration(labelText: 'Port'),
                validator: (value) {
                  if (value!.isEmpty) {
                    return 'Please enter a port';
                  }
                  return null;
                },
              ),
              SizedBox(height: 20),
              Center(
                child: ElevatedButton(
                  onPressed: () {
                    if (_formKey.currentState.validate()) {
                      _saveData();
                      _connectToLiquidGalaxy();
                    }
                  },
                  child: Text('Connect'),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}