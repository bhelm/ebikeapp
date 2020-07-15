import 'package:flutter/material.dart';
import 'dart:convert';
import 'dart:developer';
import 'dart:collection';
import 'dart:async' show Future;
import 'package:flutter/services.dart' show rootBundle;
import 'package:numberpicker/numberpicker.dart';
import 'package:provider/provider.dart';
import 'bluetoothManager.dart';
import 'connectionIndicator.dart';
import "ebikeConfig.dart";
import "bluetoothConfig.dart";

void main() {
  runApp(MultiProvider(
    providers: [
      ListenableProvider<BluetoothManager>(create: (_) => BluetoothManager()),
    ],
    child: MaterialApp(
      title: 'Navigation Basics',
      home: HomeScreen(),
    ),
  ));
}

class HomeScreen extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Row(children: [
          ConnectionIndicator()

        ]),
      ),
      body: Center(
        child: Text('Home Screen'),
      ),
      drawer: Drawer(
        // Add a ListView to the drawer. This ensures the user can scroll
        // through the options in the drawer if there isn't enough vertical
        // space to fit everything.
        child: ListView(
          // Important: Remove any padding from the ListView.
          padding: EdgeInsets.zero,
          children: <Widget>[
            DrawerHeader(
              child: Text('eBike App'),
              decoration: BoxDecoration(
                color: Colors.blue,
              ),
            ),
            ListTile(
              title: Text('eBike Configuration'),
              onTap: () {
                Navigator.pop(context);
                Navigator.push(
                  context,
                  MaterialPageRoute(
                      builder: (context) => EBikeConfigurationMenu(
                          title: "eBike Configuration")),
                );
              },
            ),
            ListTile(
              title: Text('App Configuration'),
              onTap: () {
                Navigator.pop(context);
                Navigator.push(
                  context,
                  MaterialPageRoute(
                      builder: (context) => AppConfigurationMenu()),
                );
              },
            ),
              ListTile(
                  title: Text('Bluetooth config'),
                  onTap: () {
                      Navigator.pop(context);
                      Navigator.push(
                          context,
                          MaterialPageRoute(
                                  builder: (context) => FindDevicesScreen()),
                      );
                  },
              ),
          ],
        ),
      ),
    );
  }
}

class AppConfigurationMenu extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text("AppConfigurationMenu"),
      ),
      body: Center(
        child: RaisedButton(
          onPressed: () {
            Navigator.pop(context);
          },
          child: Text('Go back!'),
        ),
      ),
    );
  }
}
