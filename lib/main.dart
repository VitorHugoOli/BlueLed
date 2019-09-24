import 'dart:core';

import 'package:flutter/material.dart';
import 'package:flutter_blue/flutter_blue.dart';

import 'brucutu.dart';

void main() => runApp(MyApp());

class MyApp extends StatelessWidget {
  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'BlueLed',
      theme: ThemeData(
        primarySwatch: Colors.blue,
        secondaryHeaderColor: Colors.amber,
      ),
      home: Brucutu(title: 'THE MAGICIAN OF LED'),
    );
  }
}
