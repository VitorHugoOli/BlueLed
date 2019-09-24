import 'dart:async';

import 'package:BlueLed/speedLight.dart';
import 'package:flutter/material.dart';
import 'package:flutter_blue/flutter_blue.dart';
import 'package:pull_to_refresh/pull_to_refresh.dart';

class Brucutu extends StatefulWidget {
  Brucutu({Key key, this.title}) : super(key: key);
  final String title;

  @override
  _BrucutuState createState() => _BrucutuState();
}

class _BrucutuState extends State<Brucutu> {
  final RefreshController _refreshController = RefreshController();
  FlutterBlue flutterBlue = FlutterBlue.instance;
  var devicesCatched = [];

  void conecta(BluetoothDevice device) {
    device.connect();
    StreamBuilder<BluetoothDeviceState>(
        stream: device.state,
        initialData: BluetoothDeviceState.disconnected,
        builder: (c, snapshot) {
          if (snapshot.data == BluetoothDeviceState.connected) {
            Navigator.of(context).push(MaterialPageRoute(
                builder: (context) => DeviceScreen(device: device)));
          }
          ;
          return;
        });
  }

//  Stream<List<Widget>> get _buildList async*{
//    yield await _refreshController.isRefresh;
//  }

  List<Widget> buildList() {
    if (devicesCatched.length > 0) {
      return List.generate(devicesCatched.length, (index) {
        return GestureDetector(
          child: Container(
            height: 50,
            child: Center(
              child: Text(devicesCatched[index].name),
            ),
            margin: const EdgeInsets.symmetric(
              vertical: 10,
              horizontal: 15,
            ),
            decoration: BoxDecoration(
              gradient: new LinearGradient(
                colors: [Colors.amber, Colors.cyan],
              ),
              borderRadius: BorderRadius.circular(15),
            ),
          ),
          onTap: () {
            Navigator.of(context).push(MaterialPageRoute(
                builder: (context) =>
                    DeviceScreen(device: devicesCatched[index])));
          },
        );
      });
    } else {
      return List.generate(1, (index) {
        return Align(
          heightFactor: 8,
          alignment: Alignment.centerRight,
          child: Text(
            "Lista de Device vazia porfavor puxe para baixo",
            style: TextStyle(
              color: Colors.white,
              fontSize: 30,
              fontWeight: FontWeight.bold,
            ),
            textAlign: TextAlign.center,
          ),
        );
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        appBar: AppBar(
          title: Text(
            widget.title,
          ),
        ),
        body: Stack(children: <Widget>[
          Container(
            decoration: BoxDecoration(
              image: DecorationImage(
                image: AssetImage("assets/images/photo.jpg"),
                fit: BoxFit.cover,
              ),
            ),
          ),
          SmartRefresher(
            controller: _refreshController,
            enablePullDown: true,
            onRefresh: () async {
              await Future.delayed(Duration(seconds: 1));
              scanAndConnect();
              Navigator.of(context).push(MaterialPageRoute(
                  builder: (context) => Brucutu(
                        title: "reload",
                      )));
              _refreshController.refreshCompleted();
            },
            child: new CustomScrollView(
              slivers: [
                SliverList(delegate: SliverChildListDelegate(buildList()))
              ],
            ),
          ),
        ]));
  }

  void scanAndConnect() {

    devicesCatched.clear();
    flutterBlue
        .scan(scanMode: ScanMode.balanced, timeout: Duration(seconds: 4))
        .listen((scanResult) {
      // do something with scan result
      BluetoothDevice device = scanResult.device;
      if (device.name == 'ESP32_Vitorrr') {
        print("Heloo");
        device.connect();
      }

      if (!devicesCatched.contains(device) && device.name != "")
        devicesCatched.add(device);

    });

  }
}
