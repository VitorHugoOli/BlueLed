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
  bool available = false;
  List<BluetoothDevice> devicesCatched = [];

  @override
  void initState() {
    super.initState();
    flutterBlue.isAvailable
        .then((available) => this.setState(() => this.available = available));
  }

  void conecta(BluetoothDevice device) async {
    await device.connect();
    Navigator.of(context).push(
      MaterialPageRoute(builder: (context) => DeviceScreen(device: device)),
    );
  }

  Widget buildList() {
    if (devicesCatched.length > 0) {
      return ListView.builder(
        itemCount: devicesCatched.length,
        itemBuilder: (context, index) {
          return GestureDetector(
            child: Container(
              height: 50,
              child: Center(
                child: Text(devicesCatched[index].name),
              ),
              margin: const EdgeInsets.symmetric(
                vertical: 30,
                horizontal: 15,
              ),
              decoration: BoxDecoration(
                gradient: new LinearGradient(
                    colors: [Color(0xFFBF3617), Color(0xFF00BF7A)]),
                borderRadius: BorderRadius.circular(15),
              ),
            ),
            onTap: () => conecta(devicesCatched[index]),
          );
        },
      );
    } else {
      return Align(
        heightFactor: 9,
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
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        body: !available
            ? Text('No bluetooth device')
            : Stack(children: <Widget>[
                Container(
                  decoration: BoxDecoration(
                    image: DecorationImage(
                      image: AssetImage("assets/images/circle.jpg"),
                      fit: BoxFit.cover,
                    ),
                  ),
                ),
                SmartRefresher(
                  controller: _refreshController,
                  enablePullDown: true,
                  onRefresh: scanAndConnect,
                  child: buildList(),
                ),
              ]));
  }

  void scanAndConnect() {
    setState(() {
      devicesCatched.clear();
    });
    Future.delayed(Duration(seconds: 1)).then((_) {
      _refreshController.refreshCompleted();
    });
    flutterBlue
        .scan(scanMode: ScanMode.balanced, timeout: Duration(seconds: 4))
        .listen((scanResult) {
      // do something with scan result
      BluetoothDevice device = scanResult.device;
      print(device.name);
      if (!devicesCatched.contains(device) && device.name != "") {
        setState(() {
          devicesCatched.add(device);
        });
      }
    });
  }
}
