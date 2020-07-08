import 'dart:async';
//import 'dart:math';
import 'dart:developer';
import 'package:flutter/material.dart';
import 'package:flutter_blue/flutter_blue.dart';

class FindDevicesScreen extends StatelessWidget {
    @override
    Widget build(BuildContext context) {
        return Scaffold(
            appBar: AppBar(
                title: Text('Find Devices'),
            ),
            body: RefreshIndicator(
                onRefresh: () =>
                        FlutterBlue.instance.startScan(timeout: Duration(seconds: 4)),
                child: SingleChildScrollView(
                    child: Column(
                        children: <Widget>[
                            StreamBuilder<List<BluetoothDevice>>(
                                stream: Stream.periodic(Duration(seconds: 2))
                                        .asyncMap((_) => FlutterBlue.instance.connectedDevices),
                                initialData: [],
                                builder: (c, snapshot) => Column(
                                    children: snapshot.data
                                            .map((d) => ListTile(
                                        title: Text(d.name),
                                        subtitle: Text(d.id.toString()),
                                        trailing: StreamBuilder<BluetoothDeviceState>(
                                            stream: d.state,
                                            initialData: BluetoothDeviceState.disconnected,
                                            builder: (c, snapshot) {
                                                if (snapshot.data ==
                                                        BluetoothDeviceState.connected) {
                                                    return RaisedButton(
                                                        child: Text('DISCONNECT'),
                                                        onPressed: () {
                                                            log("disconnected?");
                                                            d.disconnect();
                                                        },
                                                    );
                                                }
                                                return Text(snapshot.data.toString());
                                            },
                                        ),
                                    ))
                                            .toList(),
                                ),
                            ),
                            StreamBuilder<List<ScanResult>>(
                                stream: FlutterBlue.instance.scanResults,
                                initialData: [],
                                builder: (c, snapshot) => Column(
                                    children: snapshot.data
                                            .map(
                                                (r) => ScanResultTile(
                                            result: r,
                                            onTap: () {
                                                r.device.connect();
                                                r.device.discoverServices();
                                            },
                                        ),
                                    )
                                            .toList(),
                                ),
                            ),
                        ],
                    ),
                ),
            ),
            floatingActionButton: StreamBuilder<bool>(
                stream: FlutterBlue.instance.isScanning,
                initialData: false,
                builder: (c, snapshot) {
                    if (snapshot.data) {
                        return FloatingActionButton(
                            child: Icon(Icons.stop),
                            onPressed: () => FlutterBlue.instance.stopScan(),
                            backgroundColor: Colors.red,
                        );
                    } else {
                        return FloatingActionButton(
                                child: Icon(Icons.search),
                                onPressed: () => FlutterBlue.instance
                                        .startScan(timeout: Duration(seconds: 4)));
                    }
                },
            ),
        );
    }
}

class ScanResultTile extends StatelessWidget {
    const ScanResultTile({Key key, this.result, this.onTap}) : super(key: key);

    final ScanResult result;
    final VoidCallback onTap;

    Widget _buildTitle(BuildContext context) {
        if (result.device.name.length > 0) {
            return Column(
                mainAxisAlignment: MainAxisAlignment.start,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: <Widget>[
                    Text(
                        result.device.name,
                        overflow: TextOverflow.ellipsis,
                    ),
                    Text(
                        result.device.id.toString(),
                        style: Theme.of(context).textTheme.caption,
                    )
                ],
            );
        } else {
            return Text(result.device.id.toString());
        }
    }

    Widget _buildAdvRow(BuildContext context, String title, String value) {
        return Padding(
            padding: EdgeInsets.symmetric(horizontal: 16.0, vertical: 4.0),
            child: Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: <Widget>[
                    Text(title, style: Theme.of(context).textTheme.caption),
                    SizedBox(
                        width: 12.0,
                    ),
                    Expanded(
                        child: Text(
                            value,
                            style: Theme.of(context)
                                    .textTheme
                                    .caption
                                    .apply(color: Colors.black),
                            softWrap: true,
                        ),
                    ),
                ],
            ),
        );
    }

    String getNiceHexArray(List<int> bytes) {
        return '[${bytes.map((i) => i.toRadixString(16).padLeft(2, '0')).join(', ')}]'
                .toUpperCase();
    }

    String getNiceManufacturerData(Map<int, List<int>> data) {
        if (data.isEmpty) {
            return null;
        }
        List<String> res = [];
        data.forEach((id, bytes) {
            res.add(
                    '${id.toRadixString(16).toUpperCase()}: ${getNiceHexArray(bytes)}');
        });
        return res.join(', ');
    }

    String getNiceServiceData(Map<String, List<int>> data) {
        if (data.isEmpty) {
            return null;
        }
        List<String> res = [];
        data.forEach((id, bytes) {
            res.add('${id.toUpperCase()}: ${getNiceHexArray(bytes)}');
        });
        return res.join(', ');
    }

    @override
    Widget build(BuildContext context) {
        return ExpansionTile(
            title: _buildTitle(context),
            leading: Text(result.rssi.toString()),
            trailing: RaisedButton(
                child: Text('CONNECT'),
                color: Colors.black,
                textColor: Colors.white,
                onPressed: (result.advertisementData.connectable) ? onTap : null,
            ),
            children: <Widget>[
                _buildAdvRow(
                        context, 'Complete Local Name', result.advertisementData.localName),
                _buildAdvRow(context, 'Tx Power Level',
                        '${result.advertisementData.txPowerLevel ?? 'N/A'}'),
                _buildAdvRow(
                        context,
                        'Manufacturer Data',
                        getNiceManufacturerData(
                                result.advertisementData.manufacturerData) ??
                                'N/A'),
                _buildAdvRow(
                        context,
                        'Service UUIDs',
                        (result.advertisementData.serviceUuids.isNotEmpty)
                                ? result.advertisementData.serviceUuids.join(', ').toUpperCase()
                                : 'N/A'),
                _buildAdvRow(context, 'Service Data',
                        getNiceServiceData(result.advertisementData.serviceData) ?? 'N/A'),
            ],
        );
    }
}
