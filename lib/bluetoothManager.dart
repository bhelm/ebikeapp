import 'package:flutter/foundation.dart';
import 'package:flutter_blue/flutter_blue.dart';
import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';
enum Status {
   uninitialized,
   connected,
   disconnected,
   scanning
}

class BluetoothManager with ChangeNotifier {

   BluetoothDevice _ebike;
   Status status;
   SharedPreferences prefs;

   BluetoothManager() {
      print("bluetoothmanager created");
      status = Status.uninitialized;
      _autoConnect();
   }

   void setupListeners() async {
      // update the connection state if it changes on bluetooth
      await for (var state in _ebike.state) {
         if(state == BluetoothDeviceState.connected) {
            status = Status.connected;
         }else {
            status = Status.disconnected;
         }
         notifyListeners();
      }
   }

   void setEbike(BluetoothDevice device) {
      _ebike = device;
      //status = Status.connected;
      setupListeners();
      _saveDevice(device);
      notifyListeners();
   }

   void _autoConnect() async {
      SharedPreferences prefs = await SharedPreferences.getInstance();
      String deviceAddress = prefs.getString('autoConnect');
      if(deviceAddress != null) {
         print("starting auto connect search for " + deviceAddress);
         FlutterBlue blue = FlutterBlue.instance;
         blue.startScan();
         print("scan started");
         blue.scanResults.listen((results) async {
            // do something with scan results
            for (ScanResult r in results) {
               print("found " + r.device.id.toString()+": " + r.device.name);
               if(r.device.id.toString() == deviceAddress) {
                  print("connecting to saved device " + deviceAddress + " with rssi: ${r.rssi}");
                  await r.device.connect(autoConnect: true);
                  blue.stopScan();
                  setEbike(r.device);
               }
            }
         });
      }
   }

   void _saveDevice(BluetoothDevice device) async {
      SharedPreferences prefs = await SharedPreferences.getInstance();
      print('saving autoconnect device ' + device.id.toString());
      await prefs.setString('autoConnect', device.id.toString());
   }

}