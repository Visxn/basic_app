import 'package:basic_app/entities/baloon.dart';
import 'package:basic_app/entities/look_at_entity.dart';
import 'package:basic_app/services/storage_service.dart';
import 'package:flutter/material.dart';
import './entities/ssh_entity.dart';
import './services/ssh_service.dart';
import './services/lg_service.dart';
import './entities/orbit.dart';

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
                    showDialog(
                      context: context,
                      builder: (BuildContext context) {
                        return AlertDialog(
                          title: Text('Confirmation'),
                          content: Text('Are you sure you want to reboot?'),
                          actions: [
                            TextButton(
                              onPressed: () {
                                Navigator.pop(context);
                              },
                              child: Text('Cancel'),
                            ),
                            ElevatedButton(
                              onPressed: () async {
                                Navigator.pop(context);
                                await LGService.shared?.reboot();
                              },
                              child: Text('OK'),
                            ),
                          ],
                        );
                      },
                    );
                  },
                  child: Text('Reboot LG'),
                ),
                SizedBox(width: 20),
                ElevatedButton(
                  onPressed: () async {
                   await LGService.shared?.sendTour(
                       41.6167, //ficar coordenades de Lleida
                       0.6222,  //ficar coordenades de Lleida
                       15, //ficar valors manual
                       45, //ficar valors manual
                       180 //ficar valors manual
                    );
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
                    Future<void> _buildOrbit() async {
                      final lookAt = LookAtEntity(
                          lng: 0.6222, //ficar valors de la funcio go  to lleida
                          lat: 41.6167, //ficar valors de la funcio go  to lleida
                          range: '1500',
                          tilt: 45, //ficar valors de func go to lleida
                          heading: '0',
                          zoom: 15);  //ficar valors de func go to lleida
                      final orbit = OrbitEntity.buildOrbit(OrbitEntity.tag(lookAt));
                      await LGService.shared?.sendOrbit(orbit, "Orbit");
                    }
                  },
                  child: Text('Orbit city'),
                ),
                SizedBox(width: 40),
                ElevatedButton(
                  onPressed: () {
                    final kml =
                    KMLBalloonEntity(name: 'Roger', city: 'Lleida');
                    LGService.shared
                        ?.sendKMLToSlave(LGService.shared!.lastScreen, kml.body);
                  },
                  child: Text('Add Names'),
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

  final SSHService sshService = SSHService.shared;
  final StorageService settingsService = StorageService.shared;
  final _formKey = GlobalKey<FormState>();
  TextEditingController _userController = TextEditingController();
  TextEditingController _passwordController = TextEditingController();
  TextEditingController _ipController = TextEditingController();
  TextEditingController _portController = TextEditingController();

  @override
  void initState() {
    super.initState();
    // _loadSavedData();
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
                controller: _userController,
                decoration: InputDecoration(labelText: 'LG User'),
                validator: (value) {
                  if (value!.isEmpty) {
                    return 'Please enter an IP address';
                  }
                  return null;
                },
              ),
              TextFormField(
                controller: _passwordController,
                decoration: InputDecoration(labelText: 'LG Password'),
                validator: (value) {
                  if (value!.isEmpty) {
                    return 'Please enter an IP address';
                  }
                  return null;
                },
              ),
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
                  onPressed: () async {
                    final username = _userController.text;
                    final password = _passwordController.text;
                    final ipAddress = _ipController.text;
                    final port = int.parse(_portController.text);

                    final connectionSettings = SSHEntity(
                      host: ipAddress,
                      port: port,
                      username: username,
                      passwordOrKey: password,
                    );

                    await settingsService.saveConnectionSettings(
                      username,
                      password,
                      ipAddress,
                      port.toString(),
                    );

                    try {
                      await sshService.connect(connectionSettings);

                      const snackBar = SnackBar(
                          content: Text('¡Connection successful!'));
                      ScaffoldMessenger.of(context).showSnackBar(snackBar);

                    } catch (e) {
                      print('Connection error : $e');
                      const snackBar =
                      SnackBar(content: Text('¡Connection error'));
                      ScaffoldMessenger.of(context).showSnackBar(snackBar);
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