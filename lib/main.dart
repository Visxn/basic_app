import 'package:flutter/material.dart';

void main() {
  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      home: Scaffold(
        appBar: AppBar(
          backgroundColor: Colors.blue, // Change the color here
          title: Text('Button Example'),
          actions: <Widget>[
            IconButton(
              icon: Icon(Icons.settings),
              onPressed: () {
                // Add your settings button onPressed logic here
                print('Settings Button Pressed');
                // Navigate to settings screen or show settings dialog
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
                      // Add your button onPressed logic here
                      print('Elevated Button 1 Pressed');
                    },
                    child: Text('Reboot LG'),
                  ),
                  SizedBox(width: 20), // Add space between buttons
                  ElevatedButton(
                    onPressed: () {
                      // Add your button onPressed logic here
                      print('Elevated Button 2 Pressed');
                    },
                    child: Text('Go to Lleida'),
                  ),
                ],
              ),
              SizedBox(height: 40), // Add space between rows
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: <Widget>[
                  ElevatedButton(
                    onPressed: () {
                      // Add your button onPressed logic here
                      print('Elevated Button 3 Pressed');
                    },
                    child: Text('Orbit city'),
                  ),
                  SizedBox(width: 40), // Add space between buttons
                  ElevatedButton(
                    onPressed: () {
                      // Add your button onPressed logic here
                      print('Elevated Button 4 Pressed');
                    },
                    child: Text('Add Logos'),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}
