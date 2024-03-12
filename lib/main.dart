import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:iqos_develop/connectBlue.dart';
import 'package:iqos_develop/test.dart';


void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    SystemChrome.setEnabledSystemUIMode(SystemUiMode.manual, overlays: []);
    return const MaterialApp(debugShowCheckedModeBanner: false , home: ConnectBlue());
  }
}