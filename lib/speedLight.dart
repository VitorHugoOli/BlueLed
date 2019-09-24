import 'dart:math' as math;

import 'package:flutter/material.dart';
import 'package:flutter_blue/flutter_blue.dart';

class DeviceScreen extends StatefulWidget {
  const DeviceScreen({Key key, this.device}) : super(key: key);
  final BluetoothDevice device;

  @override
  DeviceScreenState createState() => DeviceScreenState();
}

class DeviceScreenState extends State<DeviceScreen> {
  BluetoothCharacteristic char;
  int speed = 20;

  void increment(int delta) {
    setState(() {
      speed = math.max(0, math.min(40, speed + delta));
    });
  }

  bool scanning = false;

  void scanNow() async {
    if (scanning) {
      return;
    }
    scanning = true;
    List<BluetoothService> services = await widget.device.discoverServices();
    services.forEach((service) async {
      print(service.uuid);
      var characteristics = service.characteristics;
      for (BluetoothCharacteristic c in characteristics) {
        print(c.uuid);
        if (c.uuid.toString() == '560d029d-57a1-4ccc-8868-9e4b4ef41da6') {
          setState(() {
            char = c;
          });
        }
      }
      scanning = false;
    });
  }

  @override
  void dispose() {
    widget.device.disconnect();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return new WillPopScope(
      child: Scaffold(
        body: Stack(
          children: <Widget>[
            Container(
              decoration: BoxDecoration(
                image: DecorationImage(
                  image: AssetImage("assets/images/circle.jpg"),
                  fit: BoxFit.cover,
                ),
              ),
            ),
            StreamBuilder<BluetoothDeviceState>(
                stream: widget.device.state,
                builder: (context, snapshot) {
                  final loading = Center(
                    child: CircularProgressIndicator(),
                  );
                  if (!snapshot.hasData ||
                      snapshot.data == BluetoothDeviceState.connecting) {
                    return loading;
                  }
                  final data = snapshot.data;
                  if (data == BluetoothDeviceState.connected && char == null) {
                    scanNow();
                    return loading;
                  }
//                  if (data == BluetoothDeviceState.disconnected) {
//                    Navigator.of(context).pop();
//                    showDialog(
//                      context: context,
//                      builder: (context) => AlertDialog(
//                        title: const Text('Device disconnected'),
//                      ),
//                    );
//                  }

                  if(speed==38){

                  }

                  return Center(
                    child: Column(

                      children: <Widget>[
                        SizedBox(
                          height: 110.0,
                        ),

                        Text(
                          (speed==40)?"Maximo":(speed==0)?"Minimo":'$speed',
                          style: TextStyle(
                            color: Colors.white,
                            fontSize: 40,
                            fontWeight: FontWeight.bold
                          ),
                        ),
                        SizedBox(
                          height: 100.0,
                        ),
                        FloatingActionButton(
                          heroTag: null,
                          onPressed: () async {
                            await char.write([34], withoutResponse: true);
                            increment(1);
                          },
                          materialTapTargetSize: MaterialTapTargetSize.padded,
                          backgroundColor: Colors.white38,
                          child: const Icon(Icons.add, size: 36.0),
                        ),
                        SizedBox(
                          height: 40.0,
                        ),
                        FloatingActionButton(
                          heroTag: null,
                          onPressed: () async {
                            await char.write([35], withoutResponse: true);
                            increment(-1);
                          },
                          materialTapTargetSize: MaterialTapTargetSize.padded,
                          backgroundColor: Colors.white38,
                          child: const Icon(Icons.remove, size: 36.0),
                        ),
                      ],
                    ),
                  );
                }),
          ],
        )


      ),
    );
  }
}
