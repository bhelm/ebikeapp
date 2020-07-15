

import 'package:flutter/cupertino.dart';
import 'package:flutter/foundation.dart';
import 'package:provider/provider.dart';

import 'bluetoothManager.dart';

class ConnectionIndicator extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Consumer<BluetoothManager>(
      builder: (context, btman, child) {
        if(btman.status == Status.uninitialized) {
          return Text("uninitialized");
        } else if(btman.status == Status.connected) {
          return Text("connected");
        }else if(btman.status == Status.disconnected) {
          return Text("disconnected");
        }

        return Text("N/A");
      },
    );
  }
  
}